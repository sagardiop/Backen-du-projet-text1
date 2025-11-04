# Étape 1 : Base PHP avec extensions nécessaires
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
    && docker-php-ext-install pdo_pgsql mbstring bcmath \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Installer Composer depuis l'image officielle
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail dans le container
WORKDIR /var/www/html

# Copier uniquement les fichiers Composer pour tirer parti du cache Docker
COPY composer.json composer.lock ./

# Installer les dépendances Laravel
RUN composer install --no-dev --optimize-autoloader --prefer-dist

# Copier le reste du projet
COPY . .

# Donner les droits nécessaires pour storage et bootstrap/cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Exposer le port attendu par Render
EXPOSE 10000
ENV PORT=10000

# Lancer Laravel (pour dev/test, pas production)
CMD php artisan serve --host 0.0.0.0 --port $PORT
