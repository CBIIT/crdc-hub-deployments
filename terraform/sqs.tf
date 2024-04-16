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
  tags = var.sqs_tags
}

resource "aws_sqs_queue" "dead_letter_queue" {
  for_each = var.sqs_queues
  name = "${local.resource_prefix}-${each.value.dead_letter_queue_name}-queue.fifo"
  fifo_queue                = true
}

#added role to the sqs
data "aws_iam_role" "sqs_role" {
  name = local.iam_role_name
  depends_on = [module.ecs]
}


data "aws_iam_role" "sqs_task_role" {
  name = local.task_role_name
  depends_on = [module.ecs]
}

data "aws_iam_policy_document" "task_execution_sqs" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:*"
    ]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_policy" "sqs_policy" {
  name    = "power-user-${var.tier}-iam-sqs-policy"
  policy = data.aws_iam_policy_document.task_execution_sqs.json
}

#attach the iam policy to the iam role
resource "aws_iam_policy_attachment" "attach_sqs" {
  name = "iam-sqs-policy-attach"
  roles = [data.aws_iam_role.sqs_role.name,data.aws_iam_role.sqs_task_role.name]
  policy_arn = aws_iam_policy.sqs_policy.arn
}
