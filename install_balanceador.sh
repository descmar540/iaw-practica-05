#!/bin/bash
set -x

#Variables de configuración
#################################################

# Configurar la IP privada de los dos front-ends
IP_FRONTEND_01=172.31.25.189
IP_FRONTEND_02=172.31.80.254

# Configuración de HTTPS
EMAIL_HTTPS=demo@demo.es
DOMAIN=dem-balanceador.ddns.net

#################################################

#Actualizamos el sistema
apt update
apt upgrade -y

#Instalamos el servidor web Apache
apt install apache2 -y

# Activamos los siguientes módulos para activar el proxy inverso
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_ajp
a2enmod rewrite
a2enmod deflate
a2enmod headers
a2enmod proxy_balancer
a2enmod proxy_connect
a2enmod proxy_html
a2enmod lbmethod_byrequests

# Reiniciamos el servidor Apache (no sé si esto es necesario aquí o mejor hacerlo al final)
systemctl restart apache2

# Copiamos el archivo de configuración de Apache
cp 000-default.conf /etc/apache2/sites-available/000-default.conf

# Hay que reemplazar el texto de las variables IP-HTTP-SERVER-1 y IP-HTTP-SERVER-2 por las direcciones IPs de las máquinas Front-End
sed -i "s/IP-HTTP-SERVER-1/$IP_FRONTEND_01/" /etc/apache2/sites-available/000-default.conf
sed -i "s/IP-HTTP-SERVER-2/$IP_FRONTEND_02/" /etc/apache2/sites-available/000-default.conf

# Reiniciamos el servidor Apache
systemctl restart apache2


#########################################
# Configuración HTTPS
#########################################

# Realizamos la instalación de snapd
snap install core
snap refresh core

# Eliminamos instalaciones previas de certbot con apt
apt-get remove certbot

# Instalamos certbot con snap 
snap install --classic certbot

# Solicitamos el certificado HTTPS
certbot --apache -m $EMAIL_HTTPS --agree-tos --no-eff-email -d $DOMAIN

