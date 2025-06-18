#!/bin/bash

echo "Setting up Elasticsearch passwords..."

# Wait for Elasticsearch to be ready
echo "Waiting for Elasticsearch to start..."
until curl -s --cacert certs/ca/ca.crt -u "elastic:12345678" "https://localhost:9200/_cluster/health" > /dev/null; do
    echo "Waiting for Elasticsearch..."
    sleep 5
done

echo "Elasticsearch is ready!"

# Set kibana_system password
echo "Setting kibana_system password..."
curl -X POST --cacert certs/ca/ca.crt -u "elastic:12345678" \
  "https://localhost:9200/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  -d '{"password":"kibana123"}'

echo ""
echo "Password setup complete!"
echo "You can now restart Kibana or start it if it's not running."
echo ""
echo "Credentials:"
echo "- Elasticsearch admin: elastic / 12345678"
echo "- Kibana system: kibana_system / kibana123"