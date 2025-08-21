#!/bin/bash

export DB_HOST=nebuladb.cpie8isakvgh.us-east-2.rds.amazonaws.com
export DB_PORT=5432            
export DB_USER=Dev1            
export DB_PASSWORD='D@ni55cssmile22'
export DB_NAME=catalogo

export PGPASSWORD=$DB_PASSWORD

echo "Variáveis de ambiente configuradas."

# Verifica se o banco existe
DB_EXISTS=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';")

if [ "$DB_EXISTS" = "1" ]; then
    echo "Banco $DB_NAME já existe no RDS."
else
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;"
    echo "Banco $DB_NAME criado com sucesso no RDS!"
fi

echo "Banco pronto! Aplicando schema e seed..."

# Aplica schema e seed diretamente no banco criado
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME <<EOF
-- Schema
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    valor DECIMAL(10,2) NOT NULL,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed
INSERT INTO clientes (nome, email) VALUES
('Rainha', 'rainha@exemplo.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO pedidos (cliente_id, valor) VALUES
(1, 150.50),
(2, 200.00);
EOF

echo "Schema e seed aplicados com sucesso!"
