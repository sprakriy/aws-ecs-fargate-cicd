variable "environment" { type = string }
variable "repository_url" { type = string }
variable "subnet_ids" { type = list(string) }
variable "ecs_tasks_sg_id" { type = string }
variable "target_group_arn" { type = string }