resource "aws_route53_health_check" "cloudfront" {
  count = var.enable_failover ? 1 : 0

  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "primary" {
  count = var.enable_failover ? 1 : 0

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

  health_check_id = aws_route53_health_check.cloudfront[0].id
}

resource "aws_route53_record" "secondary" {
  count = var.enable_failover ? 1 : 0

  depends_on = [
    aws_route53_record.primary
  ]

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
