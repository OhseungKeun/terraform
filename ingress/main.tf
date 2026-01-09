############################
# ROSA Ingress NLB 조회
############################
data "aws_lb" "rosa_ingress" {
  tags = {
    "kubernetes.io/service-name" = "openshift-ingress/router-default"
  }
}

############################
# Route53 (Hosted Zone + Record)
############################
module "route53" {
  source = "./modules/route53"

  zone_name      = var.zone_name       # banson.shop
  domain_name    = var.domain_name     # rosa.banson.shop

  # Primary (CloudFront)
  cf_domain_name = module.cloudfront.domain_name
  cf_zone_id     = module.cloudfront.hosted_zone_id

  # Secondary (Local DR)
  local_public_ip = var.local_public_ip

  enable_failover = var.enable_failover
}

############################
# ACM (us-east-1, CloudFront용)
############################
module "acm" {
  source = "./modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  domain_name    = var.domain_name
  hosted_zone_id = module.route53.zone_id
}

############################
# WAF (CloudFront scope → us-east-1)
############################
module "waf" {
  source = "./modules/waf"

  providers = {
    aws = aws.us_east_1
  }

  name = var.name
}

############################
# CloudFront
############################
module "cloudfront" {
  source = "./modules/cloudfront"

  name                 = var.name
  domain_name          = var.domain_name 
  origin_domain_name   = data.aws_lb.rosa_ingress.dns_name
  web_acl_arn          = module.waf.web_acl_arn
  acm_certificate_arn  = module.acm.certificate_arn
}
