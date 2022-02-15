#Début du script d'automatisation de l'installation de WP



#Mise a jour du système d'exploitation
sudo apt update > install.log 2>&1 && sudo apt full-upgrade -y > install.log 2>&1
echo "mise a jour de l'OS en cours ..."
echo  

#Installation de apache2 et de ces dépendances
