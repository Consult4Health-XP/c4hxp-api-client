# Getting Started with C4HXP API

This guide will walk you through integrating with the C4HXP Laboratory Management API, from obtaining your API key to placing your first order.

## Prerequisites

- A C4HXP partner account
- Basic knowledge of REST APIs
- Your preferred programming language (Python, JavaScript, or PHP recommended)

## Step 1: Obtain Your API Key

### Partner Dashboard
1. Log into your C4HXP partner dashboard
2. Navigate to **Settings** → **API Keys**
3. Click **Create New API Key**
4. Select appropriate scopes for your integration
5. Save your key ID and secret securely

### Contact Support
If you don't have dashboard access, contact your C4HXP representative:
- Email: partners@c4hxp.com
- Phone: +1 (555) 123-4567

## Step 2: Test Your API Key

Before building your integration, verify your API key works:

```bash
curl -X GET "https://api.c4hxp.com/v2/public/catalog/kit-types" \
  -H "Authorization: Api-Key your_key_id:your_secret"
```

Expected response:
```json
{
  "kit_types": [
    {
      "id": "hormone_panel",
      "name": "Hormone Panel",
      "description": "Comprehensive hormone testing",
      "price": 149.99
    }
  ]
}
```

## Step 3: Install the SDK

Choose your preferred language:

### Python
```bash
pip install c4hxp-client
```

### JavaScript/Node.js
```bash
npm install @c4hxp/api-client
```

### PHP
```bash
composer require c4hxp/api-client
```

## Step 4: Initialize Your Client

### Python
```python
from c4hxp_client import C4HXPClient

client = C4HXPClient(
    api_key="your_key_id",
    api_secret="your_secret",
    # Use sandbox for testing
    base_url="https://sandbox-api.c4hxp.com"  # Optional
)
```

### JavaScript
```javascript
import { C4HXPClient } from '@c4hxp/api-client';

const client = new C4HXPClient({
    apiKey: 'your_key_id',
    apiSecret: 'your_secret',
    // Use sandbox for testing
    baseUrl: 'https://sandbox-api.c4hxp.com'  // Optional
});
```

### PHP
```php
<?php
require_once 'vendor/autoload.php';

use C4HXP\Client\C4HXPClient;

$client = new C4HXPClient([
    'api_key' => 'your_key_id',
    'api_secret' => 'your_secret',
    // Use sandbox for testing
    'base_url' => 'https://sandbox-api.c4hxp.com'  // Optional
]);
```

## Step 5: Create Your First Order

### Python Example
```python
try:
    # Create order
    order = client.orders.create({
        "recipient": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john@example.com",
            "phone": "+1234567890",
            "address": {
                "street1": "123 Main St",
                "city": "Anytown",
                "state": "CA",
                "zip": "12345",
                "country": "US"
            }
        },
        "kit_types": ["hormone_panel"]
    })
    
    print(f"Order created successfully!")
    print(f"Order ID: {order['id']}")
    print(f"Order Number: {order['order_number']}")
    print(f"Status: {order['status']}")
    
except Exception as e:
    print(f"Error creating order: {e}")
```

### JavaScript Example
```javascript
try {
    // Create order
    const order = await client.orders.create({
        recipient: {
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            phone: '+1234567890',
            address: {
                street1: '123 Main St',
                city: 'Anytown',
                state: 'CA',
                zip: '12345',
                country: 'US'
            }
        },
        kitTypes: ['hormone_panel']
    });
    
    console.log('Order created successfully!');
    console.log(`Order ID: ${order.id}`);
    console.log(`Order Number: ${order.orderNumber}`);
    console.log(`Status: ${order.status}`);
    
} catch (error) {
    console.error('Error creating order:', error);
}
```

## Step 6: Track Your Order

```python
# Get order status
order_status = client.orders.get(order['id'])
print(f"Current status: {order_status['status']}")

# Get detailed tracking
tracking = client.orders.tracking(order['id'])
for event in tracking['events']:
    print(f"{event['timestamp']}: {event['description']}")
```

