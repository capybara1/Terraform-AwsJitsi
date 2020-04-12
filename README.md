# Jitsi on AWS

Terraform project for setting up Jitsi on AWS.

This approach is realized on the base of an [article][1] which guides
through manual creation of a Jisti Meet server.
However an important deviation is the use of an Application Load Balancer and
TLS termination instad of an elastic IP address bound to the server and
a certificate issued by letsencypt.

## Prerequisites

- A DNS zone, managed by AWS Route53, is available
- A TLS certificate, managed by AWS Certificate Manager, is available
- A RSA key pair for SSH connection is available

## Prepare

```sh
cat <<EOT > terraform.tfvars
service_domain = "jitsi.your-domain.de"
cert_domain = "*.your-domain.de"
zone = "your-domain.de."
public_key_path = "~/.ssh/id_rsa.pub"
EOT
```

```
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
```

## Apply

```sh
terraform init
terraform apply
```

## Resources

- [Getting started with Jitsi, an open source web conferencing solution][1]


[1]: https://aws.amazon.com/de/blogs/opensource/getting-started-with-jitsi-an-open-source-web-conferencing-solution/
