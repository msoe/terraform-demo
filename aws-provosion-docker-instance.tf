provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-09d95fab7fff3776c"
  instance_type = "t2.micro"

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
