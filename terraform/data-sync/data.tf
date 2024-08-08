#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#policy for datasync task

data "aws_iam_policy_document" "datasync-policy" {
  statement {
    sid  = "AllowDataSync"
    effect = "Allow"
    actions   = [
      "datasync:CreateLocationS3",
      "datasync:CreateTask",
      "datasync:DescribeLocation*",
      "datasync:DescribeTaskExecution",
      "datasync:ListLocations",
      "datasync:ListTaskExecutions",
      "datasync:DescribeTask",
      "datasync:CancelTaskExecution",
      "datasync:ListTasks",
      "datasync:StartTaskExecution",
      "iam:CreateRole",
      "iam:CreatePolicy",
      "iam:AttachRolePolicy",
      "iam:ListRoles",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListObjectsV2",
      "s3:GetObject",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    sid = "PassIAMRole"
    actions = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["datasync.amazonaws.com"]
      variable = "iam:PassedToService"
    }
  }
}

# policy for datasync access
data "aws_iam_policy_document" "datasync-s3-access" {
  statement {
    effect = "Allow"
    sid = "AllowListBucket"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListObjectsV2",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      #"arn:aws:s3:::${var.datasync-destination-bucket-name}"
      for datasync-destination-bucket-name in var.datasync-destination-bucket-names : "arn:aws:s3:::${datasync-destination-bucket-name}"
    ]
  }
  statement {
    effect = "Allow"
    sid = "AllowUploads"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectTagging",
      "s3:ListObjectsV2",
      "s3:ListBucket",
      "s3:PutObjectTagging"
    ]
    resources = [
      #"arn:aws:s3:::${var.datasync-destination-bucket-name}/*"
      for datasync-destination-bucket-name in var.datasync-destination-bucket-names : "arn:aws:s3:::${datasync-destination-bucket-name}/*"
    ]
  }
}


# policy for the assume role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

# name of execute ECS role
data "aws_iam_role" "datasync_task_role" {
  name = local.datasync_task_role_name
}

data "aws_iam_role" "datasync_task_execution_role" {
  name = local.datasync_task_execution_role_name
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
