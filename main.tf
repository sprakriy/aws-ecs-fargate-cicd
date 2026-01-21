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