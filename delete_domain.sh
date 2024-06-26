
#!/bin/bash

# Define domain names to be deleted
domains=("worker01" "master02" "master01" "master03" "worker02" "Haproxy")

# Loop through each domain and try to undefine and destroy it
for domain in "${domains[@]}"; do
    echo "Undefining and destroying domain: $domain"
    virsh destroy $domain 2>/dev/null
    virsh undefine $domain 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Successfully undefined and destroyed domain: $domain"
    else
        echo "Failed to undefine or destroy domain: $domain or it does not exist"
    fi
done


