FROM php:8.3-fpm

# Installer les dépendances système
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
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Installer les extensions PHP
RUN docker-php-ext-install \
    pdo_mysql \
    intl \
    zip \
    mbstring

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Définir le dossier de travail
WORKDIR /var/www/html

# Copier le projet
COPY . .

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Donner les permissions nécessaires à CakePHP
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 tmp logs

# Supprimer la configuration par défaut de Nginx
RUN rm -f /etc/nginx/sites-enabled/default

# Copier la configuration Nginx personnalisée
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Vérifier la configuration Nginx pendant le build
RUN nginx -t

# Exposer le port
EXPOSE 8080

# Démarrer PHP-FPM puis Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]