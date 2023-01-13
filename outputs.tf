output "VPC-ID" {
  value = aws_vpc.prodvpc.id
}

output "VPC-IGW" {
  value = aws_internet_gateway.prod_igw.id
}

output "prod-public1" {
  value = aws_subnet.prod_public1.id
}

output "prod-public2" {
  value = aws_subnet.prod_public2.id
}

output "prod-private1" {
  value = aws_subnet.prod_private1.id
}

output "prod-private2" {
  value = aws_subnet.prod_private2.id
}

output "security_group_ECS" {
  value = aws_security_group.Prod_ecsSG.id
}

output "security_group_RDS" {
  value = aws_security_group.Prod_RDS_SG.id
}


output "ecs_cluster" {
  value = aws_ecs_cluster.prod_mydemo.id
}


