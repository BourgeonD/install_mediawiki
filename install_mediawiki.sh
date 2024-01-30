#!/bin/bash

echo '
  __  __              _   _          __        __  _   _      _ 
 |  \/  |   ___    __| | (_)   __ _  \ \      / / (_) | | __ (_)
 | |\/| |  / _ \  / _` | | |  / _` |  \ \ /\ / /  | | | |/ / | |
 | |  | | |  __/ | (_| | | | | (_| |   \ V  V /   | | |   <  | |
 |_|  |_|  \___|  \__,_| |_|  \__,_|    \_/\_/    |_| |_|\_\ |_|

#################################################################
Installateur MediaWiki 1.0
Dorian Bourgeon
'

# Vérifie si l'utilisateur actuel est root (UID 0)
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Mise a jour"
sudo apt update && sudo apt upgrade -y

# Installation des paquets
read -p "Voulez-vous installer les paquets requis ? [y/n]: " chx

if [ "$chx" == "y" ]; then
    echo "Installation des paquets"
    sudo apt install apache2 mariadb-server php php-mysql libapache2-mod-php php-xml php-mbstring -y 
    sudo apt install php-apcu php-intl imagemagick inkscape php-gd php-cli php-curl php-bcmath git -y
    sudo systemctl reload apache2

    # Activation des modules PHP
    sudo phpenmod mbstring
    sudo phpenmod xml
    sudo systemctl restart apache2.service
    echo "Fin d'installation des paquets"
fi

# Téléchargement de MediaWiki
cd /tmp/
# A modifié selon la version
wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz 
tar -xvzf /tmp/mediawiki-*.tar.gz
read -p "Entrez le nom du répertoire du wiki: " name_repository
sudo mkdir /var/www/html/$name_repository
sudo mv mediawiki-*/* /var/www/html/$name_repository/.

# Configuration MYSQL
# Création de la BDD
read -p "Entrez le nom de la nouvelle BDD: " name_bdd
echo "Entrez le MDP 'root' de la BDD"
sudo mysql -u root -p -e \ "CREATE DATABASE $name_bdd; exit;"

# Création d'un nouvel utilisateur BDD & Ajout des privilèges
read -p "Voulez-vous créer un nouvel utilisateur BDD ? [y/n]: " chx_usr_bdd
if [ "$chx_usr_bdd" == "y" ]; then
    echo "Ajout d'un nouvel utilisateur"
    read -p "Entrez le nom du nouvel utilisateur: " name_usr_bdd
    read -p "Entrez le mdp du nouvel utilisateur: " pwd_usr_bdd
    echo "Entrez le MDP 'root' de la BDD"
    sudo mysql -u root -p -e \ "CREATE USER '$name_usr_bdd'@'localhost' IDENTIFIED BY '$pwd_usr_bdd'; CREATE USER '$name_usr_bdd'@'127.0.0.1' IDENTIFIED BY '$pwd_usr_bdd'; use $name_bdd; GRANT ALL ON $name_bdd.* TO '$name_usr_bdd'@'localhost'; GRANT ALL ON $name_bdd.* TO '$name_usr_bdd'@'127.0.0.1'; commit; exit;"
else
    echo "Entrez le MDP 'root' de la BDD"
    sudo mysql -u root -p -e \ "GRANT ALL ON $name_bdd.* TO 'wiki'@'localhost'; GRANT ALL ON $name_bdd.* TO 'wiki'@'127.0.0.1'; commit; exit;"
fi

cd /home/odin/

# Installation des certificats
read -p "Voulez-vous passer l'installation des certificats ? [y/n]: " chx_certs
if [ "$chx_certs" == "y" ]; then
    read -p "Placez les .crt et .key dans /home/odin, il doivent avoir le même nom que le serveur (ex: serveur => odin.ciml.cnrs = odin.crt & odin.key )"
    sudo mv *.crt /etc/ssl/certs/.
    sudo mv *.key /etc/ssl/private/.
    echo "Fin de l'installation des certificats"
fi

# Création du .htpasswd
cd /etc/apache2/
read -p "Donnez le nom d'utilisateur d'accès au wiki: " name_wiki
read -p "Donnez le nom du fichier .htpasswd [hors .htpasswd]" name_htpasswd
echo "Entrez le mot de passe du nouvel utilisateur :"
sudo htpasswd -cm .$name_htpasswd $name_wiki

# Création des virtualhosts
echo "Création des virtualhosts"
echo "Les virtualhosts seront ajoutés au fichier /etc/apache2/sites-available/001-wiki.conf"
read -p "Entrez le nom du nouveau wiki (il sera intégré dans le liens ****.ciml.cnrs): " name_server

echo '

<VirtualHost *:80>
        ServerName '$name_server'.ciml.cnrs

        DocumentRoot /var/www/html/'$name_repository'/

        Redirect permanent / https://'$name_server'.ciml.cnrs/

        <Directory /var/www/html/>
                Options -Indexes
                AuthType Basic
                AuthName "Contenue protégé par le service Informatique"
                AuthUserFile /etc/apache2/.'$name_htpasswd'
                Require valid-user
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:443>
        ServerName '$name_server'.ciml.cnrs

        DocumentRoot /var/www/html/'$name_repository'/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        <Directory /var/www/html/>
                Options -Indexes
                AuthType Basic
                AuthName "Contenue protégé par le service Informatique"
                AuthUserFile /etc/apache2/.'$name_htpasswd'
                Require valid-user
        </Directory>

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/'$name_server'.crt
        SSLCertificateKeyFile /etc/ssl/private/'$name_server'.key

        Header unset X-Powered-By
        Header always set X-Frame-Options DENY
        Header always set X-Content-Type-Options nosniff

        SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
        SSLCipherSuite HIGH:3DES:aNULL:!MD5:!SEED:!IDEA
        SSLHonorCipherOrder on
        Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
</VirtualHost>

' >> /etc/apache2/sites-available/001-wiki.conf

sudo systemctl restart apache2

echo "Maintenant rendez-vous sur $name_server.ciml.cnrs et suiver le tuto à partir de 'Configurer le wiki'"
echo "FIN DU SCRIPT"