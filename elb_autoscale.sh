#!/bin/bash

export PORT=3000
export DB_HOST=localhost
export DB_PORT=5329
export DB_USER=mariadb
export DB_PASSWORD=123
export DB_NAME=catalogo


export PGPASSWORD=$DB_PASSWORD

echo "Variáveis de ambiente configuradas."
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME



 backend () {
 aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 314296197182.dkr.ecr.us-east-2.amazonaws.com
docker build -t bootcamp .
docker tag bootcamp:latest 314296197182.dkr.ecr.us-east-2.amazonaws.com/bootcamp:latest
docker push 314296197182.dkr.ecr.us-east-2.amazonaws.com/bootcamp:latest
}

frontend () {
puxar arquivo front pelo amplify
} 
