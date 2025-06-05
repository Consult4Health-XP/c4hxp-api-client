# C4HXP API Client SDK

Official client libraries and integration tools for the C4HXP Laboratory Management API.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python SDK](https://img.shields.io/pypi/v/c4hxp-client)](https://pypi.org/project/c4hxp-client/)
[![JavaScript SDK](https://img.shields.io/npm/v/@c4hxp/api-client)](https://www.npmjs.com/package/@c4hxp/api-client)

## 🚀 Quick Start

### 1. Get Your API Key
Contact your C4HXP representative to obtain your API key, or request one through the C4HXP dashboard.

### 2. Install the SDK

**Python**
```bash
pip install c4hxp-client
```

**JavaScript/Node.js**
```bash
npm install @c4hxp/api-client
```

**PHP**
```bash
composer require c4hxp/api-client
```

### 3. Start Integrating

**Python Example**
```python
from c4hxp_client import C4HXPClient

# Initialize client
client = C4HXPClient(
    api_key="c4hxp_live_your_key_id",
    api_secret="your_secret_key"
)

# Create an order
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

print(f"Order created: {order.id}")
```

**JavaScript Example**
```javascript
import { C4HXPClient } from '@c4hxp/api-client';

// Initialize client
const client = new C4HXPClient({
    apiKey: 'c4hxp_live_your_key_id',
    apiSecret: 'your_secret_key'
});

// Create an order
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

console.log(`Order created: ${order.id}`);
```

## 📚 Available SDKs

| Language | Package | Documentation |
|----------|---------|---------------|
| Python | [`c4hxp-client`](sdks/python/) | [Python Docs](sdks/python/README.md) |
| JavaScript | [`@c4hxp/api-client`](sdks/javascript/) | [JS Docs](sdks/javascript/README.md) |
| PHP | [`c4hxp/api-client`](sdks/php/) | [PHP Docs](sdks/php/README.md) |

## 🔗 API Endpoints

### Orders
- **Create Order**: Create a new lab test order
- **Get Order**: Retrieve order details and status
- **List Orders**: Get orders for your account
- **Track Order**: Get shipping and processing updates

### Kits
- **Register Kit**: Link a kit to a patient
- **Get Kit Status**: Check kit processing status
- **Kit Tracking**: View kit lifecycle events

### Results
- **Get Results**: Retrieve test results
- **Download PDF**: Get formatted result reports
- **Result Notifications**: Webhook support for result availability

### Catalog
- **List Kit Types**: Browse available test panels
- **Get Kit Details**: View test specifications

## 📖 Documentation

- **[Getting Started Guide](docs/getting-started.md)** - Complete setup walkthrough
- **[Authentication](docs/authentication.md)** - API key usage and security
- **[API Reference](docs/api-reference.md)** - Complete endpoint documentation
- **[Rate Limits](docs/rate-limits.md)** - Usage limits and best practices
- **[Error Handling](docs/error-handling.md)** - Common errors and solutions
- **[Webhooks](docs/webhooks.md)** - Event notifications setup
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and fixes

## 🛠️ Examples

- **[Python Examples](examples/python/)** - Complete Python integration examples
- **[JavaScript Examples](examples/javascript/)** - Node.js and browser examples
- **[cURL Examples](examples/curl/)** - Raw HTTP API examples
- **[Postman Collection](examples/postman/)** - Ready-to-use Postman workspace

## 🔐 Authentication

All API requests require authentication using your API key:

```http
Authorization: Api-Key your_key_id:your_secret
```

### Security Best Practices
- Store API keys securely (environment variables, secrets management)
- Use different keys for development and production
- Monitor API key usage through the dashboard
- Rotate keys regularly

## 📊 Rate Limits

API usage is subject to rate limits based on your plan:

| Plan Type | Requests/Hour | Requests/Day |
|-----------|---------------|--------------|
| Partner | 1,000 | 10,000 |
| Enterprise | 5,000 | 50,000 |
| Custom | Negotiated | Negotiated |

Rate limit headers are included in all responses:
- `X-RateLimit-Limit`: Total requests allowed
- `X-RateLimit-Remaining`: Requests remaining
- `X-RateLimit-Reset`: Time when limits reset

## 🐛 Error Handling

The API uses standard HTTP status codes and returns detailed error information:

```json
{
  "error": {
    "code": "invalid_request",
    "message": "The request is missing required parameters",
    "details": {
      "missing_fields": ["recipient.email"]
    }
  }
}
```

Common error codes:
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid API key)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (resource doesn't exist)
- `429` - Too Many Requests (rate limit exceeded)
- `500` - Internal Server Error (contact support)

## 🔔 Webhooks

Subscribe to real-time events for order and result updates:

```python
# Configure webhook endpoint
client.webhooks.create({
    "url": "https://your-app.com/webhooks/c4hxp",
    "events": ["order.shipped", "result.available"],
    "secret": "your_webhook_secret"
})
```

Supported events:
- `order.created` - New order placed
- `order.shipped` - Kit shipped to patient
- `kit.registered` - Patient registered kit
- `sample.received` - Lab received sample
- `result.available` - Test results ready

## 🧪 Testing

### Sandbox Environment
Use the sandbox environment for testing:

```python
client = C4HXPClient(
    api_key="c4hxp_test_your_key_id",
    api_secret="your_test_secret",
    base_url="https://sandbox-api.c4hxp.com"
)
```

### Test Data
The `sample-data/` directory contains example requests and responses for testing your integration.

## 🆘 Support

- **Documentation**: Full API documentation at [docs.c4hxp.com](https://docs.c4hxp.com)
- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/c4hxp/api-client/issues)
- **Email**: Technical support at api-support@c4hxp.com
- **Community**: Join our [Discord server](https://discord.gg/c4hxp) for community support

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

---

**Need help getting started?** Check out our [Getting Started Guide](docs/getting-started.md) or contact our support team. 