variable "name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

variable "nlb_target_ips" {
  type = list(string)
}