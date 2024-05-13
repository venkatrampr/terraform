output "public_ips" {
  value = data.aws_instances.pub_instances.public_ips
}

output "private_ips" {
  value = data.aws_instances.pri_instances.private_ips
}

output "public_lb_DNS" {
  value = module.loadbalancer.pub_lb_dns
}
