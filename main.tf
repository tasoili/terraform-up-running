provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}

# expose the default VPC so the subnet detail can be gathered.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  # the VPC's ID to get the subnet id for.
  # this is from the data block above named "default"
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-01b996646377b6619"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
  	#!/bin/bash
  	echo "Hello, world" > index.html
  	nohup busybox httpd -f -p ${var.server_port} &
  	EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
