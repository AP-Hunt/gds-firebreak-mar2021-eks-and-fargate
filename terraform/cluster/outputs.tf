output "aws_lb_controller_role_arn" {
  value = aws_iam_role.aws_lb_controller.arn
}

output "vpc_cni_role_arn" {
  value = aws_iam_role.aws_vpc_cni.arn
}
