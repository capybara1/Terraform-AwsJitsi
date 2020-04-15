data "aws_route53_zone" "default" {
  name         = var.zone
  private_zone = false
}


resource "aws_lb" "default" {
  name               = var.prefix
  load_balancer_type = "network"
  internal           = false
  subnets            = var.subnet_ids
  tags = {
    Name = var.prefix
  }
}

resource "aws_lb_target_group" "http" {
  name     = "${var.prefix}-Http"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "https" {
  name     = "${var.prefix}-Https"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_target_group" "videobridge1" {
  name     = "${var.prefix}-Videobridge1"
  port     = 4443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_listener" "videobridge1" {
  load_balancer_arn = aws_lb.default.arn
  port              = 4443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.videobridge1.arn
  }
}

resource "aws_lb_target_group" "videobridge2" {
  name     = "${var.prefix}-Videobridge2"
  port     = 10000
  protocol = "UDP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_listener" "videobridge2" {
  load_balancer_arn = aws_lb.default.arn
  port              = 10000
  protocol          = "UDP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.videobridge2.arn
  }
}

resource "aws_lb_target_group_attachment" "server-http" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = var.instance_id
}

resource "aws_lb_target_group_attachment" "server-https" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = var.instance_id
}

resource "aws_lb_target_group_attachment" "server-videobridge1" {
  target_group_arn = aws_lb_target_group.videobridge1.arn
  target_id        = var.instance_id
}

resource "aws_lb_target_group_attachment" "server-videobridge2" {
  target_group_arn = aws_lb_target_group.videobridge2.arn
  target_id        = var.instance_id
}

resource "aws_route53_record" "cname_record" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.domain
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.default.dns_name]
}
