resource "aws_security_group" "elb-sg" { 
  vpc_id = var.vpc
  ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp" 
        cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    tags = {
        Name = "elb-SG"
    }
}

resource "aws_lb" "lb" {
  count = 2
  name               = "lb${count.index}"
  internal           = var.lb_type[count.index]
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets            = var.public_subnet_id

  tags = {
    Name = "pub-lb"
  }
}

resource "aws_lb_listener" "listener" {
  count = 2 
  load_balancer_arn = aws_lb.lb[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn
  }
}





resource "aws_lb_target_group" "target_group" {
  count = 2
  name        = "targetgroup${count.index}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance" 
  vpc_id      = var.vpc

  health_check {
    protocol             = "HTTP"
    path                 = "/index.html"
    port                 = 80
    interval             = 30
    timeout              = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
    matcher              = "200-299"
  }
}
