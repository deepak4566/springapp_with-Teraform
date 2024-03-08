# Security group for VPC Endpoints
resource "aws_security_group" "vpc_endpoint_security_group" {
  name        = "vpc-endpoint-sg"
  vpc_id      = aws_vpc.myvpc.id
  description = "Security group for VPC Endpoints"

  # Allow inbound HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from VPC"
  }

  tags = {
    Name = "VPC Endpoint security group"
  }
}

locals {
  endpoints = {
    "endpoint-ssm" = {
      name = "ssm"
    },
    "endpoint-ssmm-essages" = {
      name = "ssmmessages"
    },
    "endpoint-ec2-messages" = {
      name = "ec2messages"
    }
  }
}

# Create VPC Endpoints
resource "aws_vpc_endpoint" "endpoints" {
  for_each          = local.endpoints
  vpc_id            = aws_vpc.myvpc.id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.ap-south-1.${each.value.name}"

  # Add a security group to the VPC endpoint
  security_group_ids = [aws_security_group.vpc_endpoint_security_group.id]
}

# Create IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "EC2_SSM_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_role.name
}

# Create an instance profile for the EC2 instance and associate the IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_SSM_Instance_Profile"

  role = aws_iam_role.ec2_role.name
}
