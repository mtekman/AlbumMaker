#!/bin/bash

passfile=$1

if [ "$passfile" = "" ];then
	cat<<EOF
Creates a new .htpasswd file with a weekly updated password to limit concurrency on the server (and keep out those pesky kids).
	
	usage: `basename $0` <htpass file>

EOF
	exit -1
fi

password(){
	lenword=0
	while [ $lenword -lt 8 ]; do
	
		randword=$(fortune -s | head -1 | awk '{print $(NF-1)}')
		lenword=$(echo $randword | wc -c )
	done
	echo $randword
}

pass=$(password)
pass=$(echo $pass) # trim

htoutput=$(htpasswd -nb tetris $pass)

echo $pass > ~/.config/plog.txt
echo $htoutput > $passfile
