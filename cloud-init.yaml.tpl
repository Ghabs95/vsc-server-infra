#cloud-config
package_update: true
package_upgrade: true
packages:
- git
- curl
- wget
- build-essential
- nginx
- openjdk-17-jdk
- python3-pip
- python3-venv
- jq
- unzip
- software-properties-common
- redis-server
- postgresql
- postgresql-contrib

write_files:
- path: /home/ubuntu/setup_flutter.sh
permissions: '0755'
owner: ubuntu:ubuntu
content: |
#!/bin/bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable /home/ubuntu/flutter
export PATH="$PATH:/home/ubuntu/flutter/bin"
echo 'export PATH="$PATH:/home/ubuntu/flutter/bin"' >> /home/ubuntu/.bashrc
flutter doctor

- path: /home/ubuntu/start_tunnel.sh
permissions: '0755'
owner: ubuntu:ubuntu
content: |
#!/bin/bash
# Start VS Code Tunnel
# This requires an interactive login or a token.
# Usage: ./start_tunnel.sh [machine_name]
NAME=${1:-"ghabs-hq"}

# Install the service (allows background execution later)
code tunnel service install

echo "Starting tunnel interactively for authentication..."
echo "Once authenticated, you can press Ctrl+C and run 'sudo systemctl start code-tunnel' to run it in the background."

code tunnel --name "$NAME" --accept-server-license-terms

- path: /home/ubuntu/generate_ssh_key.sh
permissions: '0755'
owner: ubuntu:ubuntu
content: |
#!/bin/bash
# Generate SSH Key for GitHub
ssh-keygen -t ed25519 -C "ghabs-hq" -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "SSH Key generated. Run the following command to add it to GitHub:"
echo "gh ssh-key add ~/.ssh/id_ed25519.pub --title \"ghabs-hq\""

runcmd:
# Start Nginx
- systemctl start nginx
- systemctl enable nginx

# Start PostgreSQL
- systemctl start postgresql
- systemctl enable postgresql
- sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='nexus'" | grep -q 1 || sudo -u postgres psql -c "CREATE USER nexus WITH PASSWORD 'nexus';"
- sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='nexus'" | grep -q 1 || sudo -u postgres psql -c "CREATE DATABASE nexus OWNER nexus;"
- sudo -u postgres psql -c "ALTER ROLE nexus SET client_encoding TO 'utf8';"
- sudo -u postgres psql -c "ALTER ROLE nexus SET timezone TO 'UTC';"

# Start Redis
- systemctl start redis-server
- systemctl enable redis-server

# Install Docker (Official Script)
# This installs docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin
- curl -fsSL https://get.docker.com | sh
- systemctl start docker
- systemctl enable docker
- usermod -aG docker ubuntu

# Install Node.js 20
- curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
- apt-get install -y nodejs npm

# Install Terraform
- wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
- echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
- apt-get update && apt-get install -y terraform

# Install Github/Gemini CLI
- npm install -g @github/copilot @google/gemini-cli

# Install VS Code Server (CLI)
- curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-arm64' --output /tmp/vscode_cli.tar.gz
- tar -xf /tmp/vscode_cli.tar.gz -C /usr/local/bin
