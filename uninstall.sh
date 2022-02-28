#!/bin/bash

dossier_travail="/root/projet-6-python"

cd $dossier_travail

if [ -f ./uninstall.log ]; then
	echo "le fichier uninstall.log existe, lancement de la suppression en cours ! ... "
	rm -rf ./uninstall.log
else
	echo "création du fichier uninstall.log en cours, veuillez patientez svp ! ... "
	touch uninstall.log
fi

#purge
apt purge apache2* php* zip mariadb-server* -y


#tmp delete
echo "delete /tmp/wp/*"
rm -rf /tmp/wp/* >> uninstall.log 2>&1
echo

# remove wordpress
echo "purge WP installation"
echo
apt purge wordpress* -y >> uninstall.log 2>&1

# remove expect
echo "suppression de expect"
echo
apt remove -y expect >> uninstall.log 2>&1

# autoremove
echo "apt autoremove"
apt autoremove -y >> uninstall.log 2>&1
echo

echo "FIN du script"
