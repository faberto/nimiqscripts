#!/bin/bash
# Easy Setup Script for NodeJS Nimiq Miner

#Get Settings
echo 'Please enter your domain(optional):'
read nimiqDomain

if [ "$nimiqDomain" != "" ]; then
        echo 'Letsencrypt Cert Folder(leave blank for default)'
        read nimiqCert
        if [ "$nimiqCert" == "" ]; then
        nimiqCert="/etc/letsencrypt/live"
        fi
fi

echo 'Use TestNet? (Type YES or leave blank for mainnet)'
read nimiqTestnet

if [ "$nimiqTestnet" == "YES" ]; then
        nimiqTestnet="--network=test"
else
        nimiqTestnet=""
fi


echo 'Please enter the number of Miningthreads: '
read nimiqThreads

echo 'Enter the name of the script to be generated(default: mine.sh): '
read nimiqScript

if [ "$nimiqScript" == "" ]; then
        nimiqScript="mine.sh"
fi

echo 'Enter Wallet Address (NOT SEED): '
read nimiqAddress

echo 'Enter Extra-Data Field (Optional,Useful for multiple miners on the same Address): '
read nimiqExtra


#Generate Mining Runscript
touch $nimiqScript
chmod +x $nimiqScript
echo "cd core/clients/nodejs/" >> $nimiqScript 

if [ "$nimiqDomain" == "" ]; then
    nimiqDoD="--dumb"
else
    nimiqDoD="--host=$nimiqDomain --cert=$nimiqCert/$nimiqDomain/cert.pem --key=$nimiqCert/$nimiqDomain/privkey.pem"
fi



echo "env UV_THREADPOOL_SIZE=$nimiqThreads node index.js $nimiqTestnet --wallet-address=\"$nimiqAddress\" --port=5566 --miner=$nimiqThreads --statistics=10 $nimiqDoD --extra-data=\"$nimiqExtra\"" >> $nimiqScript
