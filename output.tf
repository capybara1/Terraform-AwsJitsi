output "server_public_ip" {
  description = "The public ip of the server"
  value       = module.ec2.public_ip
}
