import json
import re
from os import getenv, environ
from textwrap import dedent
from pprint import pformat
from boto3 import client
from datetime import datetime, timezone
from zoneinfo import ZoneInfo


datasync_client = client("datasync")
sns_client = client("sns")
sts_client = client('sts')

AWS_ACCOUNT_ID = sts_client.get_caller_identity()["Account"]
AWS_REGION = getenv('AWS_REGION')

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
    print(event)
    
    task_execution_arn = event['resources'][0]
    task_arn = re.sub(r'/execution/.*$', '', task_execution_arn)
    locations = get_locations(datasync_client)
    

    task = datasync_client.describe_task(
        TaskArn=task_arn
    )
    
    execution_status = datasync_client.describe_task_execution(
       TaskExecutionArn=task_execution_arn
    )
    
    source_location = describe_location(task['SourceLocationArn'], locations, datasync_client)
    destination_location = describe_location(task['DestinationLocationArn'], locations, datasync_client)

    list_tags = datasync_client.list_tags_for_resource(ResourceArn=task_arn)
    # tier = [item['Value'] for item in list_tags['Tags'] if item['Key'] == 'Tier'][0]
    # type = [item['Value'] for item in list_tags['Tags'] if item['Key'] == 'Type'][0]
    
    tier = "dev"
    type = "metadata"

    
    # add this before we have tags to test
    if "dev2" in source_location['LocationUri']:
        tier = "dev2"
    if "qa" in source_location['LocationUri']:
        tier = "qa"
    if "qa2" in source_location['LocationUri']:
        tier = "qa2"
    if "stage" in source_location['LocationUri']:
        tier = "stage"
    if "prod" in source_location['LocationUri']:
        tier = "prod"
    
    topic_arn = f"arn:aws:sns:{AWS_REGION}:{AWS_ACCOUNT_ID}:datasync-status-topic-{tier}"
    tier_description = "" if tier == "prod" else f"Tier: {tier}\n"

    print(task)
    print(execution_status)
    print(source_location)
    print(destination_location)

    status = execution_status['Status']

    start_time_utc = execution_status['StartTime']
    
    # Convert StartTime from UTC to local time
    start_time_local = utc_to_local(start_time_utc, 'America/New_York')  # Replace with your desired timezone
    # Convert transfer duration from seconds to minutes and seconds
    duration_seconds = execution_status['Result']['TransferDuration'] / 1000
    duration_minutes = duration_seconds // 60
    remaining_seconds = duration_seconds % 60
    # calculate data throughput
    bytes_transferred = execution_status['BytesTransferred']
    data_throughput = bytes_transferred / duration_seconds / 1024

    if status == 'SUCCESS':
        subject = f"{task['Name']} Succeeded"
        message = dedent(f"""\
            The DataSync task execution with ARN {task_execution_arn} has completed successfully.\n
            Task Name: {task['Name']}\n
            {tier_description}
            Status: {execution_status['Status']}\n
            Source Location: {source_location['LocationUri']}\n
            Destination Location: {destination_location['LocationUri']}\n
            Start Time: {start_time_local}\n
            Transfer Duration: {duration_seconds} seconds\n
            Files Transferred: {execution_status['FilesTransferred']}\n
            Files Skipped: {execution_status['FilesSkipped']}\n
            Data Transferred: {execution_status['BytesTransferred'] / 1024} kBs\n
            Data Throughput: {data_throughput} kib/seconds""")
    elif status == 'ERROR':

        subject = f"{task['Name']} Failed"
        message = dedent(f"""\
            The DataSync task execution with ARN {task_execution_arn} has failed.\n
            Task Name: {task['Name']}\n
            Source Location: {source_location['LocationUri']}\n
            Destination Location: {destination_location['LocationUri']}\n
            Start Time: {start_time_local}\n
            Total Duration: {duration_seconds} seconds\n
            Files Transferred: {execution_status['FilesTransferred']}
            
            Error Code: {execution_status["Result"]["ErrorCode"]}
            Error Details: {execution_status["Result"]["ErrorDetail"]}""")
    else:
    # If the status is not SUCCESS or ERROR, don't send a notification
        return {
            'statusCode': 200,
            'body': f"No notification sent for status: {status}"
        }

    # Send the notification to the SNS topic
    return sns_client.publish(
        TopicArn=topic_arn,
        Subject=subject,
        Message=message
    )
