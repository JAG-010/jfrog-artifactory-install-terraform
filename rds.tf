# Private Subnet for RDS
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.artifactory_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.additional_tags}-private-subnet"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "artifactory-rds-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.artifactory_vpc.id

  # PostgreSQL access from Artifactory instance
  ingress {
    description     = "PostgreSQL from Artifactory"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.artifactory_sg.id]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.additional_tags}-rds-sg"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "artifactory_db_subnet_group" {
  name       = "artifactory-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]

  tags = {
    Name = "${var.additional_tags}-db-subnet-group"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "artifactory_db_parameter_group" {
  family = "postgres14"
  name   = "artifactory-postgres14-params"

  parameter {
    name         = "max_connections"
    value        = "200"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "client_encoding"
    value = "utf8"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = {
    Name = "${var.additional_tags}-db-params"
  }
}

# RDS Instance
resource "aws_db_instance" "artifactory_db" {
  identifier = "${var.additional_tags}-artifactory-postgresql"

  # Database configuration
  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  # Database credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network configuration
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.artifactory_db_subnet_group.name
  publicly_accessible    = false

  # Backup and maintenance
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  skip_final_snapshot     = true

  # Performance
  multi_az = false

  tags = {
    Name = "${var.additional_tags}-postgresql"
  }
}