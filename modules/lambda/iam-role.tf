data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "lambda" {
  name               = "${var.account}-iam-${var.env}-${var.system}-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
				"Service": [
				    "lambda.amazonaws.com",
				    "events.amazonaws.com"
			    ]
      },
      "Action": "sts:AssumeRole",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name        = "${var.account}-iam-${var.env}-${var.system}-lambda-role"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = aws_iam_policy.lambda.arn
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_policy" "lambda" {
  name   = "${var.account}-iam-${var.env}-${var.system}-lambda-role-policy"
  policy = data.aws_iam_policy_document.lambda.json
  tags = {
    Name        = "${var.account}-iam-${var.env}-${var.system}-lambda-role-policy"
    Environment = var.env
    System      = var.system
  }
}

data "aws_iam_policy_document" "lambda" {

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    actions = [
      "logs:CreateLogGroup",
    ]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
  }

  statement {
    sid    = "CognitoIdenitity"
    effect = "Allow"
    actions = [
      "cognito-identity:*",
      "cognito-idp:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCreateDeleteNetworkInterface"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RDS"
    effect = "Allow"
    actions = [
      "rds:Describe*",
      "rds-data:ExecuteStatement"
    ]
    resources = ["arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    sid    = "GetSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    sid    = "ListSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

  # statement {
  #   sid    = "Allowses"
  #   effect = "Allow"
  #   actions = [
  #     "ses:SendEmail",
  #     "ses:SendRawEmail",
  #   ]
  #   resources = ["*"]
  # }

  # statement {
  #   sid    = "Allowssm"
  #   effect = "Allow"
  #   actions = [
  #     "ssm:PutParameter",
  #     "ssm:GetParametersByPath",
  #   ]
  #   resources = ["*"]
  # }

  statement {
    sid    = "S3ListAllMyBuckets"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }

}