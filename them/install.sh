#!/bin/bash
clear

PANEL="/var/www/pterodactyl"
THEME_DIR="$PANEL/public/freetunnel"
VIEW_DIR="$PANEL/resources/views/auth"

echo "=========== INSTALL THEME FREETUNNEL ==========="

# Buat folder theme
mkdir -p $THEME_DIR

# Backup login bila belum ada
if [ ! -f "$VIEW_DIR/login.blade.php.bak" ]; then
    cp "$VIEW_DIR/login.blade.php" "$VIEW_DIR/login.blade.php.bak"
    echo "[OK] Backup login.blade.php"
fi

# Download CSS
wget -q https://raw.githubusercontent.com/YOUR_GITHUB/ptero-freetunnel-theme/main/public/freetunnel.css \
     -O $THEME_DIR/freetunnel.css

# Download Logo
wget -q https://raw.githubusercontent.com/YOUR_GITHUB/ptero-freetunnel-theme/main/public/logo.svg \
     -O $THEME_DIR/logo.svg

# Download Login Blade
wget -q https://raw.githubusercontent.com/YOUR_GITHUB/ptero-freetunnel-theme/main/views/auth/login.blade.php \
     -O $VIEW_DIR/login.blade.php

cd $PANEL
php artisan view:clear >/dev/null
php artisan config:clear >/dev/null

echo ""
echo "================================================="
echo "   Tema FREE TUNNELING berhasil dipasang!"
echo "================================================="