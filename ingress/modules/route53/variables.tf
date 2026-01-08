variable "zone_name" {
  description = "banson.shop"
}

variable "domain_name" {
  description = "rosa.banson.shop"
}

variable "cf_domain_name" {
  description = "CloudFront distribution domain"
}

variable "cf_zone_id" {
  description = "CloudFront hosted zone id"
}

variable "local_public_ip" {
  description = "DR local environment public IP"
}