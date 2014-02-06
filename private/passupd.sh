#!/bin/bash

if [ $# -lt 3 ];then
	cat<<EOF
Updates a .htpasswd file with a new user password combo to limit concurrency on the server (and keep out those pesky kids).
	
	usage: `basename $0` <htpass file> <log_file> <"user1"> ["user2" ...]

	log_file = place to log passes in case of emergency
EOF
	exit -1
fi

passfile=$1
logpass=$2
users="${@:3}"

password(){
	lenword=0
	while [ $lenword -lt 8 ]; do
	
		randword=$(fortune -s | head -1 | awk '{print $(NF-1)}')
		lenword=$(echo $randword | wc -c )
	done
	echo $randword
}


## manually delete if you want to start over
#rm $passfile $logpass;

for user in $users; do
	pass=$(password)
	pass=$(echo $pass) # trim

	htoutput=$(htpasswd -nb $user $pass)

	echo "$user -- $pass" >> $logpass
	echo $htoutput >> $passfile
done
