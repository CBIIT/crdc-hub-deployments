#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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
      version = "$.version"
      id = "$.id"
      detail-type = "$.detail-type"
      source = "$.source"
      account = "$.account"
      time  =  "$.time"
      region = "$.region"
      resource = "$.resources[0]"
      state  = "$.detail.State"
    }
#    input_template = "\"The DataSync task <executionArn> ended at <time> in the state <state>\""
    input_template = <<EOF
      {
        "version": <version>,
        "id": <id>,
        "detail-type": <detail-type>,
        "source": <source>,
        "account": <account>,
        "time": <time>,
        "region": <region>,
        "resources": <resource>,
        "details": <state>
      }
      EOF  

  }
}

# policy for eventbridge to SNS
data "aws_iam_policy_document" "assume_role_sns_policy" {
  statement {
  actions = ["sts:AssumeRole"]
  principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eventbridge_to_sns_policy" {
  statement {
    effect = "Allow"
    actions = ["sns:Publish"]
    resources = [aws_sns_topic.datasync_status_topic.arn]
  }
}

# create an IAM role for eventbridge
resource "aws_iam_role" "eventbridge-role" {
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.assume_role_sns_policy.json
  name = "power-user-eventbridge-iam-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

#create iam policy for the eventbridge iam-role
resource "aws_iam_policy" "eventbridge-policy" {
  name = "power-user-eventbridge-policy"
  policy = data.aws_iam_policy_document.eventbridge_to_sns_policy.json
}

#attach policies to the datasync iam role
resource "aws_iam_role_policy_attachment" "eventbridge_attach" {
#  name       = "power-user-${terraform.workspace}-datasync-attachment"
  role = aws_iam_role.eventbridge-role.name
  policy_arn = aws_iam_policy.eventbridge-policy.arn
}
