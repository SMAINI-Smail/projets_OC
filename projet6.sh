#Début du script d'automatisation de l'installation de WP

#Mise a jour du système d'exploitation
echo "La mise a jour du système d'exploitation est en cours, Patientez SVP ... "
echo
sudo apt update > install.log 2>&1 && sudo apt full-upgrade -y > install.log 2>&1

#Vérification si Apache2 est installé sur le serveur
if [  ]
#Installation de apache2
echo "Installation du serveur web appache en cours ..."
sudo apt install apache2 -y >> install.log 2>
