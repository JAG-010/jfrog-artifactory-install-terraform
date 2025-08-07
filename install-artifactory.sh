#!/bin/bash

# JFrog Artifactory Installation Script for Amazon Linux 2023 (RPM-based)
# Based on official JFrog documentation: https://jfrog.com/help/r/jfrog-installation-setup-documentation/install-artifactory-on-rpm

# set -e

echo "=========================================="
echo "Starting JFrog Artifactory installation..."
echo "Timestamp: $(date)"
echo "=========================================="

echo "Starting JFrog Artifactory installation using RPM..."

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install required dependencies
echo "Installing required dependencies..."
sudo yum install -y java-21-amazon-corretto-headless wget > /tmp/artifactory_install.log 2>&1

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
echo "export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto" >> ~/.bashrc
echo `java -version` >> /tmp/artifactory_install.log 2>&1

# Add JFrog repository
echo "Adding JFrog repository..."
sudo wget https://releases.jfrog.io/artifactory/artifactory-pro-rpms/artifactory-pro-rpms.repo -O jfrog-artifactory-pro-rpms.repo
sudo mv jfrog-artifactory-pro-rpms.repo /etc/yum.repos.d/

# Install Artifactory using RPM
echo "Installing JFrog Artifactory version ${artifactory_version} using RPM..."

## Uncomment this line if you want to specify a version
# sudo yum install -y jfrog-artifactory-pro-${artifactory_version} 

# For the latest version, use the following line:
sudo yum install -y jfrog-artifactory-pro


# Replace the commented database configuration with actual values
sudo sed -i 's/#   type: postgresql/        type: postgresql/' /opt/jfrog/artifactory/var/etc/system.yaml
sudo sed -i 's/#   driver: org.postgresql.Driver/        driver: org.postgresql.Driver/' /opt/jfrog/artifactory/var/etc/system.yaml
sudo sed -i 's|#   url: "jdbc:postgresql://<your db url, for example: localhost:5432>/artifactory"|        url: "jdbc:postgresql://'${db_host}'/'${db_name}'"|' /opt/jfrog/artifactory/var/etc/system.yaml
sudo sed -i 's/#   username: artifactory/        username: '${db_username}'/' /opt/jfrog/artifactory/var/etc/system.yaml
sudo sed -i 's/#   password: password/        password: '${db_password}'/' /opt/jfrog/artifactory/var/etc/system.yaml

# Configure S3 filestore in binarystore.xml
echo "Configuring S3 filestore in binarystore.xml..."
sudo tee /opt/jfrog/artifactory/var/etc/artifactory/binarystore.xml > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<config version="2">
    <chain>
        <provider id="cache-fs" type="cache-fs">
            <provider id="s3-storage-v3" type="s3-storage-v3"/>
        </provider>
    </chain>
    <provider type="cache-fs" id="cache-fs">
        <maxCacheSize>5000000000</maxCacheSize>
        <cacheProviderDir>/artifactory-data/cache</cacheProviderDir>
    </provider>
    <provider id="s3-storage-v3" type="s3-storage-v3">
        <bucketName>${s3_bucket_name}</bucketName>
        <endpoint>s3.amazonaws.com</endpoint>
        <useInstanceCredentials>true</useInstanceCredentials>
        <testConnection>false</testConnection>
        <enableSignedUrlRedirect>true</enableSignedUrlRedirect>
        <signatureExpirySeconds>300</signatureExpirySeconds>
        <refreshCredentials>true</refreshCredentials>
        <signedUrlExpirySeconds>30</signedUrlExpirySeconds>
        <region>${aws_region}</region>
        <maxConnections>200</maxConnections>
    </provider>
</config>
EOF

# Set proper permissions for binarystore.xml
sudo chown artifactory:artifactory /opt/jfrog/artifactory/var/etc/artifactory/binarystore.xml
sudo chmod 600 /opt/jfrog/artifactory/var/etc/artifactory/binarystore.xml

# Enable and start Artifactory service
echo "Enabling and starting Artifactory service..."
# sudo systemctl stop artifactory
sudo systemctl daemon-reload
sudo systemctl enable artifactory
sudo systemctl start artifactory

# # Wait for Artifactory to start
# echo "Waiting for Artifactory to start..."
# sleep 120

# # Check if Artifactory is running
# if sudo systemctl is-active --quiet artifactory; then
#     echo "✅ Artifactory is running successfully!"
#     echo "You can access Artifactory at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
#     echo "Default credentials: admin / password"
# else
#     echo "❌ Artifactory failed to start. Check logs with: sudo journalctl -u artifactory"
#     echo "Checking service status..."
#     sudo systemctl status artifactory
#     echo "Installation failed."
#     exit 1
# fi

# echo "JFrog Artifactory installation completed successfully!"
# echo "=================================================="
# echo "Artifactory URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
# echo "Default admin credentials: admin / password"
# echo "Installation directory: /opt/jfrog/artifactory"
# echo "Service name: artifactory"
# echo "=================================================="

# # Write installation summary to console
# echo "=== INSTALLATION SUMMARY ==="
# echo "Installation completed at: $(date)"
# echo "Artifactory version: ${artifactory_version}"
# echo "Installation directory: /opt/jfrog/artifactory"
# echo "Service status: $(sudo systemctl is-active artifactory)"
# echo "Artifactory URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
# echo "Default credentials: admin / password"
# echo "=============================" 