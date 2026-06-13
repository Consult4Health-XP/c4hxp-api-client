#!/bin/bash
# C4HXP API Authentication Examples using cURL
#
# Prerequisites:
# - Set environment variables: C4HXP_API_KEY, C4HXP_API_SECRET
# - Optional: set C4HXP_BASE_URL for staging, for example https://api.staging.consult4healthxp.com
# - Or replace the variables below with your actual credentials

# Configuration
API_KEY="${C4HXP_API_KEY:-your_key_id}"
API_SECRET="${C4HXP_API_SECRET:-your_secret}"
BASE_URL="${C4HXP_BASE_URL:-https://api.staging.consult4healthxp.com}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 C4HXP API Authentication Examples${NC}"
echo "========================================"

# Check if credentials are set
if [ "$API_KEY" = "your_key_id" ] || [ "$API_SECRET" = "your_secret" ]; then
    echo -e "${RED}❌ Please set your API credentials:${NC}"
    echo "export C4HXP_API_KEY=your_actual_key_id"
    echo "export C4HXP_API_SECRET=your_actual_secret"
    echo "export C4HXP_BASE_URL=https://api.staging.consult4healthxp.com"
    exit 1
fi

echo -e "${YELLOW}Using API Key: ${API_KEY}${NC}"
echo -e "${YELLOW}Base URL: ${BASE_URL}${NC}"
echo ""

# Test 1: Get available kit types (requires authentication)
echo -e "${BLUE}📋 Test 1: Get Available Kit Types${NC}"
echo "GET ${BASE_URL}/v2/public/catalog/kit-types"
echo ""

response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -H "Authorization: Api-Key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json" \
  "${BASE_URL}/v2/public/catalog/kit-types")

http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_STATUS/d')

if [ "$http_status" = "200" ]; then
    echo -e "${GREEN}✅ Success! Available kit types:${NC}"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
else
    echo -e "${RED}❌ Failed with status: $http_status${NC}"
    echo "$body"
fi

echo ""
echo "----------------------------------------"
echo ""

# Test 2: Test authentication error (invalid key)
echo -e "${BLUE}🚫 Test 2: Test Invalid Authentication${NC}"
echo "GET ${BASE_URL}/v2/public/catalog/kit-types (with invalid key)"
echo ""

response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -H "Authorization: Api-Key invalid_key:invalid_secret" \
  -H "Content-Type: application/json" \
  "${BASE_URL}/v2/public/catalog/kit-types")

http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_STATUS/d')

if [ "$http_status" = "401" ]; then
    echo -e "${GREEN}✅ Expected 401 Unauthorized:${NC}"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
else
    echo -e "${RED}❌ Unexpected status: $http_status${NC}"
    echo "$body"
fi

echo ""
echo "----------------------------------------"
echo ""

# Test 3: Create an order (POST request)
echo -e "${BLUE}🛍️ Test 3: Create Order${NC}"
echo "POST ${BASE_URL}/v2/public/orders/"
echo ""

order_payload='{
  "recipient": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "address": {
      "street1": "123 Main Street",
      "city": "Anytown",
      "state": "CA",
      "zip": "12345",
      "country": "US"
    }
  },
  "kit_types": ["hormone_panel"],
  "shipping_method": "standard"
}'

echo "Payload:"
echo "$order_payload" | jq '.' 2>/dev/null || echo "$order_payload"
echo ""

response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST \
  -H "Authorization: Api-Key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json" \
  -d "$order_payload" \
  "${BASE_URL}/v2/public/orders/")

http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_STATUS/d')

if [ "$http_status" = "201" ]; then
    echo -e "${GREEN}✅ Order created successfully!${NC}"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"

    # Extract order ID for next test
    ORDER_ID=$(echo "$body" | jq -r '.id' 2>/dev/null)
    if [ "$ORDER_ID" != "null" ] && [ "$ORDER_ID" != "" ]; then
        echo -e "${YELLOW}📝 Order ID: $ORDER_ID${NC}"
    fi
else
    echo -e "${RED}❌ Failed to create order. Status: $http_status${NC}"
    echo "$body"
fi

echo ""
echo "----------------------------------------"
echo ""

# Test 4: Get order details (if order was created)
if [ ! -z "$ORDER_ID" ] && [ "$ORDER_ID" != "null" ]; then
    echo -e "${BLUE}📦 Test 4: Get Order Details${NC}"
    echo "GET ${BASE_URL}/v2/public/orders/${ORDER_ID}"
    echo ""

    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
      -H "Authorization: Api-Key ${API_KEY}:${API_SECRET}" \
      -H "Content-Type: application/json" \
      "${BASE_URL}/v2/public/orders/${ORDER_ID}")

    http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_STATUS/d')

    if [ "$http_status" = "200" ]; then
        echo -e "${GREEN}✅ Order details retrieved:${NC}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo -e "${RED}❌ Failed to get order. Status: $http_status${NC}"
        echo "$body"
    fi

    echo ""
    echo "----------------------------------------"
    echo ""
fi

# Test 5: Rate limit headers
echo -e "${BLUE}📊 Test 5: Check Rate Limit Headers${NC}"
echo "Making request to check rate limit headers..."
echo ""

response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nRATE_LIMIT:%{header_x_ratelimit_limit}\nRATE_REMAINING:%{header_x_ratelimit_remaining}\nRATE_RESET:%{header_x_ratelimit_reset}" \
  -H "Authorization: Api-Key ${API_KEY}:${API_SECRET}" \
  -H "Content-Type: application/json" \
  "${BASE_URL}/v2/public/catalog/kit-types")

http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
rate_limit=$(echo "$response" | grep "RATE_LIMIT" | cut -d: -f2)
rate_remaining=$(echo "$response" | grep "RATE_REMAINING" | cut -d: -f2)
rate_reset=$(echo "$response" | grep "RATE_RESET" | cut -d: -f2)

echo -e "${GREEN}Rate Limit Information:${NC}"
echo "  Limit: $rate_limit requests"
echo "  Remaining: $rate_remaining requests"
echo "  Reset: $rate_reset"

echo ""
echo "========================================"
echo -e "${GREEN}🎉 Authentication tests completed!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Try the other example scripts:"
echo "   - ./create_order.sh"
echo "   - ./get_results.sh"
echo "2. Explore the Python examples in ../python/"
echo "3. Set up webhooks for real-time notifications"
