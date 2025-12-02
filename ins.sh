#!/bin/bash
clear
echo "=============================================="
echo "  AUTO INSTALL PTERODACTYL PANEL + WINGS      "
echo "  FULL OTOMATIS + AUTO ADMIN LOGIN            "
echo "=============================================="
echo ""

# ========================== INPUT USER ==========================
read -p "Domain Panel (ex: panel.domain.com): " DOMAIN
read -p "Admin Email Panel (ex: admin@gmail.com): " ADMIN_EMAIL
read -p "Admin Password Panel: " ADMIN_PASS
read -p "Password Database (user ptero): " DB_PASS
read -p "Timezone (default Asia/Jakarta): " TZ
TZ=${TZ:-Asia/Jakarta}

echo ""
echo "=== Konfigurasi Location & Node ==="
read -p "Nama Location (ex: ID-1): " LOC_NAME
read -p "Deskripsi Location (ex: Indonesia Server): " LOC_DESC
read -p "Nama Node (ex: Node-1): " NODE_NAME
read -p "Total RAM Node (MB, ex: 4096): " NODE_RAM
read -p "Total Disk Node (MB, ex: 50000): " NODE_DISK

# Default values
NODE_RAM_OVERALLOC=100
NODE_DISK_OVERALLOC=100
NODE_UPLOAD_SIZE=100
NODE_DAEMON_PORT=8080
NODE_SFTP_PORT=2022
NODE_DATA_DIR="/var/lib/pterodactyl/volumes"

echo ""
echo "=== Instalasi dimulai... ==="
sleep 2

# ========================== UPDATE SYSTEM ==========================
apt update -y && apt upgrade -y
apt install -y curl wget unzip git ufw jq software-properties-common

# ========================== INSTALL MARIADB ==========================
echo ">>> Install MariaDB..."
apt install -y mariadb-server mariadb-client
mysql -u root <<MYSQL
CREATE DATABASE panel;
CREATE USER 'ptero'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1';
FLUSH PRIVILEGES;
MYSQL

# ========================== INSTALL PHP ==========================
echo ">>> Install PHP 8.1..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.1 php8.1-{cli,common,zip,gd,mbstring,mysql,bcmath,xml,curl,fpm}

# ========================== INSTALL COMPOSER ==========================
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# ========================== INSTALL PANEL ==========================
echo ">>> Download Panel..."
cd /var/www/
mkdir -p pterodactyl && cd pterodactyl

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz

cp .env.example .env

sed -i "s|APP_URL=.*|APP_URL=https://$DOMAIN|g" .env
sed -i "s|APP_TIMEZONE=.*|APP_TIMEZONE=$TZ|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=panel|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=ptero|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|g" .env

composer install --no-dev --optimize-autoloader
php artisan key:generate
php artisan migrate --seed --force

# ========================== AUTO CREATE ADMIN ==========================
echo ">>> Membuat Admin Panel..."
php artisan p:user:make <<EOF
$ADMIN_EMAIL
admin
Administrator
Panel
$ADMIN_PASS
yes
EOF

chown -R www-data:www-data /var/www/pterodactyl

# ========================== INSTALL NGINX ==========================
echo ">>> Install Nginx..."
apt install -y nginx

cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        include snippets/fastcgi-php.conf;
    }
}
EOF

ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
nginx -t && systemctl restart nginx

# ========================== INSTALL SSL ==========================
echo ">>> Install SSL..."
apt install -y certbot python3-certbot-nginx
certbot --nginx -d "$DOMAIN" -m "$ADMIN_EMAIL" --agree-tos --redirect --non-interactive

# ========================== INSTALL DOCKER ==========================
echo ">>> Install Docker..."
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker

# ========================== INSTALL WINGS ==========================
echo ">>> Install Wings..."
mkdir -p /etc/pterodactyl
cd /etc/pterodactyl

wget https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 -O wings
chmod +x wings

cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
Group=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/etc/pterodactyl/wings
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wings

# ========================== AUTO CREATE LOCATION & NODE ==========================
echo ">>> Membuat Location dan Node..."

LOC_ID=1

php artisan p:location:make <<EOF
$LOC_NAME
$LOC_DESC
EOF

php artisan p:node:make <<EOF
$NODE_NAME
$LOC_DESC
$LOC_ID
https
$DOMAIN
yes
no
no
$NODE_RAM
$NODE_RAM_OVERALLOC
$NODE_DISK
$NODE_DISK_OVERALLOC
$NODE_UPLOAD_SIZE
$NODE_DAEMON_PORT
$NODE_SFTP_PORT
$NODE_DATA_DIR
EOF

# ========================== OUTPUT ==========================
clear
echo "========================================================="
echo "          INSTALASI PTERODACTYL SELESAI 100%            "
echo "========================================================="
echo "Panel URL      : https://$DOMAIN"
echo "Admin Email    : $ADMIN_EMAIL"
echo "Admin Password : $ADMIN_PASS"
echo ""
echo "Location       : $LOC_NAME"
echo "Node Name      : $NODE_NAME"
echo "RAM Node       : $NODE_RAM MB"
echo "Disk Node      : $NODE_DISK MB"
echo ""
echo ">>> SELESAI!"
echo "Sekarang buka Panel → Nodes → pilih Node → Copy 'Configure Wings'"
echo "Paste ke terminal saat diminta:"
echo ""
echo "systemctl restart wings"
echo ""
echo "========================================================="