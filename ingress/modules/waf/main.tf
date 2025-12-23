resource "aws_wafv2_web_acl" "this" {
  name  = var.name
  scope = "REGIONAL"

# 룰에 위반되지 않으면 요청
  default_action {
    allow {}
  }

# WAF 전체에 대한 모니터링 설정
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

# AWS의 기본 RuleSet 적용(SQL Injection, XSS 등)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

# AWS의 Manged Ruleset 적용(악성 패턴, 비정상 입력값 등)
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BadInputs"
      sampled_requests_enabled   = true
    }
  }
}

# WAF을 ALB로 연결
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}