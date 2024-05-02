resource "aws_instance" "test_instance" {
  ami           = "ami-0cf0e376c672104d6"
  instance_type = "t2.micro"
  tags = {
    Name = "Demo"
  }
}
