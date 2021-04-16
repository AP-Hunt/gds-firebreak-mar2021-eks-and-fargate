output "aws_lb_controller_role_arn" {
  value = module.cluster.aws_lb_controller_role_arn
}

output "vpc_id" {
  value = module.infra.vpc_id
}

output "egress_ip" {
  value = module.infra.egress_ip
}

output "cluster_name" {
  value = module.infra.cluster_name
}

output "cluster_endpoint" {
  value = module.infra.cluster_endpoint
}

output "cluster_ca_data" {
  value = module.infra.cluster_ca_data
}

output "apps_domain_cert_validation_records" {
  value = module.infra.apps_domain_cert_validation_records
}

output "apps_domain_cert_arn" {
  value = module.infra.apps_domain_cert_arn
}

output "aws_vpc_cni_role_arn" {
  value = module.cluster.vpc_cni_role_arn
}
