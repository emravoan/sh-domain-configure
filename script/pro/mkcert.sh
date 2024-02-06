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

# Check if Certbot is installed
if ! command -v certbot &>/dev/null; then
    echo "❗Error: Certbot is not installed."
    exit 1
fi

# Extract the project name
PROJECT_NAME="${@: -1}"

# Remove the last argument from the list
set -- "${@:1:$(($#-1))}"

# Extract the domains
DOMAINS=("$@")

# Generate SSL certificate for all domains"
certbot certonly \
    --agree-tos \
    --register-unsafely-without-email \
    --cert-name $PROJECT_NAME \
    ${DOMAINS[*]}