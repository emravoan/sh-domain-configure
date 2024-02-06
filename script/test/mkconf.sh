#!/bin/sh

# Check if at least three arguments are provided (at least one domain, Git repo URL, and project name)
if [ $# -lt 3 ]; then
    echo "❗Error: Insufficient arguments provided."
    echo "Usage: $0 domain1 [domain2 ...] git_repo_url project_name"
    exit 1
fi

echo ""
echo "🚀 Nginx configuration start..."
sleep 1

# Extract the Git repository URL (the second last argument)
GIT_REPO="${@: -2:1}"
echo "✅ Git remote: $GIT_REPO"
sleep 1

# Extract the project name (the last argument)
PROJECT_NAME="${@: -1}"
echo "✅ Project name: $PROJECT_NAME"
sleep 1

# Remove the last two arguments (Git repo URL and project name) from the list
set -- "${@:1:$(($#-2))}"

# Define the directory path using the project name
PROJECT_DIR="./var/www/${PROJECT_NAME}"
echo "✅ Project dir: $PROJECT_DIR"
sleep 1

# Domains are now all arguments except for the last two
DOMAINS=("$@")
echo "✅ Domain name: ${DOMAINS[*]}"
sleep 1

# Define the directory where Nginx server blocks are stored
NGINX_AVAILABLE="./etc/nginx/sites-available"
NGINX_ENABLED="./etc/nginx/sites-enabled"

# Generate a unique configuration file name based on the first domain
SERVER_BLOCK_FILE="${NGINX_AVAILABLE}/${PROJECT_NAME}.conf"
echo "✅ Domain configure file: $SERVER_BLOCK_FILE"
sleep 1

# Ensure running as root
# if [ "$(id -u)" -ne 0 ]; then
#     echo "❗Error: The user must be root user." >&2
#     exit 1
# fi

# Create the directory if it doesn't exist
echo "📁 Creating directory $PROJECT_DIR..."
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"

    # Clone the project into the directory
    echo "🔗 Cloning project from $GIT_REPO into $PROJECT_DIR..."
    git clone "$GIT_REPO" "$PROJECT_DIR"
fi

# Check if mkcert.sh script exists
MKCERT_SCRIPT="./script/test/mkcert.sh"
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
echo "🔥 Creating Domain Configuration..."
sleep 1
cat > "${SERVER_BLOCK_FILE}" <<EOF
server {
    listen 443 ssl;
    server_name ${DOMAINS[*]};

    ssl_certificate /etc/letsencrypt/live/${PROJECT_NAME}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${PROJECT_NAME}/privkey.pem;

    root ${PROJECT_DIR};
    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }
}

server {
    listen 80;
    server_name ${DOMAINS[*]};
    return 301 https://\$host\$request_uri;
}
EOF

# Enable the server block by creating a symlink
echo "🔗 Symlink domain configuration..."
sleep 1
ln -sf "${SERVER_BLOCK_FILE}" "${NGINX_ENABLED}"

# Test Nginx configuration
echo "🔍 Testing Nginx configuration..."
sleep 1
# if ! nginx -t; then
#     echo "❗Error: Nginx configuration test failed." >&2
#     exit 1
# fi

# Reload Nginx to apply changes
echo "🔄 Reloading nginx service..."
sleep 1
# systemctl reload nginx

echo "🎉 Awsome! Nginx configuration completed."