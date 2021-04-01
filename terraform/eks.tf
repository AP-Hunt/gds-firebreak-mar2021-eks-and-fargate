# EKS is Amazon's Elastic Kubernetes Service
resource "aws_eks_cluster" "eks_cluster" {
  name = local.eks_cluster_name

  # The AWS IAM role which the cluster will run as
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [ for _, subnet in aws_subnet.subnets: subnet.id ]
  }

  tags = merge(local.tags, {
    Name = local.eks_cluster_name
  })

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_role_AmazonEKSClusterPolicy,
  ]

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

# The role as which the EKS cluster will run
resource "aws_iam_role" "eks_role" {
  name = "${var.deploy_env}-eks-role"
  # Allow Amazon EKS to assume this role on our behalf
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = local.tags
}

# Attach the managed EKS Cluster IAM Policy to the cluster role
resource "aws_iam_role_policy_attachment" "eks_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}
