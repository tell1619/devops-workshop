provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "terraform-demo-server" {
    ami = "ami-0fef2f5dd8d0917e8"
    instance_type = "t2.micro"
    key_name = "tds"
}