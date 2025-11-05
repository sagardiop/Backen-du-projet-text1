# ----------------------------
# Étape 1 : Image de base PHP avec FPM
# ----------------------------
FROM php:8.2-fpm

# ----------------------------
# Étape 2 : Installer dépendances système
# ----------------------------
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Étape 3 : Copier Composer depuis l’image officielle
# ----------------------------
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# ----------------------------
# Étape 4 : Définir le dossier de travail
# ----------------------------
WORKDIR /var/www/html

# ----------------------------
# Étape 5 : Copier tout le code du projet Laravel
# ----------------------------
COPY . .

# ----------------------------
# Étape 6 : Installer les dépendances PHP
# ----------------------------
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# ----------------------------
# Étape 7 : S’assurer que .env existe
# ----------------------------
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# ----------------------------
# Étape 8 : Permissions générales pour storage/bootstrap/cache/public
# ----------------------------
RUN chmod -R 775 storage bootstrap/cache public && \
    chown -R www-data:www-data storage bootstrap/cache public

# ----------------------------
# Étape 9 : Générer la clé d’application
# ----------------------------
RUN php artisan key:generate --force

# ----------------------------
# Étape 10 : Lancer migrations + seed (optionnel, sécuriser avec || true)
# ----------------------------
RUN php artisan migrate --force || true
RUN php artisan db:seed --force || true

# ----------------------------
# Étape 11 : Créer le lien symbolique storage -> public/storage
# ----------------------------
RUN php artisan storage:link || true

# ----------------------------
# Étape 12 : Exposer le port et lancer Laravel
# ----------------------------
EXPOSE 10000
ENV PORT=10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
