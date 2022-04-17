resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

# TEMPLATE FILE
data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yml")
}

data "aws_vpc" "main" {
  id = var.vpc_id
}
data "aws_ami" "sing_amazone_linux_2" {
  #privider = aws
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "sg-sangkhuu-server" {
  name        = "sangkhuu-sg-server"
  description = "sangkhuu sg create by terraform"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


## RESOURCES instance
#resource "aws_instance" "sangkhuu_server" {
#  ami                    = "ami-0801a1e12f4a9ccc0"
#  instance_type          = "t2.micro"
#  key_name               = aws_key_pair.deployer.key_name
#  vpc_security_group_ids = [aws_security_group.sg-sangkhuu-server.id]
#  user_data              = data.template_file.user_data.rendered
#
#  # FILE
#  provisioner "file" {
#    content     = "This is the string content"
#    destination = "/home/ec2-user/barsoon/txt"
#    connection {
#      type        = "ssh"
#      user        = "ec2-user"
#      host        = self.public_ip
#      private_key = data.template_file.private_key.rendered
#    }
#  }
#  tags = {
#    Name = "sangkhuu-terraform"
#  }
#}


resource "aws_instance" "sangkhuu_server" {
  ami                    = data.aws_ami.sing_amazone_linux_2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  #subnet_id = "subnet-0dcf2595700c7b2fb"

  vpc_security_group_ids = [aws_security_group.sg-sangkhuu-server.id]
  user_data              = data.template_file.user_data.rendered
  tags = {
    Name = "${var.server_name}"
  }
}
