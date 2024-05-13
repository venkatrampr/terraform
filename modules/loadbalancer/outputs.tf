output "lb_dns" {
  value = aws_lb.lb[1].dns_name
}

output "pub_lb_dns" {
  value = aws_lb.lb[0].dns_name
}

output "pub_target_group" {
  value = aws_lb_target_group.target_group[0]
}

output "pri_target_group" {
  value = aws_lb_target_group.target_group[1]
}
