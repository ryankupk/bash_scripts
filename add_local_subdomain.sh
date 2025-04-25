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

echo "Adding subdomain $new_subdomain to extfile and nginx configuration"

# Check if the subdomain already exists in the extfile.cnf
extfile="/etc/self-signed_certs/extfile.cnf"
if ! grep -q "$new_subdomain.serber" "$extfile"; then
    # Increment the DNS number and update the extfile.cnf
    last_dns=$(tail -1 "$extfile" | grep -o -E '[0-9]+')
    ((last_dns++)) # the subdomain should be added with the last DNS value + 1 in the extfile.cnf file

    echo "DNS.$last_dns = $new_subdomain.serber" >> "$extfile"
    echo "Subdomain $new_subdomain.serber has been added to $extfile."
else
    echo "Subdomain $new_subdomain.serber already exists in $extfile."
fi

# Re-generate the SSL certificate (this always runs)
openssl x509 -req -sha256 -days 36500 -in /etc/self-signed_certs/cert.csr -CA /etc/self-signed_certs/ca.pem -CAkey /etc/self-signed_certs/ca-key.pem -out /etc/self-signed_certs/cert.pem -extfile "$extfile" -extensions v3_req -CAcreateserial
if [ $? -ne 0 ]; then
    echo "Certificate regeneration failed. Exiting."
    exit 1
fi

# Add the upstream configuration to Nginx config
nginx_config_file="/etc/nginx/sites-available/local-services"

# Check if the subdomain is already in the Nginx configuration
if ! grep -q "if (\$host = $new_subdomain.serber)" "$nginx_config_file"; then
    # Use `sed` to insert the new block before `proxy_pass $upstream;`
    sed -i "/proxy_pass \$upstream;/i \                if (\$host = $new_subdomain.serber) {\n                    set \$upstream \"http://127.0.0.1:$port\";\n                }\n" "$nginx_config_file"

    echo "Upstream configuration for $new_subdomain.serber has been added to $nginx_config_file."
else
    echo "Subdomain $new_subdomain.serber already exists in the Nginx configuration."
fi

ufw allow $port

## reload the nginx configuration
nginx -s reload
