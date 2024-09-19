# Creating the VPC

resource "aws_vpc" "abc" {
 cidr_block = "10.0.0.0/16"
 instance_tenancy = "default"
 enable_dns_hostnames = "true"
 tags = {
 Name = "my-vpc"
 }
}

# Creating two public subnets in two different availability zones

resource "aws_subnet" "mysubnet1" {
 vpc_id = aws_vpc.abc.id
 cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1a"
map_public_ip_on_launch = "true"
 tags = {
 Name = "subnet-1"
 }
}


resource "aws_subnet" "mysubnet2" {
 vpc_id = aws_vpc.abc.id
 cidr_block = "10.0.2.0/24"
 availability_zone = "us-east-1b"
 map_public_ip_on_launch = "true"
 tags = {
 Name = "subnet-2"
 }
}

# Creating the internet gatway

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.abc.id
 tags = {
 Name = "my-igw"
 }
}

# Creating the route table

resource "aws_route_table" "myrt" {
 vpc_id = aws_vpc.abc.id
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.igw.id
 }
 tags = {
 Name = "my-route-table"
 }
}

# Attaching the route table to both the public subnets

resource "aws_route_table_association" "public_subnet_association_1a" {
 subnet_id = aws_subnet.mysubnet1.id
 route_table_id = aws_route_table.myrt.id
 }
 resource "aws_route_table_association" "public_subnet_association_1b" {
 subnet_id = aws_subnet.mysubnet2.id
 route_table_id = aws_route_table.myrt.id
 }

# Creating a security group with allowing inbound ports 80, 22, 443 and all outbound traffic

resource "aws_security_group" "web_server" {
 name_prefix = "web-server-sg"
 vpc_id = aws_vpc.abc.id
 ingress {
 from_port = 22
 to_port = 22
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
 from_port = 80
 to_port = 80
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
 from_port = 443
 to_port = 443
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }
}

#Creating the EC2 Instance with git installing in it.

resource "aws_instance" "aws_ec2" {
ami = "ami-0ebfd941bbafe70c6"
instance_type = "t2.micro"
tags = {
Name = "Dev"
}
user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install git -y
EOF
}

# Storing the state file in s3 bucket named "mybucket201924"

terraform {
 backend "s3" {
 bucket = "mybucket201924"
 key = "./terraform.tfstate"
 region = "us-east-1"
 }
}
