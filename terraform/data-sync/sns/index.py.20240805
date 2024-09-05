import json
import re
from os import getenv
from textwrap import dedent
from pprint import pformat
from boto3 import client
 
 
datasync_client = client("datasync")
sns_client = client("sns")
 
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
 
 
def lambda_handler(event, context):
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
 
    print(task)
    print(execution_status)
    print(source_location)
    print(destination_location)
 
    status = execution_status['Status']
 
    if status == 'SUCCESS':
        subject = "DataSync Task Execution Succeeded"
        message = dedent(f"""\
            The DataSync task execution with ARN {task_execution_arn} has completed successfully.
            Task Name: {task['Name']}
            Source Location: {source_location['LocationUri']}
            Destination Location: {destination_location['LocationUri']}
            Start Time: {execution_status['StartTime']}
            Transfer Duration: {execution_status['Result']['TransferDuration']} seconds
            Files Transferred: {execution_status['FilesTransferred']}""")
    elif status == 'ERROR':
        subject = "DataSync Task Execution Failed"
        message = dedent(f"""\
            The DataSync task execution with ARN {task_execution_arn} has failed.
            Task Name: {task['Name']}
            Source Location: {source_location['LocationUri']}
            Destination Location: {destination_location['LocationUri']}
            Start Time: {execution_status['StartTime']}
            Transfer Duration: {execution_status['Result']['TransferDuration']} seconds
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
        TopicArn=getenv('SNS_TOPIC_ARN'),
        Subject=subject,
        Message=message
    )
