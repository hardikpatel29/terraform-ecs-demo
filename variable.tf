variable "aws_access_key" {
  type = string
}
variable "aws_secret_key" {
  type = string
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "region" {
  type = string
}
variable "public_subnet_cidr_blocks" {
  default = ["10.0.0.0/24", "10.0.2.0/24"]
  type    = list(any)
}
variable "private_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.3.0/24"]
  type    = list(any)
}
variable "alb_tls_cert_arn" {

  description = "ARN id which LB use for https"
}
variable "domain" {
  type = map(string)
}
variable "container_insight_status" {
  type = map(string)
}
variable "ecs_service_launch_type" {
  type = map(string)
}
variable "ecs_service_strategy" {
  type = map(string)
}
variable "ecs_service_desired_count" {
  type = map(string)

}
variable "task_definition_name" {
  type = map(string)

}
variable "container_port" {
  type = map(string)
}
variable "container_cpu" {
  description = "The number of cpu units used by the task"
}
variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
}
variable "container_image" {
  type = map(string)
}
variable "ecr_tag" {
  type = map(string)
}
variable "ECS_Service_Scale_Role" {
  type = string
}

variable "ecs_service_max_capacity" {
  type = string
}
variable "ecs_service_min_capacity" {
  type = string
}
variable "adjustment_type" {
  type = map(string)
}
variable "metric_aggregation_type" {
  type = map(string)
}

variable "threshold_up" {
  default = "75"
}

variable "threshold_down" {
  default = "25"
}

variable "evaluation_periods" {
  default = "4"
}

variable "statistic" {
  default = "Average"
}

variable "period_down" {
  default = "120"
}

variable "period_up" {
  default = "60"
}

variable "scale_up_adjustment" {
  type    = number
  default = 1
}

variable "scale_up_cooldown" {
  type    = number
  default = 60
}

variable "scale_down_adjustment" {
  type    = number
  default = -1

}

variable "scale_down_cooldown" {
  type    = number
  default = 300
}

variable "scale_up_alarm" {
  type = map(string)
}

variable "scale_down_alarm" {
  type = map(string)
}
variable "bucket_name_prefix" {
  //default = "mycloud"
  type = map(string)
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type      = string
  sensitive = true
}

variable "db_password" {
  sensitive = true
  type      = string
}