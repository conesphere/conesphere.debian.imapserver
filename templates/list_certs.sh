#!/bin/bash
cd /etc/letsencrypt/live 
for dom in * 
do
	dat=$(openssl x509 -text -in ${dom}/cert.pem  | grep "Not After")
	dat=${dat##*Not After : }
	expire=`date -d "${dat}" +%s`
	now=$(date +%s)
	diff=$(($expire - $now))
	diff="$(($diff / 3600 / 24))d $(($diff / 3600 % 24))h $(($diff / 60 % 60))min $(($diff % 60))s"
	echo "${dom}   Expires: ${dat}   Time left: ${diff}"
done

