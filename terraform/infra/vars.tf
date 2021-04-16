variable "deploy_env" {
    type = string
}

variable "tags" {
    type = map(string)
    default = {}
}

locals {
    eks_cluster_name = "${var.deploy_env}-eks-cluster"
}
