
output "instance_ids" {
  description = "Map of instance names to EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "private_ips" {
  description = "Map of instance names to EC2 private IP addresses"
  value       = module.ec2.private_ips
}
