resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  
  # This uses the "windows" we just opened in Step 1
  resource_id        = "service/${module.ecs.cluster_name}/${module.ecs.service_name}"
  
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# The policy remains the same as your previous copy-paste
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50.0 
  }
}