variable "name" {
  description = "RDS 리소스 이름 prefix (AWS 식별자)"
  type        = string
  default     = "sajo-db"
}

variable "db_name" {
  description = "MySQL 내부 database 이름"
  type        = string
  default     = "app"
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "username" {
  type = string
  default = "admin"
}

variable "password" {
  type      = string
  sensitive = true
}

variable "db_vpc_cidr" {
  description = "DB 전용 VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "db_subnet_prefix" {
  description = "DB Subnet prefix length"
  type        = number
  default     = 24
}