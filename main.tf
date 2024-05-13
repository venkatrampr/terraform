module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  pub_subnet_cidrs = var.pub_subnet_cidrs
  pri_subnet_cidrs = var.pri_subnet_cidrs
  availability_zones = var.availability_zones
}

module "auto_scaling" {
  source = "./modules/autoscaling"
  vpc = module.vpc.vpc.id
  ami = var.ami
  instance_type = var.instance_type
  pub_subnets = module.vpc.public_subnet_id
  pub_target_group = module.loadbalancer.pub_target_group.arn
  lb_dns = module.loadbalancer.lb_dns
  pri_subnets = module.vpc.private_subnet_id
  pri_target_group = module.loadbalancer.pri_target_group.arn
}

data "aws_instances" "pub_instances" {
  filter {
    name   = "tag:Name"
    values = ["pub-EC2"]
  }
  depends_on = [module.auto_scaling]
}
data "aws_instances" "pri_instances" {
  filter {
    name   = "tag:Name"
    values = ["pri-EC2"]
  }
  depends_on = [module.auto_scaling]
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  vpc = module.vpc.vpc.id
  pub_instances = data.aws_instances.pub_instances.ids
  pri_instances = data.aws_instances.pri_instances.ids
  public_subnets = module.vpc.pub_subnet
  public_subnet_id = module.vpc.public_subnet_id
  lb_type = var.lb_type
}


locals {
  public_ip_content = join("\n", [
    for idx, pub_ip in data.aws_instances.pub_instances.public_ips : 
    "public_ip_${idx + 1} : ${pub_ip}"
  ])

  private_ip_content = join("\n", [
    for idx, pri_ip in data.aws_instances.pri_instances.private_ips : 
    "private_ip_${idx + 1} : ${pri_ip}"
  ])

  combined_content = "${local.public_ip_content}\n${local.private_ip_content}"
}

resource "local_file" "ips" {
  filename = "ips.txt"
  content  = local.combined_content
}
