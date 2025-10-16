########################
# Output Variable 정의
########################
output "myweb_public_ip" {
  description = "My webserver Public IP"
  value       = aws_instance.example.public_ip
}

# [FILE] terraform.tfstate
# tf state list
# tf state show aws_instance.example
#  -> public_ip, public_dns
#  -> aws_instance.example.public_dns

output "myweb_public_dns" {
  description = "My webserver Public DNS"
  value       = aws_instance.example.public_dns
}

# tf output
# tf output myweb_public_dns
# tf output -raw myweb_public dns
# curl $(tf output -raw myweb_public dns)