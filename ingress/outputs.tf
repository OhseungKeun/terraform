output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "fqdn" {
  value = module.route53.fqdn
}