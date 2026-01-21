<<<<<<< HEAD
# Start with the latest Ubuntu
FROM ubuntu:24.04

# Avoid being stuck on geographic zone prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install the standard Linux tools you know and love
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    iputils-ping \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Set the landing directory
WORKDIR /app

# This keeps the container running so we can "bash" into it later
CMD ["sleep", "infinity"]
=======
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
>>>>>>> 196eec81c290e9476a05aedeb6ccb299677defac
