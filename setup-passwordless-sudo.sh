#!/bin/bash
#
# Setup Passwordless Sudo for Sparkbot Operations
# Run: bash setup-passwordless-sudo.sh
#

echo "Setting up passwordless sudo for sparky user..."
echo ""

# Create sudoers.d directory if it doesn't exist
sudo mkdir -p /etc/sudoers.d

# Create sudoers file for specific commands
sudo tee /etc/sudoers.d/sparky-deploy > /dev/null << 'EOF'
# Allow sparky to restart specific services without password
sparky ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart sparkbot-v2
sparky ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
sparky ALL=(ALL) NOPASSWD: /usr/bin/systemctl status sparkbot-v2
sparky ALL=(ALL) NOPASSWD: /usr/bin/systemctl status nginx
sparky ALL=(ALL) NOPASSWD: /bin/systemctl restart sparkbot-v2
sparky ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
sparky ALL=(ALL) NOPASSWD: /bin/systemctl status sparkbot-v2
sparky ALL=(ALL) NOPASSWD: /bin/systemctl status nginx
sparky ALL=(ALL) NOPASSWD: /bin/systemctl daemon-reload
sparky ALL=(ALL) NOPASSWD: /bin/cp -r /home/sparky/sparkbot-v2/frontend/dist/* /var/www/sparkbot-remote/
sparky ALL=(ALL) NOPASSWD: /bin/chown -R www-data:www-data /var/www/sparkbot-remote/

# Deploy commands
sparky ALL=(ALL) NOPASSWD: /home/sparky/.openclaw/scripts/sparkbot-deploy.sh

# File operations
sparky ALL=(ALL) NOPASSWD: /bin/chmod 644 /var/www/sparkbot-remote/*
sparky ALL=(ALL) NOPASSWD: /bin/chmod 755 /var/www/sparkbot-remote/

# Git operations in workspace
sparky ALL=(ALL) NOPASSWD: /usr/bin/git -C /home/sparky/.openclaw/workspace pull
sparky ALL=(ALL) NOPASSWD: /usr/bin/git -C /home/sparky/.openclaw/workspace push
EOF

# Set correct permissions
sudo chmod 440 /etc/sudoers.d/sparky-deploy

echo "✅ Passwordless sudo configured for:"
echo "   - systemctl restart sparkbot-v2"
echo "   - systemctl restart nginx"
echo "   - sparkbot-deploy.sh"
echo ""
echo "Test with: sudo -n systemctl status sparkbot-v2"
