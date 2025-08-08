# Install JFrog Artifactory on AWS EC2 (Single node)


This Terraform configuration deploys JFrog Artifactory on a single AWS EC2 instance with all necessary networking components.

## Architecture

The deployment creates:
- VPC with public and private subnets
- Internet Gateway for internet access
- Security Groups with necessary ports (22, 80, 443, 8081, 8082, 5432)
- EC2 instance with Amazon Linux 2023
- RDS PostgreSQL database for Artifactory
- S3 bucket for Artifactory filestore
- Automatic Artifactory installation with database and S3 configuration

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
3. **AWS credentials** configured (via AWS CLI or environment variables)

## Quick Start

1. **Clone or download** this repository
2. **Configure variables** :
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred settings
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Deploy the infrastructure**:
   ```bash
   terraform apply
   ```

6. **Access Artifactory**:
   - URL: `http://<public-ip>:8081`
   - Default credentials: `admin` / `password`

## Configuration Options

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for deployment | `us-east-1` | No |
| `instance_type` | EC2 instance type | `t3.medium` | Yes |
| `artifactory_version` | JFrog Artifactory version | `latest` | No |
| `key_name` | SSH key pair name | `""` | Yes |
| `db_instance_class` | RDS instance class | `db.t3.micro` | Yes |
| `db_allocated_storage` | RDS storage in GB | `20` | No |
| `db_engine_version` | PostgreSQL version | `14.17` | No |
| `db_name` | Database name | `artifactory` | No |
| `db_username` | Database username | `artifactory` | No |
| `db_password` | Database password | `password` | No |
| `s3_bucket_name` | S3 bucket name for filestore | `artifactory-filestore` | Yes |
| `s3_bucket_versioning` | Enable S3 bucket versioning | `true` | No |




### Instance Specifications

- **OS**: Amazon Linux 2023
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **Storage**: 50 GB GP3 EBS volume
- **Java**: Amazon Corretto 11

### Security Group Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH access |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 8081 | TCP | Artifactory HTTP |
| 8082 | TCP | Artifactory HTTPS |
| 5432 | TCP | PostgreSQL (RDS) |



## Management Commands

### Check Artifactory Status
```bash
sudo systemctl status artifactory
```

<!-- ### View Installation Log
```bash
sudo cat /var/log/artifactory-installation.log
```

### View Artifactory Logs
```bash
sudo journalctl -u artifactory -f
```

### Restart Artifactory
```bash
sudo systemctl restart artifactory
``` -->

### Stop Artifactory
```bash
sudo systemctl stop artifactory
```

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```


## Security Considerations

- **Change default password** after first login
- **Use HTTPS** for production deployments
- **Restrict security group** to specific IP ranges
- **Enable AWS CloudTrail** for audit logging
- **Use AWS Secrets Manager** for sensitive data


## Support

For JFrog Artifactory support:
- [Official Documentation](https://jfrog.com/help/r/jfrog-installation-setup-documentation/install-artifactory-on-rpm)
- [JFrog Support Portal](https://support.jfrog.com/)

## License

This project is provided as-is for educational and development purposes.

