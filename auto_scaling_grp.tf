data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["684371204192"]  # Assuming you own the AMI

  filter {
    name   = "ami-version-1.0.1-1702821755"
    values = ["ami-06b2cc514669d75b8"]  # Replace with your actual AMI ID
  }
}


# Terraform AWS Launch Template
resource "aws_launch_template" "ec2_asg" {
  name                  = "my-launch-template"
  image_id              = data.aws_ami.amazon_linux_2.id
  instance_type         = "t2.micro"
  iam_instance_profile {
    name = "ag_iam"
  }
  user_data = base64encode(templatefile("userdata.sh", { mysql_url =}))
  vpc_security_group_ids = [aws_security_group.alb_security_group.id]
  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "asg-tf" {
  name                 = "autoscaling_in_private"
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  force_delete         = true
  depends_on           = [aws_lb.application_load_balancer]
  target_group_arns    = [aws_lb_target_group.alb_target_group.arn]
  health_check_type    = "EC2"
  launch_template {
    id      = aws_launch_template.ec2_asg.id
    version = aws_launch_template.ec2_asg.latest_version
  }
  vpc_zone_identifier  = [aws_subnet.private_sub1.id ,aws_subnet.private_sub2.id ]

  tag {
    key                 = "ag_key"
    value               = "autoscaling_in_private"
    propagate_at_launch = true
  }
}
