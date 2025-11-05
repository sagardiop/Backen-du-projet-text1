# ----------------------------
# Étape 1 : Base PHP avec extensions nécessaires
# ----------------------------
FROM php:8.2-fpm

# Installer les extensions PHP nécessaires pour Laravel + PostgreSQL
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

# Installer Composer depuis l'image officielle
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail dans le container
WORKDIR /var/www/html

# ----------------------------
# Étape 2 : Copier les fichiers et installer les dépendances
# ----------------------------
COPY composer.json composer.lock ./

# Installer les dépendances Composer sans dev et optimiser l'autoloader
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Copier le reste du projet
COPY . .

# ----------------------------
# Étape 3 : Permissions correctes
# ----------------------------
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# ----------------------------
# Étape 4 : Exposer le port et lancer Laravel
# ----------------------------
EXPOSE 10000
ENV PORT=10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
