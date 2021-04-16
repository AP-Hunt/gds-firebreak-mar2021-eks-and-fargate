## See https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.deploy_env}-eks-log-group"
  retention_in_days = 3

  tags = merge(var.tags, {
    Name = "${var.deploy_env}-eks-log-group"
  })
}


resource "aws_iam_policy" "fargate_logging" {
  name = "${var.deploy_env}-fargate-logging"
  policy = file("../iam-policies/fargate-logging.json")
}

resource "aws_iam_role_policy_attachment" "attach_fargate_logging_to_fargate_role" {
  policy_arn = aws_iam_policy.fargate_logging.arn
  role = aws_iam_role.fargate_role.name
}
