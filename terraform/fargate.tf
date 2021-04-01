resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  fargate_profile_name = "${var.deploy_env}-fp-kube-system"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn

  subnet_ids = [for name, cfg in local.subnet_config: aws_subnet.subnets[name].id if cfg.public == false]

  selector {
    namespace = "kube-system"
  }

  tags = merge(local.tags, {
    Name = "${var.deploy_env}-fp-kube-system"
  })

  depends_on = [aws_eks_cluster.eks_cluster]

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "aws_eks_fargate_profile" "apps" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  fargate_profile_name = "${var.deploy_env}-fp-apps"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn

  subnet_ids = [for name, cfg in local.subnet_config: aws_subnet.subnets[name].id if cfg.public == false]

  selector {
    namespace = "apps"
  }

  tags = merge(local.tags, {
    Name = "${var.deploy_env}-fp-apps"
  })

  depends_on = [aws_eks_cluster.eks_cluster]

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# The role that the AWS Fargate profiles will run as
resource "aws_iam_role" "fargate_role" {
  name = "${var.deploy_env}-fargate-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = local.tags
}

# Attach the managed EKS Fargate pod execution role to the fargate role
resource "aws_iam_role_policy_attachment" "fargate_role_AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_role.name
}

