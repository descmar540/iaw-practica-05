#!/bin/bash
set -x

#Variables de configuración
#################################################

# Reemplazar IP-HTTP-SERVER-1 Y IP-HTTP-SERVER-2 por las IPs de las máquinas Front-End
IP_HTTP_SERVER_1=54.227.60.126
IP_HTTP_SERVER_2=54.164.174.24

#################################################

#Actualizamos el sistema
apt update
apt upgrade -y

#Instalamos el servidor web Apache
apt install apache2 -y

# Activamos los siguientes módulos
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

# Añadir las directivas "Proxy" y "Proxypass" en Virtualhost

# Hay que reemplazar IP-HTTP-SERVER-1 y IP-HTTP-SERVER-2 por las direcciones IPs de las máquinas Front-End

#sed -i "s/IP-HTTP-SERVER-1/$IP_HTTP_SERVER_1/" /etc/apache2/sites-available/000-default.conf
#sed -i "s/IP-HTTP-SERVER-2/$IP_HTTP_SERVER_2/" /etc/apache2/sites-available/000-default.conf

# ESTE PASO ESTÁ COMENTADO PORQUE NO SÉ CÓMO AÑADIR LAS DIRECTIVAS PROXY Y PROXYPASS MEDIANTE SCRIPT, ENTONCES HE PREFERIDO HACER TODO ESTO YA A MANO.

# Reiniciamos el servidor Apache
#systemctl restart apache2




