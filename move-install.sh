#bin/bash

#this script removes sets up the install of the autoamted linux installs
# delete the existing install folders
 
sudo rsync -a --delete ./bookworm/ /var/www/html/install/bookworm
sudo rsync -a --delete ./mint/ /var/www/html/install/mint

# set permissions
sudo chmod -R 755 /var/www/html/install
sudo chown -R www-data:www-data /var/www/html/install

# restart nginx
sudo systemctl restart nginx

echo "Files moved and permissions set"
