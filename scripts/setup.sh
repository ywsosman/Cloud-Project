#!/bin/bash

# Zero-Trust Cloud Lab Setup Script
# This script helps set up the local development environment

set -e

echo "=========================================="
echo "Zero-Trust Cloud Lab - Setup Script"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Docker
echo -e "${YELLOW}Checking Docker...${NC}"
if command_exists docker; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓ Docker installed: $DOCKER_VERSION${NC}"
    
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker is running${NC}"
    else
        echo -e "${RED}✗ Docker is not running. Please start Docker.${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Docker not found. Please install Docker.${NC}"
    exit 1
fi

# Check Docker Compose
echo -e "\n${YELLOW}Checking Docker Compose...${NC}"
if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${RED}✗ Docker Compose not found. Please install Docker Compose.${NC}"
    exit 1
fi

# Check Node.js
echo -e "\n${YELLOW}Checking Node.js...${NC}"
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js installed: $NODE_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Node.js not found. Recommended for local development.${NC}"
fi

# Create .env file if it doesn't exist
echo -e "\n${YELLOW}Setting up environment variables...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.template .env
    echo -e "${GREEN}✓ .env file created${NC}"
    echo -e "${YELLOW}⚠ Please edit .env file with your actual credentials${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Create necessary directories
echo -e "\n${YELLOW}Creating directories...${NC}"
mkdir -p logs
mkdir -p data/postgres
mkdir -p data/redis
echo -e "${GREEN}✓ Directories created${NC}"

# Install dependencies for auth-service
echo -e "\n${YELLOW}Installing dependencies for auth-service...${NC}"
if [ -f src/auth-service/package.json ]; then
    cd src/auth-service
    if command_exists npm; then
        npm install
        echo -e "${GREEN}✓ Auth service dependencies installed${NC}"
    else
        echo -e "${YELLOW}⚠ npm not found. Skipping dependency installation.${NC}"
    fi
    cd ../..
fi

# Build Docker images
echo -e "\n${YELLOW}Would you like to build Docker images now? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Building Docker images...${NC}"
    docker-compose build
    echo -e "${GREEN}✓ Docker images built${NC}"
fi

# Start services
echo -e "\n${YELLOW}Would you like to start the services now? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Starting services...${NC}"
    docker-compose up -d
    
    echo -e "\n${YELLOW}Waiting for services to be ready...${NC}"
    sleep 10
    
    # Check service health
    if curl -s http://localhost:8080/health > /dev/null; then
        echo -e "${GREEN}✓ API Gateway is healthy${NC}"
    else
        echo -e "${RED}✗ API Gateway is not responding${NC}"
    fi
    
    if curl -s http://localhost:8081/health > /dev/null; then
        echo -e "${GREEN}✓ Auth Service is healthy${NC}"
    else
        echo -e "${RED}✗ Auth Service is not responding${NC}"
    fi
fi

echo -e "\n${GREEN}=========================================="
echo "Setup Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your credentials"
echo "2. Start services: docker-compose up -d"
echo "3. Check logs: docker-compose logs -f"
echo "4. Test API: curl http://localhost:8080/health"
echo ""
echo "API Endpoints:"
echo "  - API Gateway: http://localhost:8080"
echo "  - Auth Service: http://localhost:8081"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis: localhost:6379"
echo ""
echo "Documentation:"
echo "  - Week 4: week4-setup/README.md"
echo "  - Week 7: week7-prototype1/README.md"
echo ""

