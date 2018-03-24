#!/bin/bash
# Easy Setup Script for NodeJS Nimiq Miner

#Get Settings
echo 'Please enter your domain: '
read nimiqDomain
echo 'Please enter the number of Miningthreads: '
read nimiqThreads
echo 'Enter the name of the script to be generated(e.g. mine.sh): '
read nimiqScript
echo 'Enter Wallet Address (NOT SEED): '
read nimiqAddress
echo 'Enter email address for letsencrypt: '
read nimiqEmail

#Check for possible conflicts
toremove=""
declare -a rmvdeps=("apache2" "nginx")

for i in "${rmvdeps[@]}"
do
   dpkg -s "$i" &> /dev/null
   if [ $? -eq 1 ]; then
        echo "$i Check Complete"
    else
        read -p "$i detected. Do you want to remove it?(Type:YES) " rmvi
        if [ "$rmvi" = "YES" ]; then
                echo "Removing $i!"
                toremove="$i $toremove"
        fi
fi
done

#remove possible conflicts if installed (and selected to remove)
if [ "$toremove" != "" ]; then
        sudo apt-get -y purge $(echo "$toremove" | xargs)
fi

#Make sure system is updated
sudo apt-get update
sudo apt-get -y upgrade

#Install requirements
sudo apt-get install -y curl git build-essential

#Setup NodeJS
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

#Add Gulp globally
sudo npm install -g gulp

#Get the Nimiq project
git clone https://github.com/nimiq-network/core

#Build Nimiq project
cd core
npm install
npm run build
cd clients/nodejs
npm install
cd ../../
npm run prepare

#setup Letsencrypt
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot

#Get SSL Cert
sudo certbot --non-interactive --agree-tos -m $nimiqEmail certonly --standalone --preferred-challenges http -d $nimiqDomain

#Generate Mining Runscript
cd ..
touch $nimiqScript
chmod +x $nimiqScript
echo "cd core/clients/nodejs/" >> $nimiqScript 
echo "node index.js --host=$nimiqDomain --wallet-address=\"$nimiqAddress\" --port=5566 --cert=/etc/letsencrypt/live/$nimiqDomain/cert.pem --key=/etc/letsencrypt/live/$nimiqDomain/privkey.pem -miner=$nimiqThreads --statistics=1" >> $nimiqScript
