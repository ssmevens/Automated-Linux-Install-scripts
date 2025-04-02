#bin/bash

#this script removes sets up the install of the autoamted linux installs
# delete the existing install folders
rm -rf /var/www/html/install/bookworm
rm -rf /var/www/html/install/mint

# move the new install folders to the web root
mv ./bookworm /var/www/html/install/bookworm
mv ./mint /var/www/html/install/mint

# set permissions
chmod -R 755 /var/www/html/install
chown -R www-data:www-data /var/www/html/install

# restart nginx
systemctl restart nginx


