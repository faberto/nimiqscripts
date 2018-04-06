# Nimiq Scripts
Scripts that help you to mine Nimiq


## Setup everything for Nimiq mining on Ubuntu:
```sh
bash <(wget -qO- https://raw.githubusercontent.com/faberto/nimiqscripts/master/SetupNodeMiner.sh)
```


## Create a NodeJS startscript if you already have the Nimiq NodeJS Client installed:
Go into the Parent dictionary of core ( if you type "ls -la" you should see something like this)
```sh
drwxr-xr-x  4 faberto faberto 4096 Apr  6 15:04 .
drwxr-xr-x  4 faberto faberto 4096 Apr  6 14:53 ..
drwxr-xr-x 12 faberto faberto 4096 Apr  4 10:28 core
.....
```
Now copy and paste the following line into the terminal
```sh
bash <(wget -qO- https://raw.githubusercontent.com/faberto/nimiqscripts/master/NodeStartGenerator.sh)
```
