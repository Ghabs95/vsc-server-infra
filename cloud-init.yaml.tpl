#cloud-config
package_update: true
package_upgrade: true
packages:
- git
- curl
- docker.io
- build-essential

runcmd:
# Enable Docker
- systemctl start docker
- systemctl enable docker
- usermod -aG docker ubuntu

# Install VS Code Server (CLI)
- curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-arm64' --output /tmp/vscode_cli.tar.gz
- tar -xf /tmp/vscode_cli.tar.gz -C /usr/local/bin
