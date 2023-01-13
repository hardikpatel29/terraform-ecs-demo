/*
data "aws_iam_policy" "ECSserviceAutoScale" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingECSServicePolicy"
}

resource "aws_iam_role" "prod_ecs_service_auto_scale" {
  name               = "${var.environment}-role_ecs_service_auto_scale"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "prod_ecs_service_auto_scale_attach" {
  role = aws_iam_role.prod_ecs_service_auto_scale.name

  #policy_arn = data.aws_iam_policy.ECSserviceAutoScale.arn
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingECSServicePolicy"

}
*/

resource "aws_ecs_cluster" "prod_mydemo" {
  name = "${var.environment}-cluster"
  setting {
    name  = "containerInsights"
    value = var.container_insight_status.disable
  }
  tags = {
    Environment = var.environment
    Team        = "Network"
  }

}


