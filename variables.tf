# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1" // Change this to your required region
}

variable "additional_tags" {
  default     = "artifactory"
  description = "Additional resource tags"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium" // Change this to your required instance type
}

variable "key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
}

variable "artifactory_version" {
  description = "JFrog Artifactory version to install"
  type        = string
  default     = "7.77.7" // Check artifactory release notes for the latest version
}

# Database Variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "14.17"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "artifactory"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "artifactory"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  default     = "password"
  sensitive   = true
}

# S3 Filestore Variables
variable "s3_bucket_name" {
  description = "S3 bucket name for Artifactory filestore"
  type        = string
  default     = "artifactory-filestore"
}

variable "s3_bucket_versioning" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}
