#!/bin/bash

export DB_HOST=localhost
export DB_PORT=5432      
export DB_USER=postgres 
export DB_PASSWORD=123
export DB_NAME=catalogo

export PGPASSWORD=$DB_PASSWORD

echo "Variáveis de ambiente configuradas."


DB_EXISTS=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';")

if [ "$DB_EXISTS" = "1" ]; then
    echo "Banco $DB_NAME já existe."
else
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;"
    echo "Banco $DB_NAME criado com sucesso!"
fi

echo "Banco pronto! Agora você pode aplicar schema e seed manualmente ou conectar seu backend."



