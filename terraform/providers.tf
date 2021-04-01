terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

data "aws_eks_cluster" "cluster_data" {
  depends_on = [aws_eks_cluster.eks_cluster]
  name = aws_eks_cluster.eks_cluster.name
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster_data.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster_data.name]
    command = "aws"
  }
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster_data.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_data.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.cluster_data.name]
      command = "aws"
    }
  }
}
