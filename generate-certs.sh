#!/bin/bash

# Exit on any error
set -e

echo "Creating SSL certificates for Elasticsearch and Kibana..."

# Remove existing certs directory if it exists
if [ -d "certs" ]; then
    echo "Removing existing certs directory..."
    rm -rf certs
fi

# Create certificates directory structure
mkdir -p certs/{ca,elasticsearch,kibana}
echo "Created certificate directories"

# Generate CA private key
openssl genrsa -out certs/ca/ca.key 4096

# Generate CA certificate
openssl req -new -x509 -days 365 -key certs/ca/ca.key -out certs/ca/ca.crt -subj "/C=US/ST=CA/L=San Francisco/O=MyCompany/OU=IT Department/CN=Elastic Certificate Authority"

# Generate Elasticsearch private key
openssl genrsa -out certs/elasticsearch/elasticsearch.key 4096

# Generate Elasticsearch certificate signing request
openssl req -new -key certs/elasticsearch/elasticsearch.key -out certs/elasticsearch/elasticsearch.csr -subj "/C=US/ST=CA/L=San Francisco/O=MyCompany/OU=IT Department/CN=elasticsearch"

# Create extensions file for Elasticsearch
cat > certs/elasticsearch/elasticsearch.ext << EOF
[v3_req]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = elasticsearch
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

# Generate Elasticsearch certificate
openssl x509 -req -in certs/elasticsearch/elasticsearch.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -CAcreateserial -out certs/elasticsearch/elasticsearch.crt -days 365 -extensions v3_req -extfile certs/elasticsearch/elasticsearch.ext

# Generate Kibana private key
openssl genrsa -out certs/kibana/kibana.key 4096

# Generate Kibana certificate signing request
openssl req -new -key certs/kibana/kibana.key -out certs/kibana/kibana.csr -subj "/C=US/ST=CA/L=San Francisco/O=MyCompany/OU=IT Department/CN=kibana"

# Create extensions file for Kibana
cat > certs/kibana/kibana.ext << EOF
[v3_req]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = kibana
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

# Generate Kibana certificate
openssl x509 -req -in certs/kibana/kibana.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key -CAcreateserial -out certs/kibana/kibana.crt -days 365 -extensions v3_req -extfile certs/kibana/kibana.ext

# Set proper permissions
chmod 644 certs/ca/ca.crt
chmod 644 certs/elasticsearch/elasticsearch.crt
chmod 600 certs/elasticsearch/elasticsearch.key
chmod 644 certs/kibana/kibana.crt
chmod 600 certs/kibana/kibana.key

# Clean up CSR files
rm -f certs/elasticsearch/elasticsearch.csr certs/elasticsearch/elasticsearch.ext
rm -f certs/kibana/kibana.csr certs/kibana/kibana.ext

echo "SSL certificates generated successfully!"
echo "Verifying certificate files..."

# Verify all required files exist
required_files=(
    "certs/ca/ca.crt"
    "certs/elasticsearch/elasticsearch.crt"
    "certs/elasticsearch/elasticsearch.key"
    "certs/kibana/kibana.crt"
    "certs/kibana/kibana.key"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing!"
        exit 1
    fi
done

echo ""
echo "All certificates generated successfully!"
echo "You can now run: docker-compose up -d"