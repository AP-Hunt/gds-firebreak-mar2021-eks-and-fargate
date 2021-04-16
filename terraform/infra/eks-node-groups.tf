# The EKS node group to be attached to the EKS cluster
resource "aws_eks_node_group" "spot_instance_node_group" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "${aws_eks_cluster.eks_cluster.name}-ng-spot-instances"
  node_role_arn = aws_iam_role.eks_node_group.arn
  subnet_ids = [for _, subnet in local.private_subnets : subnet.id]

  # Ensure that reasonably cheap spot instances are used
  capacity_type = "SPOT"
  instance_types = ["t3.small", "t3.medium"]

  tags = merge(var.tags, {
      Name = "${aws_eks_cluster.eks_cluster.name}-ng-spot-instances"
  })

  scaling_config {
    desired_size = 2
    max_size = 4
    min_size = 2
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

# The AWS IAM Role to be used for controlling EKS node groups
resource "aws_iam_role" "eks_node_group" {
  name = "${var.deploy_env}-eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}
