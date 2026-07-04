FROM php:8.3-fpm

# Dépendances système
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    unzip \
    zip \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    default-mysql-client

# Extensions PHP
RUN docker-php-ext-install \
    pdo_mysql \
    intl \
    zip \
    mbstring

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Dossier de travail
WORKDIR /var/www/html

# Copier le projet
COPY . .

# Installer les dépendances
RUN composer install --no-dev --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data \
    tmp \
    logs

# Copier la configuration nginx
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD service nginx start && php-fpm -F