terraform {
  backend "remote" {
    organization = "MissionCyberDemonstrator"

    workspaces {
      name = "mcr-aws-infrabuild"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.0.2"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
 Build the VPC
resource "aws_vpc" "MCRVPC" {
    cidr_block = "10.31.0.0/16"
    instance_tenancy = "default"
    
  tags =  {
    Name = "MCRVPC"
    Terraform = "true"
  }
}
resource "aws_subnet" "MCRPrivateSubnet" {
  vpc_id = aws_vpc.MCRVPC.id
  cidr_block = "10.31.0.0/24"
  tags = {
    Name = "MCRPrivateSubnet"
    Terraform = "true"
  }
}
resource "aws_subnet" "MCRPublicSubnet" {
  vpc_id = aws_vpc.MCRVPC.id
  cidr_block = "10.31.1.0/24"
    
  tags = {
    Name = "MCRPublicSubnet"
    Terraform = "true"
  }
}

resource "aws_security_group" "MCRAllowSSH" {
  name        = "MCRAllowSSH"
  description = "Allow ssh inbound traffic from user connected with VPN"
  vpc_id      = aws_vpc.MCRVPC.id
    
  ingress {
    description = "ssh to EC2 using VPN"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
      
  }
    
  ingress {
    description = "allow port 80 connection"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    
  tags = {
    Name = "MCRAllowSSH"
    Terraform = "true"
  }
}  

resource "aws_security_group_rule" "MCRAllowSSH" {
  description = "Allow ssh from resources with security group attached"
  type = "ingress"
  from_port = 22
  to_port  = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.MCRAllowSSH.id
  security_group_id = aws_security_group.MCRAllowSSH.id
}

resource "aws_internet_gateway" "MCRIGW" {
  vpc_id = aws_vpc.MCRVPC.id

  tags = {
    Name = "MCRIGW"
    Terraform = "true"
  }
}

resource "aws_instance" "mcr-test" {
  ami           = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.MCRPrivateSubnet.id

  tags = {
    Name = "mcr-test"
  }
}
