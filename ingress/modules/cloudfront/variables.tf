variable "name" {}
variable "origin_domain_name" {}
variable "web_acl_arn" {}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (us-east-1)"
}

variable "domain_name" {
  description = "Alternate domain name for CloudFront (e.g. rosa.banson.shop)"
}