data "aws_lb" "rosa_nlb" {
  tags = {
    "kubernetes.io/service-name" = "openshift-ingress/router-default"
  }
}

data "aws_subnet" "nlb" {
  for_each = toset(data.aws_lb.rosa_nlb.subnets)
  id       = each.value
}

data "aws_vpc" "this" {
  id = one(distinct([
    for s in data.aws_subnet.nlb : s.vpc_id
  ]))
}

data "aws_network_interfaces" "nlb" {
  filter {
    name   = "description"
    values = ["ELB net/${data.aws_lb.rosa_nlb.name}/*"]
  }
}
data "aws_network_interface" "nlb" {
  for_each = toset(data.aws_network_interfaces.nlb.ids)
  id       = each.value
}

locals {
  nlb_private_ips = [
    for eni in data.aws_network_interface.nlb : eni.private_ip
  ]

  vpc_id        = data.aws_vpc.this.id
  subnet_ids    = data.aws_lb.rosa_nlb.subnets
  subnet_cidrs  = [
    for s in data.aws_subnet.nlb : s.cidr_block
  ]
}

module "alb" {
  source = "./modules/alb"

  name       = var.alb_name
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids
  nlb_target_ips = local.nlb_private_ips
}

module "route53" {
  source = "./modules/route53"

  domain_name  = var.domain_name
  record_name   = var.route53_record_name

  alb_dns_name  = module.alb.alb_dns_name
  alb_zone_id   = module.alb.alb_zone_id
}

module "waf" {
  source = "./modules/waf"

  name    = "${var.alb_name}-waf"
  alb_arn = module.alb.alb_arn
}