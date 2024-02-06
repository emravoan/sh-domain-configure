#!/bin/bash

# Check if at least one arguments are provided
if [ $# -lt 2 ]; then
    echo "❗Error: Insufficient arguments provided."
    echo "Usage: $0 domain1 [domain2 ...] project_name"
    exit 1
fi

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❗Error: The user must be root user." >&2
    exit 1
fi

# Check if mkcert is installed
if ! command -v mkcert &>/dev/null; then
    echo "❗Error: mkcert is not installed."
    exit 1
fi

# Extract the project name
PROJECT_NAME="${@: -1}"

# Remove the last argument from the list
set -- "${@:1:$(($#-1))}"

# Extract the domains
DOMAINS=("$@")

# Generate SSL certificate
mkdir ./etc/letsencrypt/live/${PROJECT_NAME}
mkcert \
    -key-file "./etc/letsencrypt/live/${PROJECT_NAME}/fullchain.pem" \
    -cert-file "./etc/letsencrypt/live/${PROJECT_NAME}/privkey.pem" \
    ${DOMAINS[*]}
