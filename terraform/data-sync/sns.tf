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

# create evenbridge rule
resource "aws_cloudwatch_event_rule" "datasync_status_rule" {
  name        = var.datasync_status_rule
  description = "Rule to monitor DataSync task execution status changes"
  event_pattern = jsonencode({
    "source": ["aws.datasync"],
    "detail-type": ["DataSync Task Execution State Change"],
    "detail": {
      "State": ["SUCCESS", "ERROR"]
    }
  })
}

# add an eventbridge target
resource "aws_cloudwatch_event_target" "datasync_status_target" {
  rule      = aws_cloudwatch_event_rule.datasync_status_rule.name
  arn       = aws_sns_topic.datasync_status_topic.arn
#  role_arn = aws_iam_role.eventbridge-role.arn
# add custom email message
  input_transformer {
    input_paths = {
      time  =  "$.time"
      executionArn = "$.detail.executionArn"
      state  = "$.detail.State"
    }
    input_template = "\"The DataSync task <executionArn> ended at <time> in the state <state>\""
  }
}
