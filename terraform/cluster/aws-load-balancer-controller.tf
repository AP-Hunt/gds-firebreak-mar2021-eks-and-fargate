# The role as which the AWS Load Balancer Controller will run
resource "aws_iam_role" "aws_lb_controller" {
  name = "${var.deploy_env}-awslbcontroller-role"
  path = "/"
  description = "IAM role which the AWS K8s Load Balancer Controller will assume"

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
          "${var.cluster_oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-awslbcontroller-role"
  })
}

# IAM policy defining the actions the Load Balancer Controller role is
# allowed to carry out
resource "aws_iam_policy" "aws_lb_controller" {
  name = "${var.deploy_env}-awslbcontroller"
  path = "/"
  description = "Allows the AWS Load Balancer Controller for K8s to do its thing"

  policy = file("../iam-policies/aws-load-balancer-controller.json")
}


resource "aws_iam_role_policy_attachment" "aws_lb_controller_policy_attachment" {
  policy_arn = aws_iam_policy.aws_lb_controller.arn
  role = aws_iam_role.aws_lb_controller.name
}

# The Kubernetes service account to be used by the load balancer controller
resource "kubernetes_service_account" "load_balancer_service_account" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
    }
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}

# Use a null resource to install the Custom Resource Definitions needed
# for the AWS Load Balancer Controller, before the Helm chart is installed
resource "null_resource" "aws_load_balancer_controller_crds" {
  triggers = {
    eks_endpoint = var.cluster_endpoint
  }

  provisioner "local-exec" {
    command = <<SCRIPT
      aws eks update-kubeconfig \
        --name "${var.cluster_name}" \
        --alias "${var.cluster_name}" && \
      kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
SCRIPT

  }
}

# Deploy the Helm chart for the AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [null_resource.aws_load_balancer_controller_crds]

  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  namespace = "kube-system"

  values = [<<YAML
---
vpcId: "${var.vpc_id}"
clusterName: "${var.cluster_name}"
serviceAccount:
  create: false
  name: "${kubernetes_service_account.load_balancer_service_account.metadata[0].name}"
region: eu-west-1
defaultTags: ${jsonencode(var.tags)}
YAML
]
}
