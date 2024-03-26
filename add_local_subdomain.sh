#!/usr/bin/bash

# don't allow script execution if not executing as sudo
if [ "$EUID" -ne 0 ]
        then echo "must run as root"
        exit
fi

while getopts s:p: flag
do
	case "$flag" in 
		s) new_subdomain=${OPTARG};; # text for the subdomain
		p) port=${OPTARG};; # port that the service is running on
	esac
done

last_dns=$(tail -1 /etc/self-signed_certs/extfile.cnf | grep -o -E '[0-9]+') 
((last_dns++)) # the subdomain should be added with the last DNS value + 1 in the extfile.cnf file

echo "DNS.$last_dns = $new_subdomain.serber" >> /etc/self-signed_certs/extfile.cnf

openssl x509 -req -sha256 -days 36500 -in /etc/self-signed_certs/cert.csr -CA /etc/self-signed_certs/ca.pem -CAkey /etc/self-signed_certs/ca-key.pem -out /etc/self-signed_certs/cert.pem -extfile /etc/self-signed_certs/extfile.cnf -extensions v3_req -CAcreateserial

## configure nginx sites-available file
echo "server {" >> /etc/nginx/sites-available/local-services
echo "    listen 80;" >> /etc/nginx/sites-available/local-services
echo "    server_name $new_subdomain.serber;" >> /etc/nginx/sites-available/local-services
echo "" >> /etc/nginx/sites-available/local-services
echo "    return 301 https://\$host\$request_uri;" >> /etc/nginx/sites-available/local-services
echo "}" >> /etc/nginx/sites-available/local-services
echo "" >> /etc/nginx/sites-available/local-services
echo "server {" >> /etc/nginx/sites-available/local-services
echo "    listen 443 ssl;" >> /etc/nginx/sites-available/local-services
echo "    server_name $new_subdomain.serber;" >> /etc/nginx/sites-available/local-services
echo "" >> /etc/nginx/sites-available/local-services
echo "    ssl_certificate /etc/self-signed_certs/cert.pem;" >> /etc/nginx/sites-available/local-services
echo "    ssl_certificate_key /etc/self-signed_certs/cert-key.pem;" >> /etc/nginx/sites-available/local-services
echo "" >> /etc/nginx/sites-available/local-services
echo "    location / {" >> /etc/nginx/sites-available/local-services
echo "        proxy_pass http://localhost:$port;" >> /etc/nginx/sites-available/local-services
echo "        proxy_set_header Host \$host;" >> /etc/nginx/sites-available/local-services
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/sites-available/local-services
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/sites-available/local-services
echo "        proxy_set_header X-Forwarded-Proto \$scheme;" >> /etc/nginx/sites-available/local-services
echo "    }" >> /etc/nginx/sites-available/local-services
echo "}" >> /etc/nginx/sites-available/local-services
echo "" >> /etc/nginx/sites-available/local-services

ufw allow $port

## reload the nginx configuration
nginx -s reload
