provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region

  default_tags {
    tags = {

      Owner   = "HardikPatel"
      Project = "MyDemoProject"
    }
  }
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "prodvpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prodvpc.id
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_subnet" "prod_public1" {
  cidr_block              = var.public_subnet_cidr_blocks[0]
  vpc_id                  = aws_vpc.prodvpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_subnet" "prod_public2" {
  cidr_block              = var.public_subnet_cidr_blocks[1]
  vpc_id                  = aws_vpc.prodvpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_subnet" "prod_private1" {
  cidr_block              = var.private_subnet_cidr_blocks[0]
  vpc_id                  = aws_vpc.prodvpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_subnet" "prod_private2" {
  cidr_block              = var.private_subnet_cidr_blocks[1]
  vpc_id                  = aws_vpc.prodvpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_route_table" "Prod_Pub_Route" {
  vpc_id = aws_vpc.prodvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_route_table" "Prod_Pri_Route" {
  vpc_id = aws_vpc.prodvpc.id
  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}
resource "aws_route_table_association" "prod_public1" {
  subnet_id      = aws_subnet.prod_public1.id
  route_table_id = aws_route_table.Prod_Pub_Route.id
}
resource "aws_route_table_association" "prod_public2" {
  subnet_id      = aws_subnet.prod_public2.id
  route_table_id = aws_route_table.Prod_Pub_Route.id
}
resource "aws_route_table_association" "prod-Private1" {
  subnet_id      = aws_subnet.prod_private1.id
  route_table_id = aws_route_table.Prod_Pri_Route.id
}
resource "aws_route_table_association" "prod_private2" {
  subnet_id      = aws_subnet.prod_private2.id
  route_table_id = aws_route_table.Prod_Pri_Route.id
}

#======SecurityGroup=======

resource "aws_security_group" "Prod_ecsSG" {
  name        = "Prod-ecsSG"
  description = "Web Security Group"
  vpc_id      = aws_vpc.prodvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "Prod_RDS_SG" {
  name        = "Prod-RDS-SG"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.prodvpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]

  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



