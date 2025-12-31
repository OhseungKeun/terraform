########################
# ALB Security Group
########################
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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

########################
# ALB
########################
resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = false

  subnets         = var.subnet_ids
  security_groups = [aws_security_group.alb.id]
}

########################
# ROSA Ingress NLB 자동 조회
########################
data "aws_lb" "rosa_ingress" {
  tags = {
    "kubernetes.io/service-name" = "openshift-ingress/router-default"
  }
}

########################
# NLB ENI 조회
########################
data "aws_network_interfaces" "rosa_ingress" {
  filter {
    name   = "description"
    values = ["ELB net/*${data.aws_lb.rosa_ingress.name}*"]
  }
}

########################
# ALB Target Group
########################
resource "aws_lb_target_group" "rosa_ingress" {
  name_prefix = "rosa-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/healthz"
    matcher             = "200-399"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

########################
# ALB Listener
########################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rosa_ingress.arn
  }
}

########################
# ROSA Ingress IP 자동 등록
########################
resource "aws_lb_target_group_attachment" "rosa_ips" {
  for_each = toset(flatten([
    for eni_id in data.aws_network_interfaces.rosa_ingress.ids :
    data.aws_network_interface.eni[eni_id].private_ips
  ]))

  target_group_arn = aws_lb_target_group.rosa_ingress.arn
  target_id        = each.value
  port             = 80
}

########################
# ENI 상세 조회
########################
data "aws_network_interface" "eni" {
  for_each = toset(data.aws_network_interfaces.rosa_ingress.ids)
  id       = each.value
}