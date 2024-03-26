resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.account}-ecs-${var.env}-${var.resource_identifier}-cluster"

  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.resource_identifier}-cluster",
    Environment = var.env,
    System      = var.system,
    Component   = var.app
  }
}

resource "aws_cloudwatch_log_group" "ecs-cloudwatchloggroup" {
  name              = "${var.account}-ecs-${var.env}-${var.resource_identifier}-loggroup"
  retention_in_days = "30"

  tags = {
    Name        = "${var.account}-ecs-cloudwatch-${var.env}-${var.resource_identifier}-loggroup",
    Environment = var.env,
    System      = var.system,
    Component   = var.app
  }
}


resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.account}-ecs-${var.env}-${var.resource_identifier}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.iam-ecs-task-role.arn
  task_role_arn            = aws_iam_role.iam-ecs-task-role.arn
  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.image_url
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 3000
      hostPort      = 3000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs-cloudwatchloggroup.id
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.resource_identifier}-task-definition",
    Environment = var.env,
    System      = var.system,
    Component   = var.app
  }
}

resource "aws_security_group" "sg-ecs" {
  name        = "${var.account}-sg-${var.env}-ecs-${var.resource_identifier}"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-lb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.account}-sg-${var.env}-ecs-${var.resource_identifier}",
    Environment = var.env,
    System      = var.system,
    Component   = var.app
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.account}-ecs-${var.env}-${var.resource_identifier}-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = var.instance_count
  network_configuration {
    security_groups  = [aws_security_group.sg-ecs.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.lb-targetgroup.arn
    container_name   = var.container_name
    container_port   = 3000
  }
  # health_check_grace_period_seconds = 30

  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.resource_identifier}-service",
    Environment = var.env,
    System      = var.system,
    Component   = var.app
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

output "ecs_sg" {
  value = aws_security_group.sg-ecs.id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.ecs-cluster.arn
}

output "log_group" {
  value = aws_cloudwatch_log_group.ecs-cloudwatchloggroup.name
}
