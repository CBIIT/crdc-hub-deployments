#create iam policy to allow BE service to generate embedded URLs for Quicksight dashboard
resource "aws_iam_policy" "quicksight-embed-policy" {
  name = "power-user-quicksight-embed-policy"
  policy = data.aws_iam_policy_document.quicksight_embed_policy.json
}

#attach the BE policy to the task and execute role (multiple roles)
resource "aws_iam_policy_attachment" "quicksight-embed-task-access" {
  name = "quicksight-embed-policy-attach"
  roles = [data.aws_iam_role.quicksight_task_role.name,data.aws_iam_role.quicksight_task_execution_role.name]
  policy_arn = aws_iam_policy.quicksight-embed-policy.arn
}

