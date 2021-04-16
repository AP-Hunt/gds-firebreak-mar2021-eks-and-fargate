module "infra" {
  source = "./infra"

  deploy_env = var.deploy_env
  tags = local.tags
}

module "cluster" {
  source = "./cluster"

  deploy_env = var.deploy_env
  tags = local.tags
  cluster_ca_data = module.infra.cluster_ca_data
  cluster_endpoint = module.infra.cluster_endpoint
  cluster_name = module.infra.cluster_name
  cluster_oidc_provider_arn = module.infra.cluster_oidc_provider_arn
  cluster_oidc_provider_url = module.infra.cluster_oidc_provider_url
  vpc_id = module.infra.vpc_id
  cloudwatch_logging_group_name = module.infra.cloudwatch_logging_group_name
}
