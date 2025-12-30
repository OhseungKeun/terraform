# ROSA Local Terraform State 참조
data "terraform_remote_state" "rosa" {
  backend = "local"

  config = {
    path = "../rosa/terraform.tfstate"
  }
}

# ROSA에서 가져온 값들 local에 저장
locals {
  rosa_vpc_id                 = data.terraform_remote_state.rosa.outputs.vpc_id
  rosa_vpc_cidr               = data.terraform_remote_state.rosa.outputs.vpc_cidr
  rosa_private_route_table_id = data.terraform_remote_state.rosa.outputs.private_route_table_id
  rosa_node_sg_ids            = data.terraform_remote_state.rosa.outputs.node_security_group_ids
}

# AZ 자동 선택
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  rds_azs = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )
}

# DB Subnet CIDR
locals {
  rds_subnet_cidrs = [
    for idx in range(length(local.rds_azs)) :
    cidrsubnet(local.rosa_vpc_cidr, 8, idx + 200)
  ]
}

# DB 전용 Private Subnet 생성
resource "aws_subnet" "db" {
  for_each = {
    for idx, az in local.rds_azs :
    az => local.rds_subnet_cidrs[idx]
  }

  vpc_id            = local.rosa_vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-db-${each.key}"
    Tier = "database"
  }
}

# DB Route table 연결
resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = local.rosa_private_route_table_id
}

# RDS Subnet Group 생성
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.db : s.id]

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

# RDS Security Group (ROSA Woker Node SG만 허용)
resource "aws_security_group" "rds" {
  name_prefix = "${var.name}-rds-"
  vpc_id      = local.rosa_vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = local.rosa_node_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

# RDS MySQL Instance 생성(사양)
resource "aws_db_instance" "this" {
  identifier = var.name

  engine         = "mysql"
  engine_version = "8.0"

  instance_class    = var.instance_class
  allocated_storage = 100
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.username
  password = var.password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  publicly_accessible    = false

  multi_az            = true
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = var.name
  }
}