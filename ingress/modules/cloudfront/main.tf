resource "aws_cloudfront_distribution" "this" {
  enabled = true
  comment = var.name

  aliases = [var.domain_name]

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "rosa-nlb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "rosa-nlb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS",
      "POST", "PUT", "PATCH", "DELETE"
    ]

    cached_methods = ["GET", "HEAD"]

    # ✅ 정책 기반 (정답)
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ✅ Custom SSL (ACM us-east-1)
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = var.web_acl_arn
}
