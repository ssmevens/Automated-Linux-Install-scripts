#bin/bash

#this script removes sets up the install of the autoamted linux installs
# delete the existing install folders
 
sudo rsync -a --delete ./bookworm/ /var/www/install/bookworm
sudo rsync -a --delete ./mint/ /var/www/install/mint

# set permissions
sudo chmod -R 755 /var/www/install
sudo chown -R www-data:www-data /var/www/install

# restart nginx
sudo systemctl restart nginx

echo "Files moved and permissions set"
