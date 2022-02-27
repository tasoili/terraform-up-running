provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-01b996646377b6619"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}
