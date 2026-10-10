data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    dnf install -y httpd
    systemctl enable --now httpd
    echo "<h1>${var.project} - ${var.environment}</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project}-${var.environment}-web"
  }
}
