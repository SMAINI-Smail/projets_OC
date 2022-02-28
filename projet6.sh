#!/bin/bash
#Début du script d'automatisation de l'installation de WP

#Déclaration de mes variables
dossier_temporaire="/tmp"

#Supression et création du fichier  install.log
if [ -f ./install.log ] ; then
	echo "- Le fichier install.log existe, il sera supprimer et re-créer de nouveau  ..."
	echo
	echo "- Création du fichier install.log en cours ..."
	touch ./install.log
	echo
fi 

#Mise a jour du système d'exploitation
echo "- La mise a jour du système d'exploitation est en cours, Patientez SVP ... "
echo
apt update > install.log 2>&1 && sudo apt full-upgrade -y > install.log 2>&1

# Installation de ZIP et GZIP
if [ -x /usr/bin/zip ]; then
	echo "- Le programme Zip dèja est présent dans le système ..."
	echo
else 
	echo "- Installation de zip en cours ..."
	apt install zip -y >> install.log 2>&1
	echo
fi

if [ -x /usr/bin/gzip ]; then
	echo "- Le programme Gzip est présent dans le système ..."
	echo
else
	echo "- Installation de Gzip en cours ..."
	apt install gzip -y >> install.log 2>&1
	echo
fi

#Vérification si Apache2 est installé sur le serveur
if [ -x /usr/sbin/apache2 ]
then
	echo "- Le serveur web apache2 est dèja installé ..."
	echo
else
	#Installation de apache2
	echo "- Installation du serveur web appache en cours ..."
	apt install apache2 -y >> install.log 2>&1
	echo

	echo "- Lancement d'appache2 au démarrage du systèmes"
	systemctl enable apache2 >> install.log 2>&1
	echo 

	echo "- Activation des modules Gzip,headers,rewrite, SSL"
	echo
	echo "Gzip ok ..."
	a2enmod gzip >> install.log 2>&1
	echo "headers ok ..."
	a2enmod headers >> install.log 2>&1
	echo "rewrite ok ..."
	a2enmod rewrite >> install.log 2>&1
	echo "ssl ok ..."
	a2enmod ssl >> install.log 2>&1
	echo

	echo "- Reboot de apache2 en cours ...."
	systemctl restart apache2 >> install.log 2>&1
	echo
fi

#Crétion d'un dossier wp dans /tmp
if [ -d /tmp/wp/ ] ; then
	echo "- le dossier WP  existe ..."
	echo
	echo "- Déplacement vers /tmp/wp/ ..."	
	cd /tmp/wp/
	echo	
else
	echo "- création du dossier WP en cours ..."
	mkdir /tmp/wp
	echo
	echo "- Déplacement dans /tmp/wp/ OK ..."
	cd /tmp/wp
	echo
fi

#Vérification si wordpress a été dèja télécharger
	if [ -f /tmp/wp/latest* ]; then
		echo "- La dernière version de WP est dèja téléchargée ..."
		echo
	else
		echo "- Wordpress n'existe pas, lancement du téléchargement en cours  ..."
		echo
		echo -ne '>\r'
		sleep 3
		echo -ne '>>>>>\r'
		sleep 3
		echo -ne '>>>>>>>>>>\r'
		sleep 3
		echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   (50%)\r'
		sleep 3
		echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> (75%)\r'
		sleep 3
		echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>(100%)\r'
		sleep 1
		echo
		wget https://wordpress.org/latest.zip >> install.log 2>&1
		echo
	fi

# Installation de PHP
if [ -x /usr/bin/php ]; then
	echo "- php est dèja installé sur le serveur ..."
	echo
else
	echo "- Installation de PHP et des modules php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmatch en cours ..."
	apt install php -y >> install.log 2>&1 
	apt install php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmatch -y >> install.log 2>&1
	echo
fi

#Installation de MariaDB
if [ -x /usr/bin/mariadb ]; then 
	echo "- Le serveur MariaDB est dèja installé sur le système ..."
	echo
else
	echo "- Installation du serveur Mariadb en cours ..."
	apt install mariadb-server -y >> install.log 2>&1
	echo
fi

#Autoriser mariadb a démarrer avec le boot du système
echo "- Mettre MariaDB au démarrage du système  OK ..."
systemctl enable mariadb >> install.log 2>&1
echo

# Reboot MariaDB
systemctl restart mariadb
if [ $? == 0 ]; then 
	echo "- MariaDB a été redémarer avec succès ... !"
	echo
else
	echo "- une erreur a été rencontrer lors du redémarrage de MariaDB"
	echo
fi


# Automatisation des réponses au script mariadb_secure_installation

mot_de_passe_root="123456"

# Changement mot de passe root
mariadb -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', 'mysql_native_password', '$.authentication_string', PASSWORD('$mot_de_passe_root')) WHERE User='root';"
if [ $? == 0 ]; then 
	echo "- Le mot de passe root a été mise a jour avec succès ..."
	echo
