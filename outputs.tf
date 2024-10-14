# Output declarations

# Public IP for the Bastion host instance
output "bastion_host_public_ip" {
  value       = aws_instance.depi-frontend-server.public_ip
  description = "Public IP address of the bastion host instance"
}

# Private IP for the Jenkins server instance
output "jenkins_server_private_ip" {
  value       = aws_instance.jenkins_server_instance.private_ip
  description = "Private IP of the private EC2 instance"
}

# Private IP for the backend server instance
output "backend_server_private_ip" {
  value       = aws_instance.depi_backend_server.private_ip
  description = "Private IP of the private EC2 instance"
}

output "rds_instance_endpoint" {
  value       = aws_db_instance.depi-rds-instance.endpoint
  description = "Endpoint of the RDS instance"
}
/*
output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_backend.bucket
  description = "Name of the S3 bucket used for Terraform state"
}
*/
