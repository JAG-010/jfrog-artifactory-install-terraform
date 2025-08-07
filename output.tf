output "artifactory_public_ip" {
  description = "Public IP of the Artifactory instance"
  value       = aws_instance.artifactory_instance.public_ip
}

output "artifactory_ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.artifactory_instance.public_ip}"
}

output "artifactory_url" {
  description = "URL to access Artifactory"
  value       = "http://${aws_instance.artifactory_instance.public_ip}:8081"
}

output "database_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.artifactory_db.endpoint
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.artifactory_db.db_name
}

output "database_username" {
  description = "Database master username"
  value       = aws_db_instance.artifactory_db.username
}

output "s3_bucket_name" {
  description = "S3 bucket name for Artifactory filestore"
  value       = aws_s3_bucket.artifactory_filestore.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for Artifactory filestore"
  value       = aws_s3_bucket.artifactory_filestore.arn
}