#!/bin/bash

# Script para resetar o Oracle (limpar dados e recriar)
# Execute com: sudo ./reset-oracle.sh

echo "Parando container..."
docker compose down

echo "Limpando dados antigos..."
sudo rm -rf data/oradata/* data/diag/*

echo "Ajustando permissões..."
sudo chown -R 54321:54321 data/
sudo chmod -R 755 data/

echo "Iniciando Oracle novamente..."
docker compose up -d

echo "Aguardando inicialização..."
sleep 5

echo "Monitorando logs (Ctrl+C para sair)..."
docker compose logs -f oracle19c

