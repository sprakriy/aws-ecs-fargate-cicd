# Start with Ubuntu
FROM ubuntu:24.04

# Install Nginx and PostgreSQL Client
RUN apt-get update && apt-get install -y \
    nginx \
    postgresql-client \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Put your website in the correct folder
COPY index.html /var/www/html/index.html

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]