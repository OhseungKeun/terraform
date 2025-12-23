# Route53 Public Zone 생성
resource "aws_route53_zone" "public" {
  name = var.domain_name
}

# ALB를 가르키는 DNS 레코드 생성

resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.public.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}