#!/bin/bash

# don't allow script execution if not executing as sudo
if [ "$EUID" -ne 0 ]
	then echo "must run as root"
	exit
fi

while getopts s:u:p: flag
do
	case "$flag" in
		s) new_subdomain=${OPTARG};;
		u) username=${OPTARG};;
		p) password=${OPTARG};;
	esac
done

echo "adding $new_subdomain to /etc/ddclient.conf";
echo "# $new_subdomain" >> /etc/ddclient.conf;
echo "ssl=yes \\" >> /etc/ddclient.conf;
echo "protocol=googledomains \\" >> /etc/ddclient.conf;
echo "use=web, web=https://domains.google.com/checkip \\" >> /etc/ddclient.conf;
echo "login=$username \\" >> /etc/ddclient.conf;
echo "password='$password' \\" >> /etc/ddclient.conf;
echo "$new_subdomain.ryankupka.dev" >> /etc/ddclient.conf;
echo "" >> /etc/ddclient.conf;

service ddclient restart

