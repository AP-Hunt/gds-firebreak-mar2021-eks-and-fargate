# The role as which the AWS VPC CNI will run
resource "aws_iam_role" "aws_vpc_cni" {
  name = "${var.deploy_env}-vpc-cni-role"
  path = "/"
  description = "IAM role which the AWS VPC CNI will assume"

  # Allow only AWS load balancer controllers
  # from the current cluster to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.cluster_oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.cluster_oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-node"
        }
      }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-awslbcontroller-role"
  })
}

# Attach the managed EKS Cluster IAM Policy to the cluster role
resource "aws_iam_role_policy_attachment" "eks_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aws_vpc_cni.name
}
