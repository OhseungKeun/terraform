resource "aws_route53_zone" "this" {
  name = var.zone_name
}

resource "aws_route53_health_check" "cloudfront" {
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"
  set_identifier = "cloudfront-primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = var.cf_domain_name
    zone_id                = var.cf_zone_id
    evaluate_target_health = false
  }

  health_check_id = aws_route53_health_check.cloudfront.id
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"
  set_identifier = "local-secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  ttl     = 30
  records = [var.local_public_ip]
}