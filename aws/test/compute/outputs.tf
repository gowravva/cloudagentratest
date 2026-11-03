output "instance_id" {
  description = "EC2 instance ID of the agentra web server."
  value       = aws_instance.agentra_web_server.id
}

output "instance_public_ip" {
  description = "Public IP address assigned to the agentra web server."
  value       = aws_instance.agentra_web_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the agentra web server."
  value       = aws_instance.agentra_web_server.public_dns
}

output "key_pair_name" {
  description = "Name of the AWS key pair created for the web server."
  value       = aws_key_pair.agentra_web_server_key.key_name
}

output "private_key_pem_path" {
  description = "Local path where the private key PEM file was written."
  value       = local_sensitive_file.agentra_web_server_pem.filename
}