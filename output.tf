output "lb_dns_name" {
  value       = aws_lb.default.dns_name
  description = "The domain name of the ALB"
}

output "server_public_ip" {
  description = "The public ip of the server"
  value = aws_instance.server.public_ip
}
