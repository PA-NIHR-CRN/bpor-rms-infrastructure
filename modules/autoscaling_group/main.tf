resource "aws_appautoscaling_target" "my_service" {
  count              = var.env == "oat" || var.env == "prod" ? 0 : 1
  max_capacity       = 1
  min_capacity       = 1
  resource_id        = "service/${var.account}-ecs-${var.env}-${var.system}-${var.app}-cluster/${var.account}-ecs-${var.env}-${var.system}-${var.app}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
resource "aws_appautoscaling_scheduled_action" "my_service" {
  count              = var.env == "oat" || var.env == "prod" ? 0 : 1
  name               = "${var.account}-asg-${var.env}-${var.system}-${var.app}-scale-down"
  service_namespace  = aws_appautoscaling_target.my_service[0].service_namespace
  resource_id        = aws_appautoscaling_target.my_service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.my_service[0].scalable_dimension
  schedule           = "cron(0 45 11 ? * MON-FRI *)"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}
resource "aws_appautoscaling_scheduled_action" "my_service_scale_out" {
  count              = var.env == "oat" || var.env == "prod" ? 0 : 1
  name               = "${var.account}-asg-${var.env}-${var.system}-${var.app}-scale-up"
  service_namespace  = aws_appautoscaling_target.my_service[0].service_namespace
  resource_id        = aws_appautoscaling_target.my_service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.my_service[0].scalable_dimension
  schedule           = "cron(0 50 11 ? * MON-FRI *)"

  scalable_target_action {
    min_capacity = 1
    max_capacity = 1
  }
}