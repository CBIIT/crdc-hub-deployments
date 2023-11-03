resource "aws_s3_bucket" "s3_submission" {
  bucket        = "${local.resource_prefix}-submission"
#  force_destroy = var.s3_force_destroy
  tags = var.s3_tags
}


resource "aws_s3_bucket_public_access_block" "s3_submission" {
  bucket                  = aws_s3_bucket.s3_submission.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_submission" {
  bucket = aws_s3_bucket.s3_submission.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_versioning" "s3_submission" {
  bucket = aws_s3_bucket.s3_submission.id

  versioning_configuration {
    status = var.s3_versioning_status
  }
}


resource "aws_s3_bucket_cors_configuration" "s3_submission" {
  bucket = aws_s3_bucket.s3_submission.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [ 
      "GET",
      "POST",
      "HEAD",
      "PUT"
    ]
    allowed_origins = [
      "*.cancer.gov",
      "*.cloudfront.net",
      "*.datacommons.cancer.gov",
      "http://localhost:4010"
    ]
    expose_headers  = [
      "ETag",
      "Content-Range",
      "Content-Length",
    ]
    max_age_seconds = 3000
  }
}

data "aws_iam_role" "role" {
  name = local.iam_role_name
  depends_on = [module.ecs]
}


data "aws_iam_role" "task_role" {
  name = local.task_role_name
  depends_on = [module.ecs]
}

data "aws_iam_policy_document" "task_execution_s3" {
  statement {
    sid     = "AllowBucketAccess"
    effect  = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.s3_submission.arn,
    ]
  }
  statement {
    sid     = "AllowObjectAccess"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "${local.submission_bucket_arn}/*",
      local.submission_bucket_arn
    ]
  }
}

resource "aws_iam_policy" "extra_s3_policy" {
  name    = "power-user-${var.tier}-iam-extra-s3-policy"
  policy = data.aws_iam_policy_document.task_execution_s3.json
}

#attach the iam policy to the iam role
resource "aws_iam_policy_attachment" "attach" {
  name = "iam-policy-attach"
  roles = [data.aws_iam_role.role.name,data.aws_iam_role.task_role.name]
  policy_arn = aws_iam_policy.extra_s3_policy.arn
}

