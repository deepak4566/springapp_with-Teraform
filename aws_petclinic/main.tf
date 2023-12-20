
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  enable_dns_support = true
  enable_dns_hostnames = true

   tags = {
    Name        = "aws_3tier_app"
    
   
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}






resource "aws_eip" "eip_for_nat_gateway_az1" {
  domain = "vpc"

  tags   = {
    Name = "elastic ip 1"
  }
}

resource "aws_eip" "eip_for_nat_gateway_az2" {
  domain = "vpc" # Set to true for VPC EIP

  tags   = {
    Name = "elastic ip 2"
  }
}

resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip_for_nat_gateway_az1.id
  subnet_id     = aws_subnet.sub1.id

  tags   = {
    Name = "NAT Gateway AZ1"
  }

 }


resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip_for_nat_gateway_az2.id
  subnet_id     = aws_subnet.sub1.id

  tags   = {
    Name = "NAT Gateway AZ2"
  }

 }
















resource "aws_subnet" "private_sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
}


resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway_az1.id
    
  }
}


resource "aws_route_table" "RT2" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat_gateway_az2.id
    
  }
}







resource "aws_route_table_association" "private_rta1" {
  subnet_id      = aws_subnet.private_sub1.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_route_table_association" "private_rta2" {
  subnet_id      = aws_subnet.private_sub2.id
  route_table_id = aws_route_table.RT2.id
}


resource "aws_subnet" "secure_subnet_az1" {
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = "10.0.2.0/24"
  availability_zone        = "ap-south-1a"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "secure subnet az1"
  }
}

# create secure subnet az2
resource "aws_subnet" "secure_subnet_az2" {
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = "10.0.3.0/24"
  availability_zone        = "ap-south-1b"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "secure subnet az2"
  }
}





