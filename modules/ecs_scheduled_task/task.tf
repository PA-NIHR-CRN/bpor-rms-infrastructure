
#------------------------------------------------------------------------------
# CLOUDWATCH EVENT RULE
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "${var.account}-ecs-${var.env}-${var.system}-${var.app}-cw-event-rule"
  schedule_expression = var.event_rule_schedule_expression
  event_bus_name      = var.event_rule_event_bus_name
  event_pattern       = var.event_rule_event_pattern
  description         = var.event_rule_description
  role_arn            = var.event_rule_role_arn
  is_enabled          = var.event_rule_is_enabled
  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.system}-${var.app}-cw-event-rule",
    Environment = var.env,
    System      = var.system,
    Component   = var.app,
  }
}

#------------------------------------------------------------------------------
# CLOUDWATCH EVENT TARGET
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = aws_cloudwatch_event_rule.event_rule.event_bus_name
  target_id      = var.event_target_target_id
  arn            = var.ecs_cluster_arn
  input          = var.event_target_input
  input_path     = var.event_target_input_path
  role_arn       = var.event_rule_role_arn

  ecs_target {
    group               = var.event_target_ecs_target_group
    launch_type         = "FARGATE"
    platform_version    = var.event_target_ecs_target_platform_version
    task_count          = var.event_target_ecs_target_task_count
    task_definition_arn = aws_ecs_task_definition.scheduled-task-definition.arn
    propagate_tags      = var.event_target_ecs_target_propagate_tags == "" ? null : var.event_target_ecs_target_propagate_tags

    network_configuration {
      subnets          = var.event_target_ecs_target_subnets
      security_groups  = var.event_target_ecs_target_security_groups
      assign_public_ip = var.event_target_ecs_target_assign_public_ip
    }
  }

  lifecycle {
    ignore_changes = [
      ecs_target[0].task_definition_arn
    ]
  }

}

#------------------------------------------------------------------------------
# SCHEDULED TASK DEFINITION
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs-loggroup" {
  name              = "${var.account}-ecs-${var.env}-${var.system}-${var.app}-loggroup"
  retention_in_days = "30"

  tags = {
    Name        = "${var.account}-ecs-cloudwatch-${var.env}-${var.system}-${var.app}-loggroup",
    Environment = var.env,
    System      = var.system,
    Component   = var.app,
  }
}

resource "aws_ecs_task_definition" "scheduled-task-definition" {
  family                   = "${var.account}-ecs-${var.env}-${var.system}-${var.app}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = var.ecs_task_role_arn
  task_role_arn            = var.ecs_task_role_arn
  container_definitions = jsonencode([{
    name      = var.scheduled_container_name
    image     = var.scheduled_image_url
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 3000
      hostPort      = 3000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs-loggroup.id
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.system}-${var.app}-task-definition",
    Environment = var.env,
    System      = var.system,
    Component   = var.app,
  }
}

output "log_group" {
  value = aws_cloudwatch_log_group.ecs-loggroup.name

}