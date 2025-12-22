variable "domain_name" {
  description = "Public hosted zone name"
  type        = string
  default     = "banson.shop"
}

variable "route53_record_name" {
  description = "ALB record name"
  type        = string
  default     = "rosa"
}

variable "alb_name" {
  description = "ALB name"
  type        = string
  default     = "rosa-alb"
}