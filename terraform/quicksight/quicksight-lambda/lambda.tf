# Athena Data Source
resource "aws_athena_data_catalog" "mongodb_catalog" {
  name            = var.mongodb_catalog_name
  type            = "LAMBDA"
  description     = "MongoDB data catalog for Athena"
  lambda_function = var.lambda-funtions
}
