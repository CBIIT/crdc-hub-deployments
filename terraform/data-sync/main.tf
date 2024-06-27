# create log group
resource "aws_cloudwatch_log_group" "datasync_log_group" {
  name = "/aws/datasync/${terraform.workspace}-datasync-log"
}

# Create DataSync location for source S3 bucket
resource "aws_datasync_location_s3" "source" {
  s3_bucket_arn = local.source_bucket_arn
#  region = var.region
  subdirectory  = "/"
  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync-iam-role.arn
  }
}

# create DataSync location for destination
resource "aws_datasync_location_s3" "destination" {
  s3_bucket_arn = local.destination_bucket_arn
#  region = var.region
  subdirectory  = "/"
  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync-s3-access-role.arn
  }
}

# Create DataSync task
resource "aws_datasync_task" "s3_to_s3" {
  name     = "datasync-task"
  source_location_arn      = aws_datasync_location_s3.source.arn
  destination_location_arn = aws_datasync_location_s3.destination.arn
  cloudwatch_log_group_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.datasync_log_group.name}"

  options {
    verify_mode = "ONLY_FILES_TRANSFERRED"
    posix_permissions              = "NONE"
    uid   = "NONE"
    gid   = "NONE"
  }
  tags  = var.datasync_tags
}
