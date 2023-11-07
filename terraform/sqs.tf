resource "aws_sqs_queue" "sqs_queues" {
  count = terraform.workspace == "dev" || terraform.workspace == "qa" ? 1 : 0
  for_each = var.sqs_queues
  name    = each.value.name
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
  count = terraform.workspace == "dev" || terraform.workspace == "qa" ? 1 : 0
  for_each = var.sqs_queues
  name = each.value.dead_letter_queue_name
  fifo_queue                = true
}

