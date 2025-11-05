# ----------------------------
# Étape 1 : Base PHP avec extensions nécessaires
# ----------------------------
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libonig-dev \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    pkg-config \
    autoconf \
    libxml2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_pgsql mbstring bcmath zip xml curl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ✅ Copier tout le code avant l’installation
COPY . .

# Installer les dépendances Composer
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Créer les dossiers et corriger les permissions
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 10000
ENV PORT=10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
