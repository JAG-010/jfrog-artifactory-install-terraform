# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


# User data script for Artifactory installation
data "template_file" "user_data" {
  template = file("install-artifactory.sh")
  vars = {
    artifactory_version = var.artifactory_version
    db_host             = aws_db_instance.artifactory_db.endpoint
    db_name             = var.db_name
    db_username         = var.db_username
    db_password         = var.db_password
    s3_bucket_name      = aws_s3_bucket.artifactory_filestore.bucket
    aws_region          = var.aws_region
  }
}