# Jitsi on AWS

Terraform project for setting up Jitsi on AWS.

## Prerequisites

- Registered DNS domain on AWS Route53 is available
- An RSA key pair for SSH connection is available

## Configure


```sh
cat <<EOT > terraform.tfvars
service_domain = "jitsi.your-domain.de"
cert_domain = "*.your-domain.de"
zone = "your-domain.de."
public_key_path = "~/.ssh/id_rsa"
EOT
```

## Apply

```sh
terraform init
terraform apply
```

## Resources

- [Getting started with Jitsi, an open source web conferencing solution][1]


[1]: https://aws.amazon.com/de/blogs/opensource/getting-started-with-jitsi-an-open-source-web-conferencing-solution/
