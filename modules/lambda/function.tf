resource "aws_security_group" "sg_lambda" {
  count       = var.env == "dev" ? 1 : 0
  name        = "${var.account}-sg-lambda-${var.env}-${var.system}-${var.app}"
  description = "lambda security group"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.account}-sg-lambda-${var.env}-${var.system}-${var.app}"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lambda_function" "callback_forwarder_lambda" {
  count         = var.env == "dev" ? 1 : 0
  function_name = "${var.account}-lambda-${var.env}-${var.system}-${var.app}"
  memory_size   = var.memory_size
  timeout       = 120
  handler       = "BPOR::BPOR.Callback.Function::FunctionHandlerAsync"
  filename      = "./modules/.build/lambda_dummy/lambda_dummy.zip"
  role          = aws_iam_role.lambda.arn
  runtime       = "dotnet6"
  description   = "reverse proxy for callback url"

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.sg_lambda[0].id]
  }

  environment {
    variables = {

    }
  }

  lifecycle {
    ignore_changes = [
      # version,
      qualified_arn,
      memory_size,
      # environment
    ]
  }
  tags = {
    Name        = "${var.account}-lambda-${var.env}-${var.system}-${var.app}"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lambda_alias" "callback_forwarder" {
  count            = var.env == "dev" ? 1 : 0
  name             = "main"
  function_name    = aws_lambda_function.callback_forwarder_lambda[0].function_name
  function_version = aws_lambda_function.callback_forwarder_lambda[0].version
}

# lambda logging
resource "aws_cloudwatch_log_group" "callback_forwarder_log_group" {
  count             = var.env == "dev" ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.callback_forwarder_lambda[0].function_name}"
  retention_in_days = var.retention_in_days
  tags = {
    Name        = "${var.account}-lambda-${var.env}-${var.system}-${var.app}"
    Environment = var.env
    System      = var.system
  }
}

output "lambda_sg" {
  value = aws_security_group.sg_lambda[0].id
}

output "callback_forwarder_invoke_alias_arn" {
  value = aws_lambda_alias.callback_forwarder[0].invoke_arn
}

output "function_name" {
  value = aws_lambda_function.callback_forwarder_lambda[0].function_name
}

output "alias_name" {
  value = aws_lambda_alias.callback_forwarder[0].name
}