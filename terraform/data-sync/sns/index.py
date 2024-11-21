import boto3
import json
import re
import logging

from os import getenv, environ
from textwrap import dedent
from pprint import pformat
from boto3 import client
from datetime import datetime, timezone
from zoneinfo import ZoneInfo


datasync_client = client("datasync")
sns_client = client("sns")
sts_client = client('sts')

# Initialize the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)
 
# Initialize the DataSync client
datasync_client = boto3.client('datasync')

AWS_ACCOUNT_ID = sts_client.get_caller_identity()["Account"]
AWS_REGION = getenv('AWS_REGION')

def get_tags_for_resource(resource_arn):
    """Retrieve and print tags for the specified DataSync resource."""
    try:
        # Call DataSync to list tags for the given resource ARN
        response = datasync_client.list_tags_for_resource(ResourceArn=resource_arn)
        
        # Pretty-print the response
        logger.info("Tags Retrieved: %s", json.dumps(response, indent=2))
        
        # Optionally, extract specific tags if needed
        tags = {tag['Key']: tag['Value'] for tag in response.get('Tags', [])}
        return tags

    except Exception as e:
        logger.error("Error retrieving tags: %s", str(e))
        return {}
        
def get_locations(client):
    locations = []
    paginator = client.get_paginator('list_locations')
    for page in paginator.paginate():
        locations += page['Locations']
    return locations
    
def describe_location(location_arn, locations, client):

    # Determine the location type based on the LocationArn or iterate over possible describe operations
    for location in locations:
        if location['LocationArn'] == location_arn:
            location_uri = location['LocationUri']

            # Based on the LocationUri, determine the type of location
            if location_uri.startswith('s3://'):
                return client.describe_location_s3(LocationArn=location_arn)
            elif location_uri.startswith('nfs://'):
                return client.describe_location_nfs(LocationArn=location_arn)
            elif location_uri.startswith('smb://'):
                return client.describe_location_smb(LocationArn=location_arn)
            elif location_uri.startswith('fsx://'):
                return client.describe_location_fsx_lustre(LocationArn=location_arn)
            elif location_uri.startswith('hdfs://'):
                return client.describe_location_hdfs(LocationArn=location_arn)
            elif location_uri.startswith('efs://'):
                return client.describe_location_efs(LocationArn=location_arn)
            else:
                raise ValueError(f"Unsupported location type for ARN: {location_arn}")

    raise ValueError(f"Location ARN {location_arn} not found in the provided locations list")

def utc_to_local(utc_dt, local_tz):
    """Converts UTC datetime to the specified local timezone."""
    local_timezone = ZoneInfo(local_tz)
    local_dt = utc_dt.astimezone(local_timezone)
    # Format the datetime to 'Aug 27, 2024, 9:38:16 AM EDT'
    formatted_time = local_dt.strftime('%b %d, %Y, %I:%M:%S %p %Z')
    return formatted_time
    

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event, indent=2))

    task_execution_arn = event['resources'][0]
    task_arn = re.sub(r'/execution/.*$', '', task_execution_arn)
    locations = get_locations(datasync_client)

    # Retrieve task and execution details
    task = datasync_client.describe_task(TaskArn=task_arn)
    execution_status = datasync_client.describe_task_execution(TaskExecutionArn=task_execution_arn)
    source_location = describe_location(task['SourceLocationArn'], locations, datasync_client)
    destination_location = describe_location(task['DestinationLocationArn'], locations, datasync_client)
    
    #list_tags = datasync_client.list_tags_for_resource(ResourceArn=task_arn)
    #tier = [item['Value'] for item in list_tags['Tags'] if item['Key'] == 'Tier'][0]
    #type = [item['Value'] for item in list_tags['Tags'] if item['Key'] == 'Type'][0]
    
    #tier = "dev"
    #type = "metadata"

    
    # add this before we have tags to test
    #if "dev2" in source_location['LocationUri']:
     #   tier = "dev2"
    #if "qa" in source_location['LocationUri']:
     #   tier = "qa"    
    #if "qa2" in source_location['LocationUri']:
     #   tier = "qa2"
    #if "stage" in source_location['LocationUri']:
     #   tier = "stage"
    #if "prod" in source_location['LocationUri']:
     #   tier = "prod"
    

    # Retrieve tags for the task
    tags = get_tags_for_resource(task_arn)
    tier = tags.get('Tier', 'default')
    type = tags.get('Type', 'unknown')

    logger.info("Extracted Tier: %s, Type: %s", tier, type)

    # Construct tier description
    if tier == "prod":
        tier_description = ""
    else:
        tier_description = f"[{tier}]"

    logger.info("Tier Description: %s", tier_description)
    
    print(task)
    print(execution_status)
    print(source_location)
    print(destination_location)

    status = execution_status['Status']

    # Construct SNS topic ARN
    topic_arn = f"arn:aws:sns:{AWS_REGION}:{AWS_ACCOUNT_ID}:datasync-status-topic-{tier}"
    logger.info("Using SNS Topic ARN: %s", topic_arn)

    # Convert start time to local time
    start_time_local = utc_to_local(execution_status['StartTime'], 'America/New_York')

    # Calculate transfer duration and throughput
    duration_seconds = execution_status['Result']['TransferDuration'] / 1000
    duration_minutes = duration_seconds // 60
    remaining_seconds = duration_seconds % 60
    bytes_transferred = execution_status['BytesTransferred']
    data_throughput = bytes_transferred / duration_seconds / 1024 if duration_seconds else 0

    # Construct the message and subject based on status
    status = execution_status['Status']
    if status == 'SUCCESS':
        subject = f"{tier_description.upper()} CRDC Data Hub {type} DataSync Task Completed - {execution_status['Status']}"
        message = dedent(f"""
            Source Location: {source_location['LocationUri']}\n
            Destination Location: {destination_location['LocationUri']}\n
            Start Time: {start_time_local}\n
            Transfer Duration: {duration_seconds} seconds\n
            Files Transferred: {execution_status['FilesTransferred']}\n
            Files Skipped: {execution_status['FilesSkipped']}\n
            Data Transferred: {bytes_transferred / 1024:.2f} KB\n
            Data Throughput: {data_throughput:.2f} KiB/s
        """)
    elif status == 'ERROR':
        subject = f"{task['Name']} Failed"
        message = dedent(f"""
            Task Name: {task['Name']}
            Source Location: {task['SourceLocationArn']}
            Destination Location: {task['DestinationLocationArn']}
            Start Time: {start_time_local}
            Error Code: {execution_status['Result'].get('ErrorCode', 'N/A')}
            Error Details: {execution_status['Result'].get('ErrorDetail', 'N/A')}
        """)
    else:
        logger.info("No notification sent for status: %s", status)
        return {'statusCode': 200, 'body': f"No notification sent for status: {status}"}

    # Publish message to SNS topic
    try:
        sns_client.publish(TopicArn=topic_arn, Subject=subject, Message=message)
        logger.info("Message published to SNS topic: %s", topic_arn)
    except sns_client.exceptions.NotFoundException:
        logger.error("SNS topic not found: %s", topic_arn)
        return {'statusCode': 404, 'body': f"SNS topic not found: {topic_arn}"}
    except Exception as e:
        logger.error("Error publishing to SNS: %s", str(e))
        return {'statusCode': 500, 'body': f"Error: {str(e)}"}

    return {'statusCode': 200, 'body': 'Message sent successfully'}
