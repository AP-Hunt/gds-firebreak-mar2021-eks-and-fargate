variable "deploy_env" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "cluster_name" {
    type = string
}

variable "cluster_endpoint" {
    type = string
}

variable "cluster_ca_data" {
    type = string
}

variable "cluster_oidc_provider_arn" {
    type = string
}

variable "cluster_oidc_provider_url" {
    type = string
}

variable "cloudwatch_logging_group_name" {
    type = string
}
