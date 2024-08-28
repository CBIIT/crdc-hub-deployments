import json
from os import getenv
from textwrap import dedent
from boto3 import client
from datetime import timedelta
          
datasync_client = client("datasync")
sns_client = client("sns")

def lambda_handler(event, context):
    task_execution_arn = event['resources'][0]

    execution_status = datasync_client.describe_task_execution(
       TaskExecutionArn=task_execution_arn
    )

    print(event)
    print(execution_status)

    status = execution_status['Status']
    
    if status == 'SUCCESS':
        subject = "DataSync Task Execution Succeeded"
        message = f"The DataSync task execution with ARN {task_execution_arn} has completed successfully."
    elif status == 'ERROR':
        subject = "DataSync Task Execution Failed"
        message = f"The DataSync task execution with ARN {task_execution_arn} has failed."
    else:
        # If the status is not SUCCESS or ERROR, don't send a notification
        return {
            'statusCode': 200,
            'body': f"No notification sent for status: {status}"
        }

    # Send the notification to the SNS topic
    sns_client.publish(
        TopicArn=os.environ['SNS_TOPIC_ARN'],
        Subject=subject,
        Message=message
    )

    return {
        'statusCode': 200,
        'body': f"Notification sent for status: {status}"
    }
