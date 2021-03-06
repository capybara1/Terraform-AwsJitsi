![CI](https://github.com/capybara1/Terraform-AwsJitsi/workflows/CI/badge.svg)

# Jitsi on AWS

Terraform project for setting up Jitsi on AWS.

This approach is realized on the base of [this article][1] which guides
through manual creation of a Jisti Meet server.
The official [quick install][2] and [another article][3] have been used for
refinement.
## Prerequisites

- A DNS zone, managed by AWS Route53, is available
- A RSA key pair for SSH connection is available

## Prepare

Initialize Terraform

```sh
terraform init
```

Configure

```sh
cat <<EOT > terraform.tfvars
email = "john.doe@example.com"
domain = "jitsi.your-domain.de"
zone = "your-domain.de."
public_key_path = "~/.ssh/id_rsa.pub"
EOT
```

## Apply

```sh
terraform apply
```

## Resources

- [Getting started with Jitsi, an open source web conferencing solution][1]


[1]: https://aws.amazon.com/de/blogs/opensource/getting-started-with-jitsi-an-open-source-web-conferencing-solution/
[2]: https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
[3]: https://www.scaleway.com/en/docs/installing-jitsi-meet-videoconferencing-ubuntu-bionic/
