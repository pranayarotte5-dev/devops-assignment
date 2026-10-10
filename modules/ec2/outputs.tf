
output "instance_ids" {
  description = "Map of instance names to EC2 instance IDs"

  value = merge(
    { for name, instance in aws_instance.this : name => instance.id },
    { app1 = aws_instance.protected.id }
  )
}

output "private_ips" {
  description = "Map of instance names to private IP addresses"

  value = merge(
    { for name, instance in aws_instance.this : name => instance.private_ip },
    { app1 = aws_instance.protected.private_ip }
  )
}
