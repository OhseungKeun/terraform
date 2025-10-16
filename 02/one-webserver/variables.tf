########################
# Variable 지정
########################
variable "my_region" {
  description = "AWS My Region"
  type        = string
  default     = "us-east-2"
}

variable "my_ami_ubuntu2404" {
  description = "AWS MY AMI - ubuntu 24.04 LTS(x86_64)"
  type        = string
  default     = "ami-0cfde0ea8edd312d4"
}

variable "my_instance_type" {
  description = "My Ubuntu instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_userdata_changed" {
  description = "User Data replace on change"
  type        = bool
  default     = true
}

variable "my_webserver_tags" {
  description = "My webserver Tags"
  type        = map(string)
  default = {
    Name = "myweb-server"
  }
}

variable "my_sg_tags" {
  description = "My Security Group Tags"
  type        = map(string)
  default = {
    Name = "allow_80"
  }
}

variable "my_http_port" {
  description = "my HTTP port"
  type        = number
  default     = 80
}