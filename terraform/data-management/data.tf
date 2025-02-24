#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#policy for s3 for the datasync task

data "aws_iam_policy_document" "s3_data_sync_policy" {
  statement {
    sid  = "DataSyncCreateS3LocationAndTaskAccess"
    effect = "Allow"
    principals {
      type = "AWS"
    #  identifiers = ["arn:aws:iam::${var.source-account}:role/datasync-iam-role"]
      identifiers   = [local.trusted_role_arn]
    }
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::${var.datasync-destination-bucket-name}",
      "arn:aws:s3:::${var.datasync-destination-bucket-name}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_task_exec_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers   = [local.task_exec_role_arn]
    }
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::${var.datasync-destination-bucket-name}",
      "arn:aws:s3:::${var.datasync-destination-bucket-name}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_task_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers   = [local.task_role_arn]
    }
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::${var.datasync-destination-bucket-name}",
      "arn:aws:s3:::${var.datasync-destination-bucket-name}/*"
    ]
  }
}
