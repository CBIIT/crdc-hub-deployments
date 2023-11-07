resource "aws_sqs_queue" "sqs_queues" {
  for_each = var.sqs_queues
  name    = "${local.resource_prefix}-${each.value.queue}-queue.fifo"
  fifo_queue                = true
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 604800 
  visibility_timeout_seconds = 300
  receive_wait_time_seconds = 20
  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.dead_letter_queue[each.key].arn}",
  "maxReceiveCount": 5
}
EOF
}

resource "aws_sqs_queue" "dead_letter_queue" {
  for_each = var.sqs_queues
  name = "${local.resource_prefix}-${each.value.dead_letter_queue_name}-queue.fifo"
  fifo_queue                = true
}

