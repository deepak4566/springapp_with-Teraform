# Create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database-security-group"
  description = "Enable MySQL/Aurora access on port 3306"
  vpc_id      = aws_vpc.myvpc.id  # Replace with your VPC ID

  ingress {
    description      = "MySQL/Aurora access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_security_group.id]  # Replace with your ALB security group ID
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-security-group"
  }
}

# Create the subnet group for the RDS instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "db-secure-subnets"
  subnet_ids  = [aws_subnet.secure_subnet_az1,aws_subnet.secure_subnet_az2 ]  # Replace with your secure subnet IDs
  description = "RDS in secure subnet"

  tags = {
    Name = "db-secure-subnets"
  }
}

data "aws_db_instance" "db_instance_data" {   
  endpoint = aws_db_instance.db_instance.endpoint
} 



# Create the RDS instance
resource "aws_db_instance" "db_instance" {
  engine                = "mysql"
  engine_version        = "8.0.31"
  multi_az              = false
  identifier            = "petclinic"
  username              = "petclinic"
  password              = "petclinic"
  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  publicly_accessible   = true
  db_subnet_group_name  = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  availability_zone     = "ap-south-1"
  db_name               = "petclinic"
  skip_final_snapshot   = true
}

data "aws_db_instance" "db_instance_data" {   
  endpoint = aws_db_instance.db_instance.endpoint
} 
