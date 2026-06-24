#!/bin/bash
# VPC Setup Script — creates VPC with public/private subnets across 2 AZs
# Run from AWS CloudShell or a machine with AWS CLI configured

REGION="ap-south-1"
VPC_CIDR="10.0.0.0/16"

echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --query 'Vpc.VpcId' \
  --output text)
echo "VPC created: $VPC_ID"

aws ec2 create-tags --resources $VPC_ID \
  --tags Key=Name,Value=ecommerce-vpc

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames

# Public Subnet AZ-1
PUB_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ${REGION}a \
  --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PUB_SUBNET_1 \
  --tags Key=Name,Value=ecommerce-public-1a

# Public Subnet AZ-2
PUB_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ${REGION}b \
  --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PUB_SUBNET_2 \
  --tags Key=Name,Value=ecommerce-public-1b

# Private Subnet AZ-1
PRIV_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.3.0/24 \
  --availability-zone ${REGION}a \
  --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PRIV_SUBNET_1 \
  --tags Key=Name,Value=ecommerce-private-1a

# Private Subnet AZ-2
PRIV_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.4.0/24 \
  --availability-zone ${REGION}b \
  --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PRIV_SUBNET_2 \
  --tags Key=Name,Value=ecommerce-private-1b

# Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=ecommerce-igw

echo "=== VPC setup complete ==="
echo "VPC: $VPC_ID | Public: $PUB_SUBNET_1, $PUB_SUBNET_2 | Private: $PRIV_SUBNET_1, $PRIV_SUBNET_2"
