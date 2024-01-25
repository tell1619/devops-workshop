provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "terraform-demo-server" {
    ami = "ami-0fef2f5dd8d0917e8"
    instance_type = "t2.micro"
    key_name = "tds-2"
    security_groups = [ "terraform-demo-sg" ]
}

resource "aws_security_group" "terraform-demo-sg" {
  name        = "terraform-demo-sg"
  description = "SSH Access"
  
  ingress {
    description      = "SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"

  }
}