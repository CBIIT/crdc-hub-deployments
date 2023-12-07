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

data "aws_iam_role" "task_role" {
  name = local.task_role_name
  depends_on = [module.ecs]
}

module "iam_policy_sqs" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name        = "power-user-crdc-hub-${terraform.workspace}-sqs-policy"
  description = "sqs submission policy"
  policy = data.aws_iam_policy_document.task_execution_sqs.json
}

resource "aws_iam_policy_attachment" "sqs_attach" {
  name = "iam-policy-attach-sqs"
  roles = [data.aws_iam_role.task_role.name,data.aws_iam_role.task_role.name]
  policy_arn = module.iam_policy_sqs.arn
}