else
	echo "- une erreur a été rencontrer, merci de vérifier la syntaxe svp ..."
	echo
fi

# Suppression de l'utilisateur anonymous
mariadb -e "DELETE FROM mysql.global_priv WHERE User='';"
if [ $? -eq 0 ]; then
	echo "- La suppression  de l'accès anonyme a été menée avec succès ..."
	echo 
else
	echo "- Une erreur c'est produite lors de l'exécution de la commande, veuillez vérifier la syntaxe svp ..."
	echo
fi	

# Création de la BDD pour l'installation de WORDPRESS

BDD="wp_smail_projet6"

mariadb -e "CREATE DATABASE $BDD;" >> install.log 2>&1
if [ $? == 0 ]; then
	echo "- la base de donnée $BDD a été créer avec succès ..."
	echo
else
	echo "- la base de donnée existe dèja, veuillez vérifier avec un Show databases svp ..."
	echo
fi

# Suppression de l'accès distant pour root
mariadb -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
if [ $? -eq 0 ]; then
	echo "- L'accès distant a été supprimer pour l'utilisateur root"
	echo
else
	echo "- Erreur lors de l'exécution de la commande, veuillez vérifier la syntaxe svp ..."
        echo	
fi

# Suppression de la BDD test
mariadb -e "DROP DATABASE test;" >> install.log 2>&1
if [ $? -eq 0 ]; then
	echo "- La base de données test a été supprimée avec succès ..."
	echo
else
	echo "- La BDD n'existe pas ..."
	echo
fi

# Suppression des privilèges sur la BDD test
mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
if [ $? -eq 0 ]; then
	echo "- Privilèges supprimer avec Succes ..."
	echo
else
	echo "- Un soucis avec l'exécution de la commande, veuillez vérifier la syntaxe svp ..."
	echo
fi

# Recharger les privilèges 
mariadb -e "FLUSH PRIVILEGES;"
    if [ $? -eq 0 ]; then
	echo "- Rechargement des privilèges  OK ..."
	echo
    else
	echo "- Erreur, veuillez vérifier la syntaxe ..."
	echo
    fi

# Ajout d'utilisateur admin_projet6 a mariadb

admin="admin_projet6"
pass_BDD="mon_super_password"

mariadb -e "CREATE USER '$admin'@'localhost' IDENTIFIED BY '$pass_BDD';" >> install.log 2>&1
if [ $? == 0 ]; then 
	echo "- L'utilisateur $admin a été créer avec succès ..."
	echo
else
	echo "- L'utilisateur $admin existe dèja dans MariaDB ..."
	echo
fi

# Donner les droits pour l'admin_projet6 sur la BDD wp_smail_projet6
mariadb -e "GRANT ALL PRIVILEGES ON $BDD.* TO $admin@localhost;"
if [ $? == 0 ]; then 
	echo "- Droits octroyés a admin_projet6 sur la BDD wp_smail_projet6 avec succès ..."
	echo
else
	echo "- Erreur, merci de vérifier la syntaxe ..."
	echo
fi

# Rechargement des privilèges
mariadb -e "FLUSH PRIVILEGES;"
if [ $? == 0 ]; then 
	echo "- Rechargement ok ..."
	echo 
else
	echo "- Rechargement NOK, vérifiez la syntaxe svp ..."
	echo
fi

# Suppression Index.html depuis /var/www/html
cd /var/www/html
if [ $? == 0 ]; then
	echo "- Changement de dossier ok ..."
	echo 
else 
	echo "Erreur, vérifiez le chemin d'accès svp ..."
	echo
fi

if [ -f index.html ]
then 
	echo "- Suprresion de index.html en cours ..."
	rm -f index.html
	echo
else
	echo "- Index.html n'existe pas ... "
	echo
fi

# Unzip et déplacement de WP vers /var/www/html
cd /tmp/wp/
echo " - Déplacement vers le dossier WP ce trouvant dans /tmp OK ..."

if [ -d /tmp/wp/wordpress ]; then
	echo "- Le dossier wordpress existe ..."
	echo
else
	echo "- Décompression de wordpress en cours, veuillez patientez ..."
        unzip latest.zip
        echo
fi	

echo "- Déplacement du contenu worpdress dans /var/www/html en cours"
echo	
	
mv wordpress/* /var/www/html >> install.log 2>&1
if [ $? == 0 ]; then 
	echo "- Le déplacement des fichiers a été effectué avec succès ..."
	echo 
else
	echo "- Le dossier /var/www/html n'est pas vide, impossible de déplacement les fichiers, assurez vous qu'il soit vide avant de refaire l'opération ..."
	echo
fi

echo "- Changement des droits d'accès sur l'ensemble des fichiers contenant dans /var/www/html"
echo
chown -R www-data:www-data /var/www/html/

echo "fin du script"
