output "rds_endpoint" {
  description = "RDS 접속 엔드포인트"
  value       = aws_db_instance.this.endpoint
}

output "rds_subnet_ids" {
  value = [for s in aws_subnet.db : s.id]
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}

