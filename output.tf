output "lb_dns_name" {
  value       = aws_lb.default.dns_name
  description = "The domain name of the ALB"
}
