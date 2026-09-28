#!/bin/bash
# ============================================
# SILLALIBRE - Inicialización de Bases de Datos
# ============================================
# Crea bases de datos lógicas por microservicio
# en la instancia PostgreSQL compartida (Docker Compose)
# ============================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Servicios que necesitan base de datos propia
SERVICES=("identidad" "establecimiento" "personal" "reserva" "notificacion" "fidelizacion" "resena" "descubrimiento")

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Inicializando bases de datos por servicio${NC}"
echo -e "${YELLOW}========================================${NC}"

# Verificar que Docker Compose está corriendo
if ! docker compose ps postgres | grep -q "running"; then
    echo -e "${RED}Error: PostgreSQL no está corriendo. Ejecuta 'docker compose up -d' primero.${NC}"
    exit 1
fi

# Crear bases de datos para cada servicio
for svc in "${SERVICES[@]}"; do
    db_name="${svc}_db"
    echo -e "${YELLOW}Creando base de datos: ${db_name}${NC}"
    
    docker compose exec -T postgres psql -U sillalibre -d postgres -c \
        "CREATE DATABASE ${db_name};" 2>/dev/null || true
    
    echo -e "${GREEN}✓ ${db_name} creada (o ya existía)${NC}"
done

echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}Inicialización completada${NC}"
echo -e "${YELLOW}========================================${NC}"

# Listar bases de datos creadas
echo -e "${YELLOW}Bases de datos disponibles:${NC}"
docker compose exec -T postgres psql -U sillalibre -d postgres -c "\l" | grep sillalibre
