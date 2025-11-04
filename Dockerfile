# Étape 1 : Base PHP avec extensions nécessaires
FROM php:8.2-fpm

# Installer les extensions PHP nécessaires pour Laravel + PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo_pgsql mbstring bcmath

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail dans le container
WORKDIR /var/www/html

# Copier tout le projet Laravel dans le container
COPY . .

# Installer les dépendances Laravel
RUN composer install --no-dev --optimize-autoloader

# Donner les droits nécessaires pour storage et bootstrap/cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Exposer le port attendu par Render
EXPOSE 10000

# Définir le port attendu par Render
ENV PORT=10000

# Lancer Laravel
CMD php artisan serve --host 0.0.0.0 --port $PORT
