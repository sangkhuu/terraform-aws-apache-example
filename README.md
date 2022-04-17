Terraform Module to provision an EC2 Instance that is running Apache.

```
terraform {

}

provider "aws" {
  region = "ap-southeast-1"
}

module "apache" {
  source = ".//terraform-aws-apache-example"

  vpc_id        = "vpc-123456"
  my_ip         = "116.109.107.8/32"
  public_key    = "ssh-rsa AAAAB3NzaC1yc2EA...............gklajsdfbpo"
  instance_type = "t2.micro"
  server_name   = "Apache Example Server"
}

output "public_ip" {
  value = module.apache.public_ip
}
```