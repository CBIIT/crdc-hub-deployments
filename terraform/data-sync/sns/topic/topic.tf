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
