resource "aws_lb" "prod_lb" {
  name               = "${var.environment}-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Prod_ecsSG.id]
  subnets            = [aws_subnet.prod_public1.id, aws_subnet.prod_public2.id]

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}

resource "aws_lb_target_group" "prod_frontend" {
  name        = "${var.environment}-frontend"
  port        = var.container_port.frontend
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prodvpc.id
  target_type = "ip"



  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}


resource "aws_lb_target_group" "prod_backend" {
  name = "${var.environment}-backend"

  port        = var.container_port.backend
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prodvpc.id
  target_type = "ip"



  tags = {
    Environment = var.environment
    Team        = "Network"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod_lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.prod_lb.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.alb_tls_cert_arn

  default_action {
    #type = "redirect"
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "503"
    }
  }
}


resource "aws_lb_listener_rule" "prod_frontend_Rule" {
  listener_arn = aws_lb_listener.https.arn
  #priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_frontend.arn
  }
  condition {
    host_header {
      values = [var.domain.admin]
    }
  }
}



resource "aws_lb_listener_rule" "prod_backend_rule" {
  listener_arn = aws_lb_listener.https.arn
  #priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_backend.arn
  }
  condition {
    host_header {
      values = [var.domain.api]
    }
  }
}
