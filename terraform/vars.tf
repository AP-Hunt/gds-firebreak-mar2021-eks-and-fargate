variable "deploy_env" {
    type = string
}

locals {
    cost_allocation_tag = "${var.deploy_env}-eks"
    tags = {
        "chargeable_entity" = local.cost_allocation_tag
        "deploy_env" = var.deploy_env
    }
    eks_cluster_name = "${var.deploy_env}-eks-cluster"
}
