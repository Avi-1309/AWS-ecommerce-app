#!/bin/bash
# EC2 User Data Script — E-Commerce App
# Runs automatically when EC2 instance launches

set -e
exec > /var/log/userdata.log 2>&1

echo "=== Starting EC2 bootstrap ==="

# Update system packages
yum update -y

# Install Apache web server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Install Python 3 and pip
yum install -y python3 python3-pip

# Install required Python libraries
pip3 install boto3 flask mysql-connector-python

# Install AWS CLI v2 (if not present)
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
fi

# Create app directory
mkdir -p /var/www/html/app
chown -R apache:apache /var/www/html/app

# Set environment variables (no hardcoded secrets — uses IAM role)
cat >> /etc/environment << 'ENVEOF'
APP_ENV=production
AWS_DEFAULT_REGION=ap-south-1
S3_BUCKET_NAME=ecommerce-product-images
DYNAMODB_TABLE=ecommerce-sessions
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0
ENVEOF

echo "=== EC2 bootstrap complete ==="
