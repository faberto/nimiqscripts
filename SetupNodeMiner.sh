#!/bin/bash
# Easy Setup Script for NodeJS Nimiq Miner

#Get Settings
echo 'Please enter your domain:'
read nimiqDomain
echo 'Please enter the number of Miningthreads'
read nimiqThreads
echo 'Enter the name of the script to be generated(e.g. mine.sh):'
read nimiqScript
echo 'Remove Apache if installed?(Type:YES)'
read nimiqApache


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
sudo npm install
sudo npm run build

#setup Letsencrypt
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot

#remove apache2 if installed
if [ "$nimiqApache" = "YES" ]; then
    sudo apt-get remove apache2
fi


#Get SSL Cert
sudo certbot certonly --standalone --preferred-challenges http -d $nimiqDomain

#Generate Mining Runscript
cd ..
touch $nimiqScript
chmod +x $nimiqScript
echo "cd core/clients/nodejs/" >> $nimiqScript 
echo "node index.js --host=$nimiqDomain --port=5566 --cert=/etc/letsencrypt/live/$nimiqDomain/cert.pem --key=/etc/letsencrypt/live/$nimiqDomain/privkey.pem -miner=$nimiqThreads --statistics=1" >> $nimiqScript
