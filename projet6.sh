#!/bin/bash
#Début du script d'automatisation de l'installation de WP

#Déclaration de mes variables
dossier_temporaire="/tmp"

#Supression et création du fichier  install.log
if [ -f ./install.log ] ; then
	echo "Le fichier install.log existe, il sera supprimer et re-créer de nouveau  ..."
	echo
	echo "Création du fichier install.log en cours ..."
	touch ./install.log
	echo
fi 

#Mise a jour du système d'exploitation
echo "La mise a jour du système d'exploitation est en cours, Patientez SVP ... "
echo
apt update > install.log 2>&1 && sudo apt full-upgrade -y > install.log 2>&1

# Installation de ZIP et GZIP
if [ -x /usr/bin/zip ]; then
	echo "Le programme Zip est présent dans le système ..."
else 
	echo "Installation de zip en cours ..."
	apt install zip -y >> install.log 2>&1
	echo
fi

if [ -x /usr/bin/gzip ]; then
	echo "Le programme Gzip est présent dans le système ..."
	echo
else
	echo "Installation de Gzip en cours ..."
	apt install gzip -y >> install.log 2>&1
	echo
fi

#Vérification si Apache2 est installé sur le serveur
if [ -d /etc/apache2/ ]
then
	echo "Le serveur web apache2 est dèja installé ..."
	echo
else
	#Installation de apache2
	echo "Installation du serveur web appache en cours ..."
	apt install apache2 -y >> install.log 2>&1
	echo

	echo "Lancement d'appache2 au démarrage du systèmes"
	systemctl enable apache2 >> install.log 2>&1
	echo 

	echo "Activation des modules Gzip,headers,rewrite, SSL"
	echo "Gzip ok ..."
	a2enmod gzip >> install.log 2>&1
	echo "headers ok ..."
	a2enmod headers >> install.log 2>&1
	echo "rewrite ok ..."
	a2enmod rewrite >> install.log 2>&1
	echo "ssl ok ..."
	a2enmod ssl >> install.log 2>&1
	echo

	echo "Reboot de apache2 en cours ...."
	systemctl restart apache2 >> install.log 2>&1
	echo
fi

#Crétion d'un dossier wp dans /tmp
if [ -d /tmp/wp/ ] ; then
	echo "le dossier WP  existe ..."
	echo
	echo "Déplacement vers /tmp/wp/ ..."	
	cd /tmp/wp/
	echo	
else
	echo "création du dossier WP en cours ..."
	mkdir /tmp/wp
	echo
	echo "Déplacement dans /tmp/wp/ OK ..."
	cd /tmp/wp
	echo
	echo "Téléchargement de la dernière version de wordpress en cours ..."
	wget https://wordpress.org/latest.zip >> install.log 2>&1
	echo
fi

#Vérification si wordpress a été dèja télécharger
	if [ -f /tmp/wp/latest* ]; then
		echo "La dernière version de WP est dèja téléchargée ..."
		echo
	else
		echo "Wordpress n'existe pas, lancement du téléchargement en cours  ..."
		wget https://wordpress.org/latest.zip >> install.log 2>&1
		echo
	fi

# Installation de PHP
if [ -x /usr/bin/php ]; then
	echo "php est dèja installé sur le serveur ..."
	echo
else
	echo "Installation de PHP et des modules php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmatch en cours ..."
	apt install php php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmatch -y >> install.log 2>&1
	echo
fi

#Installation de MariaDB
if [ -x /usr/bin/mariadb ]; then 
	echo "Le serveur MariaDB est dèja installé sur le système ..."
	echo
else
	echo "Installation du serveur Mariadb en cours ..."
	apt install mariadb-server -y >> install.log 2>&1
	echo
fi

#Autoriser mariadb a démarrer avec le boot du système
echo "Mariadb startup OK ..."
systemctl enable mariadb >> install.log 2>&1
echo

echo "reboot mariadb OK ..."
systemctl restart mariadb
echo

# Automatisation des réponses au script mariadb_secure_installation
if [ -x /usr/bin/expect ]
then 
	echo "expect est dèja installer ..."
	echo
else
echo "installation de expect en cours ..."
apt -y install expect >> install.log 2>&1
echo

MYSQL_ROOT_PASSWORD=123456

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL_ROOT_PASSWORD\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect EOF
")

# Création de la BDD pour l'installation de wordpress

mariadb -e "CREATE DATABASE wp_smail_projet6;"
echo "création ok"
mariadb -e "show databases;"

echo "fin du script"
