#!/bin/bash
set -x

#Variables de configuración
#################################################

# Configuramos la IP privada de la máquina de MySQL (Backend)
IP_MYSQL=172.31.29.42

EMAIL_HTTPS=demo@demo.es
DOMAIN=dem-practicahttps.ddns.net

#################################################

#Actualizamos el sistema
apt update
apt upgrade -y

#Instalamos el servidor web Apache
apt install apache2 -y


# Instalamos los paquetes de PHP
apt install php libapache2-mod-php php-mysql -y

# Reiniciamos el servidor web Apache
systemctl restart apache2 

#########################################
# Instalación de herramientas adicionales
#########################################

# Instalamos Adminer
cd /var/www/html
mkdir adminer
cd adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
mv adminer-4.8.1-mysql.php index.php

# Actualizamos el propietario y el grupo del directorio /var/www/html
chown www-data:www-data /var/www/html -R

#########################################
# Despliegue de la aplicación web
#########################################
cd /var/www/html

# Clonamos el repositorio de la aplicación
rm -rf /var/www/html/iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git

# Movemos el código fuente de la aplicación al directorio /var/www/html
mv iaw-practica-lamp/src/* /var/www/html

# Importamos el script de base de datos. El -h indica el host al que vamos a conectarnos
#mysql -u root -p$MYSQL_ROOT_PASSWORD -h $IP_MYSQL< iaw-practica-lamp/db/database.sql

# Eliminar el archivo index.html
rm -f /var/www/html/index.html

# Eliminamos el directorio del repositorio
rm -rf /var/www/html/iaw-practica-lamp

# Configuramos la dirección IP de MySQL en el archivo de configuración
sed -i "s/localhost/$IP_MYSQL/" /var/www/html/config.php

# Cambiamos el propietario y el grupo de los archivos
chown www-data:www-data /var/www/html -R

#########################################
# Configuración HTTPS
#########################################

# Realizamos la instalación de snapd
#snap install core
#snap refresh core

# Eliminamos instalaciones previas de certbot con apt
#apt-get remove certbot

# Instalamos certbot con snap 
#snap install --classic certbot

# Solicitamos el certificado HTTPS
#certbot --apache -m $EMAIL_HTTPS --agree-tos --no-eff-email -d $DOMAIN