#!/bin/bash

# We need this helper to get popstgres URI and username/password combo since the gitea chart needs it in its values, this will NOT be part of git since storing secrets in git is bad
SECRET_NAME=$(aws secretsmanager list-secrets --filters Key=tag-value,Values=${STACK_ID}  | jq .SecretList[].Name -r)

#  "dbClusterIdentifier": "gitea-postgres-auroradbcluster-1geq0j1dxxrgb",
#  "password": "}o*N<4I<!,aMc3s`",
#  "dbname": "gitea",
#  "engine": "postgres",
#  "port": 5432,
#  "host": "gitea-postgres-auroradbcluster-1geq0j1dxxrgb.cluster-cipbmaz91imc.eu-central-1.rds.amazonaws.com",
#  "username": "gitea"
USERNAME=$(aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} | jq .SecretString -r | jq .username -r)
PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} | jq .SecretString -r | jq .password -r)
PORT=$(aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} | jq .SecretString -r | jq .port -r)
HOST=$(aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} | jq .SecretString -r | jq .host -r)
DB_NAME=$(aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} | jq .SecretString -r | jq .dbname -r)

# Prepare database
kubectl run \
  postgres-client \
  --image launcher.gcr.io/google/postgresql9 \
  --rm --attach --restart=Never \
  -it \
  -- sh -c 'export PGPASSWORD='"'${PASSWORD}'"'; exec psql --host '"'${HOST}'"' --port '"'${PORT}'"' --username '"'${USERNAME}'"' --command="CREATE DATABASE gitea WITH OWNER gitea TEMPLATE template0 ENCODING UTF8 LC_COLLATE '"'"'en_US.UTF-8'"'"' LC_CTYPE '"'"'en_US.UTF-8;'"'"'"'

# and schema, i guess the documentation on gitea is a bit wrong
kubectl run \
  postgres-client \
  --image launcher.gcr.io/google/postgresql9 \
  --rm --attach --restart=Never \
  -it \
  -- sh -c 'export PGPASSWORD='"'${PASSWORD}'"'; exec psql --host '"'${HOST}'"' --port '"'${PORT}'"' --username '"'${USERNAME}'"' --command="CREATE SCHEMA gitea AUTHORIZATION gitea"'

# We need to preapply the namespace
kubectl apply -f ../flux/gitea/gitea-namespace.yaml

cat <<EOF >> tmp.yaml
apiVersion: v1
stringData:
  values.yaml: |
    gitea:
      config:
        database:
          DB_TYPE: postgres
          HOST: ${HOST}:${PORT}
          NAME: gitea
          USER: ${USERNAME}
          PASSWD: "${PASSWORD}"
          SCHEMA: ${DB_NAME}
          SSL_MODE: require
kind: Secret
metadata:
  name: gitea-database
  namespace: gitea
type: Opaque
EOF

kubectl apply -f tmp.yaml
rm tmp.yaml
