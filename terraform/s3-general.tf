resource "aws_s3_bucket" "s3" {
  for_each = var.bucketname
  bucket        = each.value
#  force_destroy = var.s3_force_destroy
  tags = var.s3_tags
}

#resource "aws_s3_bucket_ownership_controls" "s3" {
#  bucket = aws_s3_bucket.s3.id
#  rule {
#    object_ownership = var.object_ownership
#  }
#}
#resource "aws_s3_bucket_acl" "s3" {
#  bucket = aws_s3_bucket.s3.id
#  acl    = "private"
#}

resource "aws_s3_bucket_public_access_block" "s3" {
  for_each = var.bucketname
  bucket                  = aws_s3_bucket.s3[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3" {
  for_each = var.bucketname
  bucket = aws_s3_bucket.s3[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3" {
  for_each = var.bucketname
  bucket = aws_s3_bucket.s3[each.key].id
  versioning_configuration {
    status = each.value.versioning
  }
}
#resource "aws_s3_bucket_notification" "s3" {
#  for_each = var.bucketname
#  bucket      = aws_s3_bucket.s3[each.key].id
#  eventbridge = each.value.eventbridge
#}
