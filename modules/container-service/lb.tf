resource "aws_security_group" "sg-lb" {
  name        = "${var.account}-sg-${var.env}-lb-${var.resource_identifier}"
  description = "Allow HTTP(S) inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ips
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ips
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.account}-sg-${var.env}-lb-${var.resource_identifier}",
    Environment = var.env,
    System      = var.system,
    Component   = var.app
  }
}




resource "aws_lb" "lb" {
  name               = "${var.account}-lb-${var.env}-${var.resource_identifier}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-lb.id]
  subnets            = var.lb_subnets

  enable_deletion_protection = true

  access_logs {
    bucket  = var.logs_bucket
    enabled = true
  }

  tags = {
    Name        = "${var.account}-lb-${var.env}-${var.resource_identifier}"
    Environment = var.env
    System      = var.system
    Component   = var.app
  }
}

resource "aws_lb_target_group" "lb-targetgroup" {
  name                 = "${var.account}-lb-${var.env}-${var.resource_identifier}-targetgroup"
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/api/health"
    port                = "3000"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }

  tags = {
    Name        = "${var.account}-lb-${var.env}-${var.resource_identifier}-targetgroup"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lb_listener" "lb-listener-" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name        = "${var.account}-lb-${var.env}-${var.resource_identifier}-http-listener"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lb_listener" "lb-listener-https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-targetgroup.arn
  }
  tags = {
    Name        = "${var.account}-lb-${var.env}-${var.resource_identifier}-https-listener"
    Environment = var.env
    System      = var.system
  }
}


output "lb_dns" {
  value = aws_lb.lb.dns_name

}

output "lb_arn" {
  value = aws_lb.lb.id

}

output "lb_suffix" {
  value = aws_lb.lb.arn_suffix

}

output "tg_suffix" {
  value = aws_lb_target_group.lb-targetgroup.arn_suffix

}