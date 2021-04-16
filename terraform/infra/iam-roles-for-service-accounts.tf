# Amazon EKS has a feature called IAM Roles for Service Accounts
# which allows Kubernetes service accounts be associated with an
# AWS IAM role. This lets service accounts provides AWS persmissions
# to pods.
# https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html

resource "aws_iam_role" "eks_service_accounts_role" {
  name = "${var.deploy_env}-eks-service-accounts-role"
  # Allow Amazon EKS to assume this role on our behalf
  assume_role_policy = data.aws_iam_policy_document.eks_role_assume_role_policy.json

  tags = var.tags
}

# In order for a K8s service account to assume a role, it must
# be able to authenticate with IAM through an OIDC provider
resource "aws_iam_openid_connect_provider" "cluster_oidc_provider" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_issuer_cert.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks_oidc_issuer_cert" {
  depends_on = [aws_eks_cluster.eks_cluster]
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"

    condition {
      test = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster_oidc_provider.url, "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.cluster_oidc_provider.arn]
      type = "Federated"
    }
  }
}
