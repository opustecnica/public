#!/bin/sh
# Check if the pub key has already been added
grep -q 'user@computer' /root/.ssh/authorized_keys
if [ $? -eq 0 ]
then
    echo "user@computer pub key is already present."
else
    cat /mnt/data/scripts/user_id_rsa.pub >> /root/.ssh/authorized_keys
    echo "Added user@computer pub key."
fi
