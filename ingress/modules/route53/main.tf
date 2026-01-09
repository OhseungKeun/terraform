resource "aws_route53_zone" "this" {
  name = var.zone_name
}

resource "aws_route53_record" "simple" {
  count = var.enable_failover ? 0 : 1

  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cf_domain_name
    zone_id                = var.cf_zone_id
    evaluate_target_health = false
  }
}
