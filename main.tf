provider "aws" {}

resource "aws_instance" "test_1" {
  count = 3
  ami                    = "ami-0fc20dd1da406780b"
  instance_type          = "t2.micro"
  key_name               = "lin"
  private_ip             = "172.31.36.${count.index +10}"
  subnet_id              = "subnet-b62ea3fa"
  vpc_security_group_ids = [aws_security_group.my_web.id]
  user_data              = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt-get install apache2 -y
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "$myip"   >  /var/www/html/index.html
sudo service apache2 start
chkconfig apache2 on
EOF
    tags = {
    Name = "WebTerraform"
    Owner = "WebTerraform"
}
 }

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.haproxy.id}"
  allocation_id = "eipalloc-0f334dbbb2a2d2c9d"
}

resource "aws_instance" "haproxy" {
  ami                    = "ami-0fc20dd1da406780b"
  instance_type          = "t2.micro"
  key_name               = "lin"
  private_ip             = "172.31.36.15"
  subnet_id              = "subnet-b62ea3fa"
  vpc_security_group_ids = [aws_security_group.my_web.id]
  user_data              = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install haproxy -y
git clone https://github.com/lkrv/playbook.git
sudo cp /playbook/haproxy.cfg /etc/haproxy/
sudo service haproxy restart
EOF
    tags = {
    Name = "HAProxy"
    Owner = "HAProxy"
}
  
 }

resource "aws_security_group" "my_web" {
  name        = "my_web Security Group"
  description = "My First Security Group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
