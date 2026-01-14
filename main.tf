# main.tf

module "ecr" {
  source = "./modules/ecr"
}

module "networking" {
  source      = "./modules/networking"
  environment = "prod"
}

module "ecs" {
  source           = "./modules/ecs"
  environment      = "prod"
  repository_url   = module.ecr.repository_url
  subnet_ids       = module.networking.public_subnet_ids
  ecs_tasks_sg_id  = module.networking.ecs_tasks_sg_id
  target_group_arn = module.networking.target_group_arn
}

# 1. Define the Scalable Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# 2. Define the Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50.0  # Keep average CPU at 50%
  }
}
# OUTPUTS
output "app_url" {
  value = "http://${module.networking.alb_dns_name}"
}
# DIAGNOSTIC OUTPUTS
output "DEBUG_image_url_from_ecr" {
  value = module.ecr.repository_url
  description = "This is the URL Terraform is grabbing from the ECR module"
}

output "DEBUG_vpc_id" {
  value = module.networking.vpc_id
}

output "DEBUG_public_subnets" {
  value = module.networking.public_subnet_ids
}