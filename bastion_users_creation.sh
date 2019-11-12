#!/bin/bash

echo "

### Author: Walid Ayada ###

### Script Prerequists  ###

Run aws configure and pass Access key ID, Secret access key, default region


### Script do the following ###

# -Create Keypair for each user
# -Retrieving the Public Key for Your Key Pair on Linux
# -Create Linux users
# -adapting the users .ssh and authorized permssions
# -Appending the public key for each user at it's .ssh/authorized_keys
"


for user in "$@"
 do

aws ec2 create-key-pair --key-name $user --query 'KeyMaterial' --output text > ${user}.pem
chmod 400 ${user}.pem
public_key=`ssh-keygen -y -f ${user}.pem`

sudo adduser $user
sudo  -i -u $user bash  << EOF 
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
echo "$public_key" > .ssh/authorized_keys

if [ $? -eq 0 ]
then
echo "User $user created sussefully"
fi
EOF
done

