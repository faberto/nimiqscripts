#!/bin/bash
# Easy Setup Script for NodeJS Nimiq Miner


#Required Setup
sudo apt-get update
sudo apt-get -y upgrade

#Install requirements
sudo apt-get install -y curl git build-essential python

#Setup NodeJS
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g yarn
yarn global add gulp

git clone https://github.com/nimiq-network/core





#Get Settings

echo 'Use NimiqPool.com ? ( Constant rewards, Default:YES (YES/NO) )'
read usePool
if [ "$usePool" == "NO" ]; then
        usePool=""
else
        usePool="--pool=node.nimiqpool.com:8444"
fi

echo 'Please enter your domain(optional):'
read nimiqDomain

if [ "$nimiqDomain" != "" ]; then
        echo 'Install Certbot/Letsencrypt? Default:YES (YES/NO) '
        read instCertbot
        if [ "$instCertbot" != "NO" ]; then
            #setup Letsencrypt
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository -y ppa:certbot/certbot
            sudo apt-get update
            sudo apt-get install -y certbot
        fi
        echo 'Letsencrypt Cert Folder(leave blank for default)'
        read nimiqCert
        if [ "$nimiqCert" == "" ]; then
        nimiqCert="/etc/letsencrypt/live"
        fi
        #Check for possible conflicts
        toremove=""
        declare -a rmvdeps=("apache2" "nginx")

        for i in "${rmvdeps[@]}"
        do
        dpkg -s "$i" &> /dev/null
        if [ $? -eq 1 ]; then
                echo "$i Check Complete"
            else
                read -p "$i detected. Do you want to remove it?(Default:NO (YES/NO)) " rmvi
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

        echo 'Get Certificate?(recommended, Default:YES (YES/NO)):'
        read getCert
        if [ "$getCert" != "NO" ]; then
            echo 'Enter Email'
            read certmail
            sudo certbot --non-interactive --agree-tos -m $certmail certonly --standalone --preferred-challenges http -d $nimiqDomain

        fi

fi

echo 'Use TestNet? (Default:NO (YES/NO))'
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

if [ "$nimiqDomain" == "" ]; then
    nimiqDoD="--dumb"
else
    nimiqDoD="--host=$nimiqDomain --cert=$nimiqCert/$nimiqDomain/cert.pem --key=$nimiqCert/$nimiqDomain/privkey.pem"
fi

#Generate Mining Runscript
touch $nimiqScript
chmod +x $nimiqScript

echo "cd core && git pull && yarn " >> $nimiqScript 

echo "cd clients/nodejs/" >> $nimiqScript 



echo "env UV_THREADPOOL_SIZE=$nimiqThreads node index.js $usePool $nimiqTestnet --wallet-address=\"$nimiqAddress\" --port=5566 --miner=$nimiqThreads --statistics=10 $nimiqDoD --extra-data=\"$nimiqExtra\"" >> $nimiqScript
