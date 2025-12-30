# 소개

## 설명

이 레파지토리는 Rosa Cluster, Route53 + ALB(WAF), RDS를 구축하는 Terraform Code이다.

워크 플로우는 사용자 요청 -> Route53 -> ALB(WAF) -> Rosa Ingress(Router / Service) -> Pod 흐름이다.

## 사용법

### Rosa Cluster 구축

1. Offline Key export

$ export <offline_key>

2. Rosa Cluster 구축

$ cd rosa

$ terraform init

$ terraform plan

$ terraform apply -auto-approve


### ALB + WAF + Route53 구축

$ cd ingress

$ terraform init

$ terraform plan

$ terraform apply -auto-approve

### DB 구축

$ cd rds

$ terraform init

$ terraform plan

$ terraform apply -auto-approve