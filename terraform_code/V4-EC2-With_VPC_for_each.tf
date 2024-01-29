provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "terraform-demo-server" {
    ami = "ami-0905a3c97561e0b69" //ubuntu-ami-id
    instance_type = "t2.micro"
    key_name = "tds-2"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [aws_security_group.terraform-demo-sg.id]
    subnet_id = aws_subnet.terraform-demo-public-subnet-01.id
for_each = toset(["jenkins-master", "build-slave", "ansible"])
   tags = {
     Name = "${each.key}"
   }
}

resource "aws_security_group" "terraform-demo-sg" {
  name        = "terraform-demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.terraform-demo-vpc.id 
  
  ingress {
    description      = "SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
    description      = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
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

resource "aws_vpc" "terraform-demo-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "terraform-demo-vpc"
  }
  
}

resource "aws_subnet" "terraform-demo-public-subnet-01" {
  vpc_id = aws_vpc.terraform-demo-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "terraform-demo-public-subnet-01"
  }
}

resource "aws_subnet" "terraform-demo-public-subnet-02" {
  vpc_id = aws_vpc.terraform-demo-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "terraform-demo-public-subnet-02"
  }
}

resource "aws_internet_gateway" "terraform-demo-igw" {
  vpc_id = aws_vpc.terraform-demo-vpc.id 
  tags = {
    Name = "terraform-demo-igw"
  } 
}

resource "aws_route_table" "terraform-demo-public-rt" {
  vpc_id = aws_vpc.terraform-demo-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-demo-igw.id 
  }
}

resource "aws_route_table_association" "terraform-demo-rta-public-subnet-01" {
  subnet_id = aws_subnet.terraform-demo-public-subnet-01.id
  route_table_id = aws_route_table.terraform-demo-public-rt.id   
}

resource "aws_route_table_association" "terraform-demo-rta-public-subnet-02" {
  subnet_id = aws_subnet.terraform-demo-public-subnet-02.id 
  route_table_id = aws_route_table.terraform-demo-public-rt.id   
}

#Budget Alarm

module "billing_alert" {
  source = "binbashar/cost-billing-alarm/aws"

  aws_env = local.aws_profile
  aws_account_id = local.aws_account_id
  monthly_billing_threshold = 10
  currency = "USD"
  create_sns_topic = true
}

output "sns_topic_arn" {
  value = module.billing_alert.sns_topic_arns
}
# Will output the following:
# arn:aws:sns:us-east-1:111111111111:billing-alarm-notification-usd-dev for billing alarms

locals {
  aws_account_id = "381492164150" 
  aws_profile = "dev"
}