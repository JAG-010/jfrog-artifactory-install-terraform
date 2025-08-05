# IAM Role for EC2
resource "aws_iam_role" "artifactory_role" {
  name = "${var.additional_tags}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "artifactory_profile" {
  name = "${var.additional_tags}-instance-profile"
  role = aws_iam_role.artifactory_role.name
}

# EC2 Instance
resource "aws_instance" "artifactory_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.artifactory_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.artifactory_profile.name
  key_name               = var.key_name != "" ? var.key_name : null

  user_data = data.template_file.user_data.rendered
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.additional_tags}-instance"
  }

  depends_on = [
    aws_internet_gateway.artifactory_igw,
    aws_db_instance.artifactory_db
  ]
}
