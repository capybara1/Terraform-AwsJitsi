provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}


locals {
  public_subnet_cidr_blocks  = [for i in range(var.public_subnet_count) : cidrsubnet(var.vpc_cidr_block, var.vpc_subnet_bits, i)]
  private_subnet_cidr_blocks = [for i in range(var.private_subnet_count) : cidrsubnet(var.vpc_cidr_block, var.vpc_subnet_bits, i + var.public_subnet_count)]
  server_subnet_index        = 0
}


data "aws_acm_certificate" "default" {
  domain   = var.cert_domain
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "default" {
  name         = var.zone
  private_zone = false
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "setup" {
  template = file("setup.tpl")
  vars = {
    domain = var.service_domain
  }
}


resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.prefix
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.default.id
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = local.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-Public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                = var.private_subnet_count
  vpc_id               = aws_vpc.default.id
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block           = local.private_subnet_cidr_blocks[count.index]
  tags = {
    Name = "${var.prefix}-Private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "${var.prefix}-Public"
  }
}

resource "aws_security_group" "lb" {
  name        = "${var.prefix}-ALB"
  description = "Controls access from/to load balancer"
  vpc_id      = aws_vpc.default.id

  dynamic "ingress" {
    for_each = [
      { port = 80, protocol = "tcp" },
      { port = 443, protocol = "tcp" },
      { port = 4443, protocol = "tcp" },
      { port = 10000, protocol = "udp" }
    ]
    iterator = it
    content {
      from_port   = it.value.port
      to_port     = it.value.port
      protocol    = it.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-ALB"
  }
}

resource "aws_lb" "default" {
  name               = var.prefix
  load_balancer_type = "network"
  internal           = false
  subnets            = aws_subnet.public[*].id
#  security_groups    = [aws_security_group.lb.id]
  tags = {
    Name = var.prefix
  }
}

resource "aws_lb_target_group" "http" {
  name     = "${var.prefix}-Http"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.default.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
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
  vpc_id   = aws_vpc.default.id

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "TCP"
  #  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"
  #  certificate_arn   = data.aws_acm_certificate.default.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_target_group" "videobridge1" {
  name     = "${var.prefix}-Videobridge1"
  port     = 4443
  protocol = "TCP"
  vpc_id   = aws_vpc.default.id

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_listener" "videobridge1" {
  load_balancer_arn = aws_lb.default.arn
  port              = "4443"
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
  vpc_id   = aws_vpc.default.id

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_listener" "videobridge2" {
  load_balancer_arn = aws_lb.default.arn
  port              = "10000"
  protocol          = "UDP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.videobridge2.arn
  }
}

resource "aws_key_pair" "default" {
  key_name   = var.prefix
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "server" {
  name        = "${var.prefix}-Server"
  description = "Controls access from/to Jitsi server instance"
  vpc_id      = aws_vpc.default.id

  dynamic "ingress" {
    for_each = [
      { port = 22, cidr_blocks = var.ssh_whitelist },
      { port = 80 },
      { port = 443 },
      { port = 4443 },
      { port = 10000, protocol = "udp" }
    ]
    iterator = it
    content {
      from_port   = it.value.port
      to_port     = it.value.port
      protocol    = lookup(it.value, "protocol", "tcp")
      cidr_blocks = lookup(it.value, "cidr_blocks", ["0.0.0.0/0"])
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-Server"
  }
}

resource "aws_instance" "server" {
  instance_type = var.instance_type
  ami           = data.aws_ami.ubuntu.id
  subnet_id     = aws_subnet.public[local.server_subnet_index].id
  vpc_security_group_ids = [
    aws_security_group.server.id
  ]
  key_name                    = aws_key_pair.default.id
  associate_public_ip_address = true
  user_data                   = data.template_file.setup.rendered
  tags = {
    Name = var.prefix
  }

}

# resource "aws_ebs_volume" "storage" {
#   type              = "gp2"
#   availability_zone = data.aws_availability_zones.available.names[local.server_subnet_index]
#   size              = 10
#   iops              = 100
#   tags = {
#     Name = var.prefix
#   }
# }

# resource "aws_volume_attachment" "server-storage" {
#   device_name = "/dev/sda1"
#   volume_id   = aws_ebs_volume.storage.id
#   instance_id = aws_instance.server.id
# }

resource "aws_lb_target_group_attachment" "server-http" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.server.id
}

resource "aws_lb_target_group_attachment" "server-https" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.server.id
}

resource "aws_lb_target_group_attachment" "server-videobridge1" {
  target_group_arn = aws_lb_target_group.videobridge1.arn
  target_id        = aws_instance.server.id
}

resource "aws_lb_target_group_attachment" "server-videobridge2" {
  target_group_arn = aws_lb_target_group.videobridge2.arn
  target_id        = aws_instance.server.id
}

resource "aws_route53_record" "cname_record" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.service_domain
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.default.dns_name]
}
