# Étape 1 : Image de base PHP avec FPM
FROM php:8.3-fpm

# Étape 2 : Installer dépendances système
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev libgmp-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip pdo_pgsql gmp

# Étape 3 : Copier Composer depuis l’image officielle
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Étape 4 : Définir le dossier de travail
WORKDIR /var/www/html

# Étape 5 : Copier tout le code du projet Laravel
COPY . .

# Étape 6 : Installer les dépendances PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# 6b  Build Vite (ESSENTIEL)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm ci \
    && npm run build

# 7b  Supprime le .env figé (ESSENTIEL)
RUN rm -f .env

# Étape 7 : S’assurer que .env existe (devient inutile mais on touche pas)
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Étape 8 : Permissions générales pour storage/bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache public && \
    chown -R www-data:www-data storage bootstrap/cache public

# Étape 9 : Générer la clé d’application
RUN php artisan key:generate --force

# Étape 10 : Lancer migrations + seed (sans fresh)
RUN php artisan migrate --force || true
RUN php artisan db:seed --force || true

# Étape 11 : Installer Passport si les clés manquent
RUN if [ ! -f storage/oauth-private.key ] || [ ! -f storage/oauth-public.key ]; then \
        php artisan install:api --passport || true; \
    fi

# Étape 12 : Créer le lien symbolique storage -> public/storage
RUN php artisan storage:link || true
RUN php artisan route:clear || true
RUN php artisan config:clear || true
RUN php artisan cache:clear || true
RUN php artisan optimize:clear || true
RUN php artisan migrate:fresh || true

# Étape 13 : Corriger permissions des clés OAuth
RUN chmod 600 storage/oauth-private.key || true && \
    chmod 600 storage/oauth-public.key || true && \
    chown www-data:www-data storage/oauth-*.key || true

# 13b Installe psql pour le test au démarrage
RUN apt-get update && apt-get install -y postgresql-client

# Étape 14 : Exposer le port
EXPOSE 8000

# Étape 15 : Script d’entrée qui teste la DB avant Laravel
RUN echo '#!/bin/sh\n\
echo "⇆ Test connexion DB..."\n\
until PGPASSWORD=$DB_PASSWORD psql "sslmode=${DB_SSLMODE:-require} host=$DB_HOST port=${DB_PORT:-5432} user=$DB_USERNAME dbname=$DB_DATABASE" -c "SELECT 1;" >/dev/null 2>&1; do\n\
  echo "⏳ DB inaccessible, nouvelle tentative dans 2 s..."; sleep 2;\n\
done\n\
echo "✅ DB reachable – lancement Laravel"\n\
php artisan config:cache\n\
composer require s-ichikawa/laravel-sendgrid-driver\n\
php artisan serve --host=0.0.0.0 --port=8000\n' > /entry.sh && chmod +x /entry.sh

CMD ["/entry.sh"]