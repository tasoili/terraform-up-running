provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-039af3bfc52681cd5"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}
