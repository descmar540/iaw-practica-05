#!/bin/bash
set -x

#Variables de configuración
#################################################

MYSQL_ROOT_PASSWORD=root

#################################################

#Actualizamos el sistema
apt update
apt upgrade -y

#Instalamos MySQL Server
apt install mysql-server -y

#Cambiamos la contraseña del usuario root
mysql <<< "ALTER USER root@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"

# Configuramos MySQL para aceptar conexiones desde cualquier interfaz
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Reiniciamos el servicio de MySQL
systemctl restart mysql

#########################################
# Despliegue de la aplicación web
#########################################
cd /var/www/html

# Clonamos el repositorio de la aplicación
rm -rf /var/www/html/iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git

# Importamos el script de base de datos
mysql -u root -p$MYSQL_ROOT_PASSWORD < /var/www/html/iaw-practica-lamp/db/database.sql

# Eliminamos el directorio del repositorio
rm -rf /var/www/html/iaw-practica-lamp