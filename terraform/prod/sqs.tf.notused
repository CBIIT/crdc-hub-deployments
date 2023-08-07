resource "aws_sqs_queue" "sqs_queue" {
  name                      = "${local.resource_prefix}-queue.fifo"
  fifo_queue                = true
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 604800 
  visibility_timeout_seconds = 300
  receive_wait_time_seconds = 20
  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.dead_letter_queue.arn}",
  "maxReceiveCount": 5
}
EOF
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name                      = "${local.resource_prefix}-dead-letter-queue.fifo"
  fifo_queue                = true
}

