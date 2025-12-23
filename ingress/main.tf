# openshift ingress(Rosa Cluster)에 의해 생성된 NLB 태그 조회
data "aws_lb" "rosa_nlb" {
  tags = {
    "kubernetes.io/service-name" = "openshift-ingress/router-default"
  }
}

# NLB에 속한 subnet 조회
data "aws_subnet" "nlb" {
  for_each = toset(data.aws_lb.rosa_nlb.subnets)
  id       = each.value
}

# NLB가 위치한 VPC 정보 조회(여러 서브넷이 존재하더라도 하나의 VPC만 조회)
data "aws_vpc" "this" {
  id = one(distinct([
    for s in data.aws_subnet.nlb : s.vpc_id
  ]))
}

# NLB에 의해 생성된 ENI(Network Interface) 목록 조회
data "aws_network_interfaces" "nlb" {
  filter {
    name   = "description"
    values = ["ELB net/${data.aws_lb.rosa_nlb.name}/*"]
  }
}

# 위에서 조회한 ENI를 기반으로 상세 내용 조회
data "aws_network_interface" "nlb" {
  for_each = toset(data.aws_network_interfaces.nlb.ids)
  id       = each.value
}

locals {
# NLB가 사용하는 private IP 조회
# ALB Target Group에서 IP 타켓으로 사용(ALB -> NLB)
  nlb_private_ips = [
    for eni in data.aws_network_interface.nlb : eni.private_ip
  ]

  vpc_id        = data.aws_vpc.this.id
  subnet_ids    = data.aws_lb.rosa_nlb.subnets
  subnet_cidrs  = [
    for s in data.aws_subnet.nlb : s.cidr_block
  ]
}

# ALB 생성
# NLB의 Private IP를 Target Group에 등록
module "alb" {
  source = "./modules/alb"

  name       = var.alb_name
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids
  nlb_target_ips = local.nlb_private_ips
}

# Route53 생성
# ALB DNS 이름을 도메인 레코드에 등록
module "route53" {
  source = "./modules/route53"

  domain_name  = var.domain_name
  record_name   = var.route53_record_name

  alb_dns_name  = module.alb.alb_dns_name
  alb_zone_id   = module.alb.alb_zone_id
}

# WAF 생성
module "waf" {
  source = "./modules/waf"

  name    = "${var.alb_name}-waf"
  alb_arn = module.alb.alb_arn
}