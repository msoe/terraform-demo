provider "aws" {
  region = "us-east-1"
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("tf.pub")
}

# Security groups
resource "aws_security_group" "web-ssh-sg" {
  name        = "public-web-ssh-sg"
  description = "Allow incoming http/ssh traffic"

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

# Instance, Amazon Linux 2
resource "aws_instance" "my-instance" {
  instance_type          = "t2.micro"
  ami                    = "ami-09d95fab7fff3776c"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.web-ssh-sg.id]

  # To output the public IP of the instance to the file
  provisioner "local-exec" {
    command = "echo ${aws_instance.my-instance.public_ip} > ip_address.txt"
  }
}