# Shell Script for Domain Configuration

## About

- Script for setting up the domain configuration for Nginx server include certbot SSL certificate.


## Requirement

- [Certbot](https://certbot.eff.org/)
- [Web Server](https://docs.nginx.com/)


## Quick Start

```bash
# Generate
sh script/pro/mkconf.js.sh d1.com d2.com https://github.com/emravoan/sh-domain-configure.git sh_domain

# Modifies Domain and SSl
sh script/pro/mdconf.sh d1.com d2.com d3.com d4.com sh_domain
```