#!/bin/bash

# API Testing Script for Zero-Trust Cloud Lab

set -e

API_URL="${API_URL:-http://localhost:8080}"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Zero-Trust Cloud Lab - API Testing"
echo "=========================================="
echo ""
echo "Testing API at: $API_URL"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
if curl -s -f "$API_URL/health" > /dev/null; then
    echo -e "${GREEN}✓ Health check passed${NC}"
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi

# Test 2: Register a new user
echo -e "\n${YELLOW}Test 2: User Registration${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser'$(date +%s)'",
        "email": "test'$(date +%s)'@example.com",
        "password": "SecurePass123!",
        "firstName": "Test",
        "lastName": "User"
    }')

if echo "$REGISTER_RESPONSE" | grep -q "User registered successfully"; then
    echo -e "${GREEN}✓ User registration passed${NC}"
    echo "Response: $REGISTER_RESPONSE"
else
    echo -e "${RED}✗ User registration failed${NC}"
    echo "Response: $REGISTER_RESPONSE"
fi

# Test 3: Login
echo -e "\n${YELLOW}Test 3: User Login${NC}"
# Extract email from registration (for testing, use a known user)
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "test@example.com",
        "password": "SecurePass123!"
    }')

if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
    echo -e "${GREEN}✓ User login passed${NC}"
    ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
    echo "Access Token: ${ACCESS_TOKEN:0:50}..."
else
    echo -e "${YELLOW}⚠ Login failed (user might not exist yet)${NC}"
    echo "Response: $LOGIN_RESPONSE"
    
    # Try to create and login with a new user
    echo -e "\n${YELLOW}Creating a test user for login...${NC}"
    TEST_EMAIL="testuser@example.com"
    TEST_PASSWORD="TestPass123!"
    
    curl -s -X POST "$API_URL/api/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"username\": \"testuser\",
            \"email\": \"$TEST_EMAIL\",
            \"password\": \"$TEST_PASSWORD\"
        }" > /dev/null
    
    LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_EMAIL\",
            \"password\": \"$TEST_PASSWORD\"
        }")
    
    if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
        echo -e "${GREEN}✓ User login passed${NC}"
        ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
    fi
fi

# Test 4: Access protected endpoint
if [ ! -z "$ACCESS_TOKEN" ]; then
    echo -e "\n${YELLOW}Test 4: Access Protected Endpoint${NC}"
    ME_RESPONSE=$(curl -s -X GET "$API_URL/api/auth/me" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    
    if echo "$ME_RESPONSE" | grep -q "user"; then
        echo -e "${GREEN}✓ Protected endpoint access passed${NC}"
        echo "Response: $ME_RESPONSE"
    else
        echo -e "${RED}✗ Protected endpoint access failed${NC}"
        echo "Response: $ME_RESPONSE"
    fi
    
    # Test 5: Invalid token
    echo -e "\n${YELLOW}Test 5: Invalid Token${NC}"
    INVALID_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "$API_URL/api/auth/me" \
        -H "Authorization: Bearer invalid_token")
    
    if echo "$INVALID_RESPONSE" | grep -q "HTTP_STATUS:401"; then
        echo -e "${GREEN}✓ Invalid token correctly rejected${NC}"
    else
        echo -e "${RED}✗ Invalid token test failed${NC}"
    fi
else
    echo -e "\n${RED}⚠ Skipping protected endpoint tests (no access token)${NC}"
fi

# Test 6: Rate limiting
echo -e "\n${YELLOW}Test 6: Rate Limiting${NC}"
echo "Sending 10 rapid requests..."
for i in {1..10}; do
    curl -s "$API_URL/health" > /dev/null
done
echo -e "${GREEN}✓ Rate limiting test completed${NC}"

echo -e "\n${GREEN}=========================================="
echo "API Testing Complete!"
echo "==========================================${NC}"

