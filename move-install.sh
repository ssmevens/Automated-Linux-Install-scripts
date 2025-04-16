#bin/bash

#this script removes sets up the install of the autoamted linux installs
# delete the existing install folders
 
mkdir /var/www/installs
mkdir /var/www/installs/bookworm
mkfir /var/www/installs/mint

sudo rsync -a --delete ./bookworm/ /var/www/installs/bookworm
sudo rsync -a --delete ./mint/ /var/www/installs/mint

# set permissions
sudo chmod -R 755 /var/www/installs
sudo chown -R www-data:www-data /var/www/installs

# restart nginx
sudo systemctl restart nginx

echo "Files moved and permissions set"
