output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "ecs_tasks_sg_id"   { value = aws_security_group.ecs_tasks.id } # Ensure this matches the SG name
output "target_group_arn"  { value = aws_lb_target_group.app.arn }
output "alb_dns_name"      { value = aws_lb.main.dns_name }
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}