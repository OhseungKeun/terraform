##################################
# 작업 순서
# 1. VPC 생성
# 2. IGW  생성 및 VPC 연결
# 3. public subnet 생성
# 4. route table 생성 및 public subnet에 연결
# 5. Security Group 생성
# 6. Security Group Rule 생성
# 7. EC2 생성
##################################

provider "aws" {
  region = "us-east-2"
}

#
# 1. VPC 생성
#
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  # DNS 호스트 이름 활성화
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "myVPC"
  }
}

#
# 2. IGW  생성 및 VPC 연결
# 
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

#
# 3. public subnet 생성
#
resource "aws_subnet" "myPubSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  # 퍼블릭 IPv4 주소 자동 할당 활성화
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

#
# 4. route table 생성 및 public subnet에 연결
#
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  # 라우팅 테이블 추가
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}

# 서브넷 연결
resource "aws_route_table_association" "myPubRTassoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

#
# 5. Security Group 생성
#
resource "aws_security_group" "mySecurity" {
  name        = "mySecurity"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySecurity"
  }
}

#
# 6. Security Group Rule 생성
#
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#
# 7. EC2 생성
#
resource "aws_instance" "myEC2" {
  ami           = "ami-077b630ef539aa0b5"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.myPubSN.id

  user_data = <<EOF
#!/bin/bash
dnf -y install httpd mod_ssl
echo "MyWEB" > /var/www/html/index.html
systemctl enable --now httpd 
EOF

  vpc_security_group_ids      = [aws_security_group.mySecurity.id]
  user_data_replace_on_change = true

  tags = {
    Name = "myweb-server"
  }
}