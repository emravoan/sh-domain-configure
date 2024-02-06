#!/bin/sh

# Check if at least two arguments are provided (at least one domain and project name)
if [ $# -lt 2 ]; then
    echo "❗Error: Insufficient arguments provided."
    echo "Usage: $0 domain1 [domain2 ...] exist_project_name"
    exit 1
fi

echo ""
echo "🚀 Nginx modifies configuration start..."
sleep 1

# Extract the project name (the last argument)
PROJECT_NAME="${@: -1}"
echo "✅ Project name: $PROJECT_NAME"
sleep 1

# Remove the last two arguments (Git repo URL and project name) from the list
set -- "${@:1:$(($#-1))}"

# Define the directory path using the project name
PROJECT_DIR="/var/www/${PROJECT_NAME}"
echo "✅ Project dir: $PROJECT_DIR"
sleep 1

# Domains are now all arguments except for the last two
DOMAINS=("$@")
echo "✅ Domain name: ${DOMAINS[*]}"
sleep 1

# Define the directory where Nginx server blocks are stored
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

# Generate a unique configuration file name based on the first domain
SERVER_BLOCK_FILE="${NGINX_AVAILABLE}/${PROJECT_NAME}.conf"
echo "✅ Domain configure file: $SERVER_BLOCK_FILE"
sleep 1

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❗Error: The user must be root user." >&2
    exit 1
fi

# Check if server block file exists
if [ ! -f "$SERVER_BLOCK_FILE" ]; then
    echo "❗Error: Nginx domain configuration file $SERVER_BLOCK_FILE not found." >&2
    exit 1
fi

# Check if mkcert.sh script exists
MKCERT_SCRIPT="./mkcert.sh"
if [ ! -f "$MKCERT_SCRIPT" ]; then
    echo "❗Error: SSL certificate script mkcert.sh not found." >&2
    exit 1
fi

# Make mkcert.sh executable if it isn't
if [ ! -x "$MKCERT_SCRIPT" ]; then
    chmod +x "$MKCERT_SCRIPT"
fi

# Create SSL Certificate
echo "🔐 Creating SSL certificate for ${DOMAINS[*]}"
if ! $MKCERT_SCRIPT "${DOMAINS[*]}" "${PROJECT_NAME}"; then
    echo "❗Error: SSL certificate generation failed." >&2
    exit 1
fi

# Create the Nginx server block configuration
echo "🔥 Updating domain configuration..."
sleep 1

# Update server_name
sed -i '' "s/^    server_name .*/    server_name ${DOMAINS[*]};/" "$SERVER_BLOCK_FILE"

# Test Nginx configuration
echo "🔍 Testing Nginx configuration..."
sleep 1
if ! nginx -t; then
    echo "❗Error: Nginx configuration test failed." >&2
    exit 1
fi

# Reload Nginx to apply changes
echo "🔄 Reloading nginx service..."
sleep 1
systemctl reload nginx

echo "🎉 Awsome! Nginx configuration modified."