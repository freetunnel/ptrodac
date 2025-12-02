#!/bin/bash
clear

PANEL="/var/www/pterodactyl"
VIEW_DIR="$PANEL/resources/views/auth"

echo "=========== UNINSTALL THEME FREETUNNEL ==========="

if [ -f "$VIEW_DIR/login.blade.php.bak" ]; then
    cp "$VIEW_DIR/login.blade.php.bak" "$VIEW_DIR/login.blade.php"
    echo "[OK] Login dikembalikan ke default."
else
    echo "[WARNING] Backup tidak ditemukan."
fi

echo "Selesai."