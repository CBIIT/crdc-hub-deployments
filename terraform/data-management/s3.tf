resource "aws_s3_bucket" "s3_data_management" {
  bucket        = var.bucket_name
#  force_destroy = var.s3_force_destroy
  tags = var.s3_tags
}


#resource "aws_s3_bucket_public_access_block" "s3_data_management" {
#  bucket                  = aws_s3_bucket.s3_data_management.id
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}

#resource "aws_s3_bucket_server_side_encryption_configuration" "s3_data_management" {
#  bucket = aws_s3_bucket.s3_data_management.id

#  rule {
#    apply_server_side_encryption_by_default {
#      sse_algorithm = "AES256"
#    }
#  }
#}


#resource "aws_s3_bucket_versioning" "s3_data_management" {
#  bucket = aws_s3_bucket.s3_data_management.id
#
#  versioning_configuration {
#    status = var.s3_versioning_status
#  }
#}