## Step 7: Handle Kit Registration

When the patient receives their kit, they'll register it:

```python
# Register kit to patient
registration = client.kits.register({
    "barcode": "XP00012345",
    "patient": {
        "first_name": "John",
        "last_name": "Doe",
        "date_of_birth": "1985-03-15"
    },
    "collection_date": "2024-01-15T09:30:00Z"
})

print(f"Kit registered: {registration['status']}")
```

## Step 8: Retrieve Results

When results are available, retrieve them:

```python
# Get results by kit barcode
results = client.results.get_by_kit("XP00012345")

print(f"Test Status: {results['status']}")
for test in results['results']:
    print(f"{test['test_name']}: {test['value']} {test['unit']}")

# Download PDF report
pdf_url = client.results.get_pdf_url(results['id'])
print(f"PDF Report: {pdf_url}")
```

## Step 9: Set Up Webhooks (Optional)

Stay informed about order and result updates:

```python
# Configure webhook
webhook = client.webhooks.create({
    "url": "https://your-app.com/webhooks/c4hxp",
    "events": [
        "order.created",
        "order.shipped", 
        "kit.registered",
        "result.available"
    ],
    "secret": "your_webhook_secret"
})

print(f"Webhook configured: {webhook['id']}")
```

## Error Handling

Always implement proper error handling:

```python
from c4hxp_client.exceptions import (
    C4HXPAuthenticationError,
    C4HXPValidationError,
    C4HXPRateLimitError,
    C4HXPAPIError
)

try:
    order = client.orders.create(order_data)
except C4HXPAuthenticationError:
    print("Invalid API key or secret")
except C4HXPValidationError as e:
    print(f"Validation error: {e.details}")
except C4HXPRateLimitError:
    print("Rate limit exceeded, please slow down")
except C4HXPAPIError as e:
    print(f"API error: {e.message}")
```

## Rate Limits

Be mindful of rate limits:

- **Partner Plan**: 1,000 requests/hour
- **Enterprise Plan**: 5,000 requests/hour

Check rate limit status:
```python
# Check remaining requests
rate_limit = client.get_rate_limit_status()
print(f"Remaining requests: {rate_limit['remaining']}")
print(f"Reset time: {rate_limit['reset_time']}")
```

## Environment Best Practices

### Use Environment Variables
```bash
# .env file
C4HXP_API_KEY=your_key_id
C4HXP_API_SECRET=your_secret
C4HXP_BASE_URL=https://sandbox-api.c4hxp.com
```

```python
import os
from c4hxp_client import C4HXPClient

client = C4HXPClient(
    api_key=os.getenv('C4HXP_API_KEY'),
    api_secret=os.getenv('C4HXP_API_SECRET'),
    base_url=os.getenv('C4HXP_BASE_URL')
)
```

### Development vs Production
- **Sandbox**: `https://sandbox-api.c4hxp.com`
- **Production**: `https://api.c4hxp.com`

Use sandbox for all development and testing!

## Next Steps

1. **Explore Examples**: Check out language-specific examples in `/examples/`
2. **Read API Reference**: Complete endpoint documentation in `/docs/api-reference.md`
3. **Set Up Webhooks**: Real-time notifications in `/docs/webhooks.md`
4. **Error Handling**: Comprehensive guide in `/docs/error-handling.md`
5. **Rate Limits**: Best practices in `/docs/rate-limits.md`

## Support

Need help? We're here to assist:

- **Documentation**: [docs.c4hxp.com](https://docs.c4hxp.com)
- **GitHub Issues**: [Report bugs or request features](https://github.com/c4hxp/api-client/issues)
- **Email Support**: api-support@c4hxp.com
- **Community**: [Join our Discord](https://discord.gg/c4hxp)

---

**Ready to integrate?** Start with our [Python examples](../examples/python/) or [JavaScript examples](../examples/javascript/)! 