#create sns topic
resource "aws_sns_topic" "datasync_status_topic" {
  name = var.datasync_status_topic
}

# create subscription
resource "aws_sns_topic_subscription" "datasync_status_subscription" {
  for_each = toset(var.emails)
  topic_arn = aws_sns_topic.datasync_status_topic.arn
  protocol  = "email"
  endpoint  = each.value
#  endpoint  = "tracy.truong@nih.gov"
}

#make sure policy permissiona are correct in the sns topic
resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn = aws_sns_topic.datasync_status_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action   = "sns:Publish",
        Resource = aws_sns_topic.datasync_status_topic.arn
      }
    ]
  })
}

#this is to use the AWS default templat -  create evenbridge rule - dont use this rule
#resource "aws_cloudwatch_event_rule" "datasync_status_rule" {
#  name        = var.datasync_status_rule
#  description = "Rule to monitor DataSync task execution status changes"
#  event_pattern = jsonencode({
#    "source": ["aws.datasync"],
#    "detail-type": ["DataSync Task Execution State Change"],
#    "detail": {
#      "State": ["SUCCESS", "ERROR"]
#    }
#  })
#}

# this is to use the AWS default template - add an eventbridge target - we are not using this template at the moment
#resource "aws_cloudwatch_event_target" "datasync_status_target" {
#  rule      = aws_cloudwatch_event_rule.datasync_status_rule.name
#  arn       = aws_sns_topic.datasync_status_topic.arn
##  role_arn = aws_iam_role.eventbridge-role.arn
## add custom email message
#  input_transformer {
#    input_paths = {
#      version = "$.version"
#      id = "$.id"
#      detail-type = "$.detail-type"
#      source = "$.source"
#      account = "$.account"
#      time  =  "$.time"
#      region = "$.region"
#      resource = "$.resources[0]"
#      state  = "$.detail.State"
#    }
##    input_template = "\"The DataSync task <executionArn> ended at <time> in the state <state>\""
#    input_template = <<EOF
#      {
#        "version": <version>,
#        "id": <id>,
#        "detail-type": <detail-type>,
#        "source": <source>,
#        "account": <account>,
#        "time": <time>,
#        "region": <region>,
#        "resources": <resource>,
#        "details": <state>
#      }
#      EOF  

#  }
#}

# create another rule to use lambda function

resource "aws_cloudwatch_event_rule" "lambda_datasync_status_rule" {
  name        = var.lambda_datasync_status_rule
  description = "Rule to monitor DataSync task execution status changes used by lambda function"
  event_pattern = jsonencode({
    "source": ["aws.datasync"],
    "detail-type": ["DataSync Task Execution State Change"],
    "detail": {
      "State": ["SUCCESS", "ERROR"]
    }
  })
}

# create the lambda function which publishes updates about DataSync task execution status
resource "aws_lambda_function" "datasync_task_notifications_lambda" {
  function_name    = "DataSyncTaskNotificationsLambda"
  role             = aws_iam_role.lambda-role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  memory_size      = 256
  timeout          = 900
  filename         = "lambda_function_payload.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.datasync_status_topic.arn
    }
  }
}

# create event target and add lambda function as a target
resource "aws_cloudwatch_event_target" "lambda_datasync_status_target" {
  rule   =  aws_cloudwatch_event_rule.lambda_datasync_status_rule.name
  arn    = aws_lambda_function.datasync_task_notifications_lambda.arn
}


# Grant Permission for the Event Rule to Invoke the Lambda Function
resource "aws_lambda_permission" "allow_eventbridge_to_invoke_lambda" {
  statement_id  = "AllowCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.datasync_task_notifications_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_datasync_status_rule.arn
}
