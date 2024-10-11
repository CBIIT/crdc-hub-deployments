#creat sqs queue that will receive messages from eventbridge
resource "aws_sqs_queue" "ecs_troubleshoot_sqs_queue" {
  name = var.troubleshoot_sqs_name
}

# Create a Policy that allows EventBridge to send messages to the SQS Queue
resource "aws_sqs_queue_policy" "ecs_troubleshooting_queue_policy" {
  queue_url = aws_sqs_queue.ecs_troubleshoot_sqs_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.ecs_troubleshoot_sqs_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.scheduled_rule.arn
          }
        }
      }
    ]
  })
}
