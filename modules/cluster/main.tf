resource "aws_security_group" "webserver_sg" {
  name   = "webserver-sg-studentN"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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

resource "aws_launch_template" "webserver_template" {
  image_id      = "ami-058165de3b7202099"
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
EOF
  )
}

resource "aws_autoscaling_group" "webserver_asg" {
  vpc_zone_identifier = var.public_subnets
  target_group_arns   = [aws_lb_target_group.target_asg.arn]
  health_check_type   = "ELB"

  min_size = 2
  max_size = 3

  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = "$Latest"
  }

  # depends_on 를 사용해 필요한 의존성(예, VPC 생성 완료)을 보장할 수 있음
}

resource "aws_security_group" "alb_sg" {
  name   = var.alb_security_group_name
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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

resource "aws_lb" "webserver_alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "target_asg" {
  name     = var.alb_name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                 = "/"
    protocol             = "HTTP"
    matcher              = "200"
    interval             = 15
    timeout              = 3
    healthy_threshold    = 2
    unhealthy_threshold  = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.webserver_alb.arn
  port              = var.server_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_asg.arn
  }
}

resource "aws_lb_listener_rule" "webserver_asg_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_asg.arn
  }
}