output "instance_id" {
  description = "The ID of the webapp EC2 instance."
  value       = aws_instance.webapp_instance.id
}

output "instance_public_ip" {
  description = "The public IP address of the webapp EC2 instance."
  value       = aws_instance.webapp_instance.public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the webapp EC2 instance."
  value       = aws_instance.webapp_instance.private_ip
}