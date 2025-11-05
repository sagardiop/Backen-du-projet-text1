# Étape 1 : Base PHP
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libonig-dev libpq-dev git unzip zip curl pkg-config autoconf \
    libxml2-dev libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_pgsql mbstring bcmath zip xml curl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ✅ Copier tout le projet AVANT d’installer
COPY . .

# ✅ Ensuite seulement installer les dépendances
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 10000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
