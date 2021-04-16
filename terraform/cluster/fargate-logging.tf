## See https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html
resource "kubernetes_namespace" "observability" {
  metadata {
    name = "aws-observability"
    labels = {
      "aws-observability": "enabled"
    }
  }
}

resource "kubernetes_config_map" "logging_config_map" {
  metadata {
    name = "aws-logging"
    namespace = kubernetes_namespace.observability.metadata[0].name
    labels = {}
  }

  data = {
    "output.conf" = <<CONF
[OUTPUT]
  Name cloudwatch_logs
  Match   *
  region eu-west-1
  log_group_name ${var.cloudwatch_logging_group_name}
  log_stream_prefix fargate-pod-
  auto_create_group false
CONF
  }
}
