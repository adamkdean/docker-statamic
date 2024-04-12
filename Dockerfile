# Copyright (C) 2024 Adam K Dean <adamkdean@googlemail.com>

FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ENV DOMAIN ""

# Update the package list, install the required packages, then clean up
RUN apt update && \
    apt upgrade -y && \
    apt install -y php-common php-fpm sudo zip unzip curl nginx php-json php-mbstring \
                    php-zip php-cli php-xml php-tokenizer php-curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Composer & make it executable
WORKDIR /tmp
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Create a non-root user to perform the install, temporarily taking over the www directory
RUN useradd -ms /bin/bash statamic-user && \
    echo "statamic-user ALL=(ALL) NOPASSWD: ALL" | tee "/etc/sudoers.d/statamic-user" && \
    chown -R statamic-user:statamic-user /var/www

# Switch to the non-root user and install Statamic to the www directory
WORKDIR /var/www
USER statamic-user
RUN composer create-project --prefer-dist statamic/statamic statamic

# Switch back to root and remove the non-root user
USER root
RUN userdel statamic-user

# Return directory ownership to www-data
RUN chmod -R 755 /var/www/statamic && \
    chown -R www-data:www-data /var/www

# Copy the nginx site configuration & enable it
COPY site.conf /etc/nginx/sites-available/statamic
RUN ln -sf /etc/nginx/sites-available/statamic /etc/nginx/sites-enabled/statamic

# Start Services: ensure a domain environment variable is set, update the Nginx
# configuration with the domain, started PHP-FPM, and then start Nginx.
CMD test -n "$DOMAIN" || { echo "Error: DOMAIN environment variable is not set."; exit 1; } && \
    sed -i 's/%DOMAIN%/'"$DOMAIN"'/g' /etc/nginx/sites-available/statamic && \
    service php8.1-fpm start && \
    nginx -g 'daemon off;'
