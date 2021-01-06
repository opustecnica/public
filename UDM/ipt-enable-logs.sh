#!/bin/bash

# [TODO] Convert this script to use #!/bin/sh (ash) to avoid interaction with unifi-os container.
# [NOTE] Standard environment has the iptables utilities, but bash is only available in the unifi-os container.
# [NOTE] Bash has a a cleaner way to deal with arrays.
# [NOTE] Need to find a hook to run this script not only at startup but every time time the firewall is modified.

# Collect existing iptables configuration into an array.
IPTABLES=()
while IFS= read -r line; do
    IPTABLES+=( "$line" )
done < <( ssh -q -o StrictHostKeyChecking=no root@127.0.1.1 'iptables-save' )

# Clear existing ipt-save if it exists.
FILE=/data/ipt-save
if test -f "$FILE"; then
  rm -f $FILE
fi

for i in ${!IPTABLES[@]}; do
  x=$((i + 1))
  if [[ ${IPTABLES[$i]} =~ LOG$ ]]
    then
      ACTION=`echo "${IPTABLES[$x]}" | sed -E "s/.*-j\s(.*)$/\1/"` 
      if [[ $ACTION =~ ^RETURN$ ]]; then ACTION='ACCEPT'; fi
      echo -e "${IPTABLES[$i]}" | sed -E "s/^-A\sUBIOS_(\S+)\s.*-j LOG$/& --log-prefix \"[${ACTION}_\1] \"/" >> $FILE 
      # echo lines that are affected by the changes to STDOUT
      echo "${i} ${IPTABLES[$i]}" | sed -E "s/^\w+\s-A\sUBIOS_(\S+)\s.*-j LOG$/& --log-prefix \"[${ACTION}_\1] \"/" 
      echo "${x} ${IPTABLES[$x]}"
    else
      echo -e "${IPTABLES[$i]}" >> $FILE
  fi
done

