output "vpc" {
    value = aws_vpc.vpc
}
output "pub_subnet" {
    value = aws_subnet.pub_subnet
}
output "pri_subnet" {
    value = aws_subnet.pri_subnet
}

output "public_subnet_id" {
  value = aws_subnet.pub_subnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.pri_subnet[*].id
}
