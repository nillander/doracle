#!/bin/bash

# Script para resetar o Oracle (limpar dados e recriar)
# Execute com: sudo ./reset-oracle.sh

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "Reset do Oracle 19c - Docker"
echo "==========================================${NC}"
echo ""

echo "Parando container..."
docker compose down

echo "Limpando dados antigos..."
sudo rm -rf data/oradata/* data/diag/*

echo "Ajustando permissões..."
sudo chown -R 54321:54321 data/
sudo chmod -R 755 data/

echo "Iniciando Oracle novamente..."
docker compose up -d

echo ""
echo -e "${YELLOW}Aguardando Oracle inicializar (isso pode levar 5-15 minutos)...${NC}"
echo ""

# Aguardar o healthcheck passar
CONTAINER_ID=$(docker compose ps -q oracle19c)
MAX_WAIT=900  # 15 minutos
ELAPSED=0
INTERVAL=10

while [ $ELAPSED -lt $MAX_WAIT ]; do
    HEALTH=$(docker inspect "$CONTAINER_ID" --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")

    if [ "$HEALTH" = "healthy" ]; then
        echo -e "${GREEN}✓ Oracle está pronto!${NC}"
        break
    elif [ "$HEALTH" = "starting" ]; then
        echo -e "${YELLOW}⏳ Aguardando... (${ELAPSED}s/${MAX_WAIT}s) - Status: $HEALTH${NC}"
    else
        echo -e "${YELLOW}⏳ Aguardando... (${ELAPSED}s/${MAX_WAIT}s) - Status: $HEALTH${NC}"
    fi

    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ "$HEALTH" != "healthy" ]; then
    echo -e "${RED}✗ Timeout aguardando Oracle ficar pronto${NC}"
    echo "Verifique os logs com: docker compose logs -f oracle19c"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================="
echo "✓ Reset concluído com sucesso!"
echo "==========================================${NC}"
echo ""
echo "📝 Para criar o usuário laraveldb para Laravel:"
echo "   ./create-laravel-user.sh"
echo ""
echo "📝 Para ver os logs:"
echo "   docker compose logs -f oracle19c"
echo ""

