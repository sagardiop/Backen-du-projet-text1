# Étape 1 : Image de base PHP avec FPM
FROM php:8.3-fpm

# Étape 2 : Installer dépendances système
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Étape 3 : Copier Composer depuis l’image officielle
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Étape 4 : Définir le dossier de travail
WORKDIR /var/www/html

# Étape 5 : Copier les fichiers composer en priorité pour profiter du cache Docker
COPY composer.json composer.lock ./

# Étape 6 : Installer les dépendances PHP sans exécuter les scripts Laravel automatiquement
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Étape 7 : Copier tout le code du projet
COPY . .

# Étape 8 : Vérifier que .env existe
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Étape 9 : Corriger les permissions pour Laravel
RUN chmod -R 775 storage bootstrap/cache public && \
    chown -R www-data:www-data storage bootstrap/cache public

# Étape 10 : Exécuter les scripts Laravel après avoir les bonnes permissions
RUN composer dump-autoload --optimize
RUN php artisan key:generate --force
RUN php artisan config:cache
RUN php artisan route:cache || true
RUN php artisan view:cache || true

# Étape 11 : Migrations et seed
RUN php artisan migrate --force || true
RUN php artisan db:seed --force || true

# Étape 12 : Installer Passport si nécessaire
RUN if [ ! -f storage/oauth-private.key ] || [ ! -f storage/oauth-public.key ]; then \
        php artisan install:api --passport || true; \
    fi

# Étape 13 : Créer le lien symbolique storage -> public/storage
RUN php artisan storage:link || true

# Étape 14 : Corriger permissions des clés OAuth
RUN chmod 600 storage/oauth-private.key || true && \
    chmod 600 storage/oauth-public.key || true && \
    chown www-data:www-data storage/oauth-*.key || true
