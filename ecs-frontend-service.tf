#=========CloudWatch Metrics===========
resource "aws_cloudwatch_metric_alarm" "ecs_service_fronend_scale_up_alarm" {
  alarm_name          = var.scale_up_alarm.frontend
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.period_up
  statistic           = var.statistic
  threshold           = var.threshold_up
  #datapoints_to_alarm = var.datapoints_to_alarm_up

  dimensions = {
    ClusterName = aws_ecs_cluster.prod_mydemo.id
    ServiceName = "${aws_ecs_service.frontend.id}"
  }

  alarm_description = "This metric monitor ecs CPU utilization up"
  alarm_actions     = [aws_appautoscaling_policy.frontend_service_scale_up.arn]
}


resource "aws_cloudwatch_metric_alarm" "ecs_service_frontend_scale_down_alarm" {
  alarm_name          = var.scale_down_alarm.frontend
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.period_down
  statistic           = var.statistic
  threshold           = var.threshold_down
  #datapoints_to_alarm = var.datapoints_to_alarm_up

  dimensions = {
    ClusterName = aws_ecs_cluster.prod_mydemo.id
    ServiceName = "${aws_ecs_service.frontend.id}"
  }

  alarm_description = "This metric monitor ecs CPU utilization Down"
  alarm_actions     = [aws_appautoscaling_policy.frontend_service_scale_down.arn]
}


resource "aws_ecs_service" "frontend" {
  launch_type     = var.ecs_service_launch_type.fargate
  task_definition = aws_ecs_task_definition.frontend.arn
  cluster         = aws_ecs_cluster.prod_mydemo.id
  name            = var.task_definition_name.frontend

  scheduling_strategy = var.ecs_service_strategy.replica

  desired_count                      = var.ecs_service_desired_count.frontend
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  #iam_role                           = aws_iam_role.prod_ecs_service_auto_scale.arn

  network_configuration {
    security_groups  = [aws_security_group.Prod_ecsSG.id]
    subnets          = [aws_subnet.prod_public1.id, aws_subnet.prod_public2.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.prod_frontend.arn
    container_name   = var.task_definition_name.frontend
    container_port   = var.container_port.frontend
  }

}


resource "aws_appautoscaling_target" "prod_ecs_frontend_target" {
  max_capacity       = var.ecs_service_max_capacity
  min_capacity       = var.ecs_service_min_capacity
  resource_id        = "service/${aws_ecs_cluster.prod_mydemo.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = var.ECS_Service_Scale_Role
}


resource "aws_appautoscaling_policy" "frontend_service_scale_up" {
  name               = var.scale_up_alarm.frontend
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.prod_ecs_frontend_target.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = var.adjustment_type.changein
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = var.metric_aggregation_type.max

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_up_adjustment
    }
  }
  depends_on = [aws_appautoscaling_target.prod_ecs_frontend_target]
}

resource "aws_appautoscaling_policy" "frontend_service_scale_down" {
  name               = var.scale_down_alarm.frontend
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.prod_ecs_frontend_target.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = var.adjustment_type.changein
    cooldown                = var.scale_down_cooldown
    metric_aggregation_type = var.metric_aggregation_type.max

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_down_adjustment
    }
  }
  depends_on = [aws_appautoscaling_target.prod_ecs_frontend_target]
}
