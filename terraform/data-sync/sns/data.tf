#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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

# policy for lambda function to execute the datasync task

data "aws_iam_policy_document" "assume_lambda_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_to_datasync_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "datasync:DescribeTask",
      "datasync:DescribeTaskExecution",
      "datasync:ListLocations",
      "datasync:DescribeLocation*"
    ]
#    resources = ["*"]
    #resources = ["arn:aws:datasync:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/*"]
    resources = ["arn:aws:datasync:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.datasync_status_topic.arn]
  }
}

# add this for lambda function
data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "index.py" 
  output_path = "lambda_function_payload.zip"
}
