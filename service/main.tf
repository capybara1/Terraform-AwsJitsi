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
  template = file("service/setup.tpl")
  vars = {
    domain = var.service_domain
    email = var.email
  }
}


resource "aws_key_pair" "default" {
  key_name   = var.prefix
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "server" {
  name        = "${var.prefix}-Server"
  description = "Controls access from/to Jitsi server instance"
  vpc_id      = var.vpc_id

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
  instance_type               = var.instance_type
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.server.id]
  key_name                    = aws_key_pair.default.id
  associate_public_ip_address = length(var.ssh_whitelist) > 0
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
