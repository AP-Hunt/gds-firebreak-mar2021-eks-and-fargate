output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "egress_ip" {
  value = aws_nat_gateway.nat_gateway.public_ip
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster_oidc_provider.arn
}

output "cluster_oidc_provider_url" {
  value = aws_iam_openid_connect_provider.cluster_oidc_provider.url
}

output "apps_domain_cert_validation_records" {
  value = [for dvo in aws_acm_certificate.apps_cert.domain_validation_options : {
    name = dvo.resource_record_name,
    record = dvo.resource_record_value,
    type = dvo.resource_record_type
  }]
}

output "apps_domain_cert_arn" {
  value = aws_acm_certificate.apps_cert.arn
}

output "cloudwatch_logging_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}
