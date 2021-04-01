resource "kubernetes_namespace" "apps" {
  depends_on = [aws_eks_cluster.eks_cluster]
  metadata {
    name = "apps"
  }
}
