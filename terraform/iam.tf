locals {
  env = regex("^(.*?)(2+)?$", terraform.workspace) != null ? regex("^(.*?)(2+)?$", terraform.workspace)[0] : terraform.workspace
  submission_bucket_arn = "arn:aws:s3:::crdc-hub-${local.env}-submission"
  permission_boundary_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser"
}
module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  role_permissions_boundary_arn = local.permission_boundary_arn
  custom_role_trust_policy        = data.aws_iam_policy_document.custom_trust_policy.json
  create_role = true
  role_name = "power-user-crdc-hub-${terraform.workspace}-submission-role"
  create_custom_role_trust_policy = true
  custom_role_policy_arns = [
    module.iam_policy_s3.arn
  ]
}

data "aws_iam_policy_document" "custom_trust_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:GetSessionToken",
      "sts:GetAccessKeyInfo"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/power-user-crdc-hub-${terraform.workspace}-ecs-task-execution-role",
      ]
    }
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com"
      ]
    }
  }
}
data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "${local.submission_bucket_arn}/*",
      local.submission_bucket_arn
    ]
  }
}
module "iam_policy_s3" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name        = "power-user-crdc-hub-${terraform.workspace}-submission-policy"
  path        = "/"
  description = "s3 submission policy"
  policy = data.aws_iam_policy_document.s3.json
}