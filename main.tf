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

resource "aws_vpc" "MCRVPC" {
	cidr_block = "10.31.0.0/16"
  	instance_tenancy = "default"
	tags = {
    		Name = "mymcrvpc"
    		Terraform = "true"
  	}
}

resource "aws_subnet" "MCRPrivateSubnet" {
	vpc_id = aws_vpc.MCRVPC.id
  	cidr_block = "10.31.0.0/24"
  	tags = {
    		Name = "mymcrprivatesubnet"
    		Terraform = "true"
  	}
}

resource "aws_instance" "MCREC2" {
  	ami = "ami-0dc2d3e4c0f9ebd18"
  	instance_type = "t2.micro"
  	subnet_id = aws_subnet.MCRPrivateSubnet.id  
  	tags = {
    		Name = "myec2instance"
  	}
}
