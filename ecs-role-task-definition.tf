data "aws_iam_policy" "ECStaskExecution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# data "aws_iam_policy" "ECSserviceAutoScale" {
#   arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingECSServicePolicy"
# }
data "template_file" "frontend" {
  template = file("./jsons/frontend.json.tpl")
  vars = {
    aws_ecr_repository = var.container_image.frontend
    name               = var.task_definition_name.frontend
    region             = var.region
    port               = var.container_port.frontend
    awslogs-group      = aws_cloudwatch_log_group.prodgroup.name
    tag                = var.ecr_tag.latest
  }
}

data "template_file" "backend" {
  template = file("./jsons/backend.json.tpl")
  vars = {
    aws_ecr_repository = var.container_image.backend
    name               = var.task_definition_name.backend
    region             = var.region
    port               = var.container_port.backend
    awslogs-group      = aws_cloudwatch_log_group.prodgroup.name
    tag                = var.ecr_tag.latest
  }
}
resource "aws_iam_role" "prod_ecs_task_role" {
  name               = "${var.environment}-role-ecsTaskRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role" "Prod_ecs_task_execution_role" {
  name               = "${var.environment}-role-ecsTaskExecutionRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# resource "aws_iam_policy" "dynamodb" {
#   name        = "${var.name}-task-policy-dynamodb"
#   description = "Policy that allows access to DynamoDB"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "dynamodb:CreateTable",
#                 "dynamodb:UpdateTimeToLive",
#                 "dynamodb:PutItem",
#                 "dynamodb:DescribeTable",
#                 "dynamodb:ListTables",
#                 "dynamodb:DeleteItem",
#                 "dynamodb:GetItem",
#                 "dynamodb:Scan",
#                 "dynamodb:Query",
#                 "dynamodb:UpdateItem",
#                 "dynamodb:UpdateTable"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }
# resource "aws_iam_policy" "secrets" {
#   name        = "${var.name}-task-policy-secrets"
#   description = "Policy that allows access to the secrets we created"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "AccessSecrets",
#             "Effect": "Allow",
#             "Action": [
#               "secretsmanager:GetSecretValue"
#             ],
#             "Resource": ${jsonencode(var.container_secrets_arns)}
#         }
#     ]
# }
# EOF
# }
resource "aws_iam_role_policy_attachment" "ECS-task-execution-attach" {
  role = aws_iam_role.Prod_ecs_task_execution_role.name

  policy_arn = data.aws_iam_policy.ECStaskExecution.arn
}
resource "aws_iam_role_policy_attachment" "s3-access" {
  role       = aws_iam_role.prod_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.dynamodb.arn
# }
# resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-secrets" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = aws_iam_policy.secrets.arn
# }
#==========CloudWatch Log Group for ECS CLuster Log============
resource "aws_cloudwatch_log_group" "prodgroup" {
  name = "/ecs/task-${var.environment}"
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
#===============Task Definition=============
resource "aws_ecs_task_definition" "frontend" {
  family                   = var.task_definition_name.frontend
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.Prod_ecs_task_execution_role.arn
  #======== below parameter is optinal use when you want to access other aws services like dynamodb etc. here i attache same policy as above
  task_role_arn = aws_iam_role.prod_ecs_task_role.arn
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
  container_definitions = data.template_file.frontend.rendered
}

resource "aws_ecs_task_definition" "backend" {
  family                   = var.task_definition_name.backend
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.Prod_ecs_task_execution_role.arn
  #======== below parameter is optinal use when you want to access other aws services like dynamodb etc. here i attache same policy as above
  task_role_arn = aws_iam_role.prod_ecs_task_role.arn
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
  container_definitions = data.template_file.backend.rendered
}