resource "aws_acm_certificate" "apps_cert" {
  domain_name = "*.k8s.andyhunt.me"
  validation_method = "DNS"

  tags = merge(local.tags, {
    Name = "${var.deploy_env}-apps-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}
