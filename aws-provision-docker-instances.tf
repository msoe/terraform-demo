provider "aws" {
  profile = "sandbox"
  region  = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_instance" "node" {
  count         = 3
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-09d95fab7fff3776c"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-ssh-sg.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/terraform")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum upgrade -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo systemctl start docker",
      "sudo usermod -a -G docker ec2-user"    ]
  }
}

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
  
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}