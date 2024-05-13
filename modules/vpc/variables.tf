variable "vpc_cidr" {}
variable "pub_subnet_cidrs" {
    type = list
}
variable "pri_subnet_cidrs" {
    type = list
}
variable "availability_zones" {
    type = list
}
