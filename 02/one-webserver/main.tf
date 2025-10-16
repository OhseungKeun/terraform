# provider 설정
provider "aws" {
  region = var.my_region
}

# ec2 instance 생성
# * webserver 구성 => user_data
resource "aws_instance" "example" {
  ami                         = var.my_ami_ubuntu2404
  instance_type               = var.my_instance_type
  vpc_security_group_ids      = [aws_security_group.allow_80.id]
  user_data_replace_on_change = var.my_userdata_changed
  tags                        = var.my_webserver_tags

  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt -y install apache2
echo "WEB" | sudo tee /var/www/html/index.html
sudo systemctl enable --now apache2
EOF
}

#
# security group 생성
#
resource "aws_security_group" "allow_80" {
  name        = "allow_80"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = var.my_sg_tags
}

#
# security group rule 설정
#
resource "aws_vpc_security_group_ingress_rule" "allow_80_ipv4" {
  security_group_id = aws_security_group.allow_80.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.my_http_port
  to_port           = var.my_http_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_80.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}