# DESCRIPCIÓN DEL PROCESO DE INSTALACIÓN

Se va a proceder a explicar el proceso para configurar un balanceador de carga de manera que el acceso a la aplicación se haga desde dos máquinas y así evitar sobrecargar las máquinas Front-End.

------

## Variables de configuración que hay que tener en cuenta

En este caso, tenemos las variables para configururar la IP privada de los dos Front-ends.
- *IP_FRONTEND_01=172.31.25.189*
- *IP_FRONTEND_02=172.31.80.254*

------
## INSTALACIÓN DE COMPONENTES

### Apache

Previo a la instalación, como en toda buena práctica con un sistema Ubuntu es importante hacer una **actualización del sistema**:

- *apt update*
- *apt upgrade -y*
("-y" es para no tener que poner YES y cortar la acción automática del script)

Ahora sí, se procede a instalar el servidor web Apache

* *apt install apache2 -y*

Una vez que ya lo hemos instalado (es el único componente de la pila que tenemos que instalar en esta máquina), se procede a activar los módulos necesarios para activar el proxy inverso. Es proxy es un tipo de servidor que, como se ha explicado al principio, hace de intermediario entre un cliente y uno o más servidores, repartiendo el acceso a ellos.

- *a2enmod proxy*
- *a2enmod proxy_http*
- *a2enmod proxy_ajp*
- *a2enmod rewrite*
- *a2enmod deflate*
- *a2enmod headers*
- *a2enmod proxy_balancer*
- *a2enmod proxy_connect*
- *a2enmod proxy_html*
- *a2enmod lbmethod_byrequests*

----------
Tras esto, se copia el archivo de configuración de Apache que hemos descargado al clonar el repositorio (cuyo contenido también está ya modificado) en el directorio de apache2 de sites-available, con la intención de sustituir el que viene por defecto y usar el que viene modificado

- *cp 000-default.conf /etc/apache2/sites-available/000-default.conf*

Básicamente el fichero se compone del siguiente contenido

~~~
<VirtualHost *:80>
    # Dejamos la configuración del VirtualHost como estaba
    # sólo hay que añadir las siguiente directivas: Proxy y ProxyPass

    <Proxy balancer://mycluster>
        # Server 1
        BalancerMember http://IP-HTTP-SERVER-1

        # Server 2
        BalancerMember http://IP-HTTP-SERVER-2
    </Proxy>

    ProxyPass / balancer://mycluster/
</VirtualHost>
~~~~

donde se ven los dos servidores (en este caso tenemos dos, si tuviéramos más Front-ends, pues sería cuestión de replicar líneas).

---
El penúltimo paso se encarga de reemplazar el texto que veíamos anteriormente en las líneas de las direcciones de BalancerMember por las IPs privadas de las máquinas, que además ya tenemos establecidas en las variables del principio del documento. Los comandos son los siguientes:

- *sed -i "s/IP-HTTP-SERVER-1/$IP_FRONTEND_01/" /etc/apache2/sites-available/000-default.conf*
- *sed -i "s/IP-HTTP-SERVER-2/$IP_FRONTEND_02/" /etc/apache2/sites-available/000-default.conf*

---

Finalmente, lo único que resta es reiniciar el servicio Apache para que se apliquen los cambios y el balanceador de carga comience a operar.

- *systemctl restart apache2*

Tras esto, ya debería de funcionar sin ningún tipo de problema el balanceador.

----
## CONFIGURACIÓN HTTPS

El último paso que resta de la práctica consiste en conseguir la certificación para poder acceder a la aplicación web mediante el protocolo HTTPS.

Se realiza mediante Certbot, y este se obtiene desde el repositorio de aplicaciones snap, no el apt clásico. Así pues, lo primero que hay que hacer es instalar el repositorio y actualizarlo
- *snap install core*
- *snap refresh core*

Una vez realizado, toca instalar Certbot, pero previo a ello, es preciso o recomendable eliminar posibles anteriores instalaciones que hubiera, para que no haya problema a la hora de emitir la certificación

- *apt-get remove certbot*
- *snap install --classic certbot*

Ya con Certbot instalado en el sistema, se puede proceder a pedir el certificado HTTPS.

* *certbot --apache -m $EMAIL_HTTPS --agree-tos --no-eff-email -d $DOMAIN*

En este comando entran dos variables por definir, **EMAIL_HTTPS=demo@demo.es** (se pone en forma de enlace por el .es) y la variable **DOMAIN=dem-balanceador.ddns.net**.

La primera variable es un valor default, pero la segunda se obtiene de asociar la IP elástica de la máquina donde se trabaja (si se trabaja de esa manera) al dominio que sea, en este caso, uno creado en la dirección www.noip.com

Además de esas instrucciones, en el comando aparece **agree-tos**, que es para aceptar automáticamente los términos y condiciones y **--no-eff-email** para no compartir el email con la *Electronic Frontier Foundation*.

---
Con todo ya preparado, lo que restaría sería ejecutar el script mediante el comando sudo (en este caso **sudo ./install_balanceador.sh**) y se ejecutaría el proceso de instalación del balanceador de carga con todas las herramientas adicionales al completo.