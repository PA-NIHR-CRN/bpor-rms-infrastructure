resource "aws_iam_role" "api_gateway_role" {
  count = var.env == "dev" ? 1 : 0
  name  = "${var.account}-iam-${var.env}-${var.system}-${var.app}-api-gateway-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com", "events.amazonaws.com", "lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  tags = {
    Name        = "${var.account}-iam-${var.env}-${var.system}-${var.app}-api-gateway-role",
    Environment = var.env,
    System      = var.system
  }
}

resource "aws_api_gateway_account" "iam_apigateway_account" {
  count               = var.env == "dev" ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.api_gateway_role[0].arn
  lifecycle {
    ignore_changes = [
      cloudwatch_role_arn
    ]
  }
}

resource "aws_iam_role_policy" "apigateway-role-policy" {
  count = var.env == "dev" ? 1 : 0
  name  = "${var.account}-iam-${var.env}-${var.system}-${var.app}-api-gateway-role-policy"
  role  = aws_iam_role.api_gateway_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "events:PutRule",
          "events:ListRules",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "sqs:SendMessage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_api_gateway_rest_api" "main" {
  count       = var.env == "dev" ? 1 : 0
  name        = "${var.account}-api-gateway-${var.env}-${var.system}-${var.app}"
  description = "${var.system}-${var.app} API Gateway."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    Name        = "${var.account}-api-gateway-${var.env}-${var.system}-${var.app}"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_api_gateway_resource" "main" {
  count       = var.env == "dev" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  parent_id   = aws_api_gateway_rest_api.main[0].root_resource_id
  path_part   = "{proxy+}"
}

//resource path

# # Define the API Gateway resource for /api/v1/home
# resource "aws_api_gateway_resource" "home_resource" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   parent_id   = aws_api_gateway_rest_api.main.root_resource_id
#   path_part   = "api"
# }

# resource "aws_api_gateway_resource" "v1_resource" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   parent_id   = aws_api_gateway_resource.home_resource.id
#   path_part   = "v1"
# }

# resource "aws_api_gateway_resource" "home_path_resource" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   parent_id   = aws_api_gateway_resource.v1_resource.id
#   path_part   = "home"
# }

# # Define the API Gateway resource for /api/v1/home/authenticated
# resource "aws_api_gateway_resource" "authenticated_resource" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   parent_id   = aws_api_gateway_resource.home_path_resource.id
#   path_part   = "authenticated"
# }

# // method

# resource "aws_api_gateway_method" "home_method" {
#   rest_api_id   = aws_api_gateway_rest_api.main.id
#   resource_id   = aws_api_gateway_resource.home_path_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }


# resource "aws_api_gateway_method" "authenticated_method" {
#   rest_api_id   = aws_api_gateway_rest_api.main.id
#   resource_id   = aws_api_gateway_resource.authenticated_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

resource "aws_api_gateway_method" "main" {
  count         = var.env == "dev" ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.main[0].id
  resource_id   = aws_api_gateway_resource.main[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "main" {
  count       = var.env == "dev" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.main[0].http_method
  # method that the api gateway will use to call the lambda - lambdas can only be invoked by POST, even though the gateway method may be a GET
  type                    = "AWS_PROXY"
  uri                     = var.invoke_lambda_arn
  integration_http_method = "POST"
}


resource "aws_api_gateway_method_response" "main" {
  count       = var.env == "dev" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.main[0].http_method
  status_code = "200"
  depends_on = [
    aws_api_gateway_method.main[0],
  ]
}

resource "aws_api_gateway_method_settings" "main" {
  count       = var.env == "dev" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  stage_name  = var.env
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}


resource "aws_api_gateway_integration_response" "main" {
  count       = var.env == "dev" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.main[0].http_method
  status_code = aws_api_gateway_method_response.main[0].status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_integration.main[0],
    aws_api_gateway_method_response.main[0],
  ]
}

resource "aws_api_gateway_deployment" "main" {
  count       = var.env == "dev" ? 1 : 0
  depends_on  = [aws_api_gateway_integration.main[0]]
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  stage_name  = var.env
}

//lambda invoker
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_lambda_permission" "main" {
  count         = var.env == "dev" ? 1 : 0
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  qualifier     = var.function_alias_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.main[0].id}/*"
}