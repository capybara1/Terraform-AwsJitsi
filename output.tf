output "server_public_ip" {
  description = "The public ip of the server"
  value       = module.service.public_ip
}
