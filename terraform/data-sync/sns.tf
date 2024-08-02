#create sns topic
resource "aws_sns_topic" "datasync_status_topic" {
  name = "datasync_status_topic"
}

# create subscription
resource "aws_sns_topic_subscription" "datasync_status_subscription" {
  topic_arn = aws_sns_topic.datasync_status_topic.arn
  protocol  = "email"
  endpoint  = "tracy.truong@nih.gov"
}

# create evenbridge rule
resource "aws_cloudwatch_event_rule" "datasync_status_rule" {
  name        = "datasync_status_rule"
  description = "Rule to monitor DataSync task execution status changes"
  event_pattern = jsonencode({
    "source": ["aws.datasync"],
    "detail-type": ["DataSync Task Execution State Change"],
    "detail": {
      "state": ["SUCCESS", "ERROR"]
    }
  })
}

# add an eventbridge target
resource "aws_cloudwatch_event_target" "datasync_status_target" {
  rule      = aws_cloudwatch_event_rule.datasync_status_rule.name
  arn       = aws_sns_topic.datasync_status_topic.arn
# add custom email message
  input_transformer {
    input_paths = {
      state  = "$.detail.state"
    }
    input_template = "\"Sync task is in state <state>\""
  }
}
