data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_subnet" "public" {
  id = "subnet-00260868f0fd32bcf"
}

data "aws_security_group" "webapp_sg" {
  id = "sg-073152a7f6ed0e3fb"
}

resource "aws_instance" "webapp_instance" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public.id
  vpc_security_group_ids      = [data.aws_security_group.webapp_sg.id]
  associate_public_ip_address = true

  # Replace the instance whenever user-data changes so the fix is applied
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    # ── 1. Install Apache (httpd) ──────────────────────────────────────────────
    dnf install -y httpd

    # ── 2. Configure httpd to listen on port 8080 instead of 80 ───────────────
    # Remove any existing Listen directives from the main config and all conf.d
    # fragments, then add a single authoritative Listen 8080.
    sed -i 's/^\s*Listen\s\+80\b.*/Listen 8080/' /etc/httpd/conf/httpd.conf
    # Remove any stray "Listen 80" lines that might appear in conf.d
    find /etc/httpd/conf.d/ -name '*.conf' \
         -exec sed -i '/^\s*Listen\s\+80\b/d' {} \;

    # ── 3. Create the hello-world page ────────────────────────────────────────
    mkdir -p /var/www/html
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
      <head><title>Hello</title></head>
      <body><h1>Hello from AWS Full Stack</h1></body>
    </html>
    HTML

    # ── 4. Enable and start httpd ─────────────────────────────────────────────
    systemctl enable httpd
    systemctl restart httpd

    # ── 5. Wait until Apache is actually serving on port 8080 ─────────────────
    for i in $(seq 1 30); do
      if curl -sf http://127.0.0.1:8080/ > /dev/null 2>&1; then
        echo "Apache is serving on port 8080 (attempt $i)"
        exit 0
      fi
      echo "Waiting for Apache ... attempt $i"
      sleep 2
    done

    echo "ERROR: Apache did not come up on port 8080 within 60 s" >&2
    exit 1
  EOF

  tags = {
    Name  = "webapp-instance"
    Stack = "instance"
  }
}