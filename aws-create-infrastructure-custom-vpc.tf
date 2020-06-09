provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}

# Subnet
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Route Table
resource "aws_route_table" "public_rt" {
  route {
    cidr_block = "0.0.0.0/0"
  
  gateway_id = aws_internet_gateway.igw.id
  }
      vpc_id = aws_vpc.vpc.id

}

# Subnet Association
resource "aws_route_table_association" "public1_subnet_rt" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

# Security groups
resource "aws_security_group" "public-web-sg" {
  name        = "public-web-ssh-sg"
  description = "Allow incoming http/ssh traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("tf.pub")
}

# Instance
resource "aws_instance" "my-instance" {
  instance_type          = "t2.micro"
  ami                    = "ami-b73b63a0"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.public-web-sg.id]
  subnet_id              = aws_subnet.public1.id

  provisioner "local-exec" {
    command = "echo ${aws_instance.my-instance.public_ip} > ip_address.txt"
  }
}
