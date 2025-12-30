output "vpc_id" {
  value = module.vpc[0].vpc_id
}

output "vpc_cidr" {
  value = module.vpc[0].vpc_cidr_block
}

output "private_route_table_id" {
  value = module.vpc[0].private_route_table_ids[0]
}

output "node_security_group_ids" {
  value = data.aws_security_groups.rosa_nodes.ids
}