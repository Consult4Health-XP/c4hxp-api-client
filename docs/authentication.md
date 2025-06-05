# Authentication

Complete guide to authenticating with the C4HXP API using API keys.

## Overview

The C4HXP API uses **API Key authentication** for all requests. Every API key consists of two parts:
- **Key ID**: A public identifier (e.g., `c4hxp_live_abc123`)
- **Secret**: A private secret key (e.g., `sk_live_xyz789`)

## API Key Format

API keys are provided in the following format:

```
Key ID: c4hxp_{environment}_{key_id}
Secret: sk_{environment}_{secret}
```

**Examples:**
- Production: `c4hxp_live_abc123` + `sk_live_xyz789`
- Staging: `c4hxp_test_def456` + `sk_test_uvw123`

## Authentication Header

Include your API key in the `Authorization` header of every request:

```http
Authorization: Api-Key {key_id}:{secret}
```

**Example:**
```bash
curl -H "Authorization: Api-Key c4hxp_live_abc123:sk_live_xyz789" \
     https://api.c4hxp.com/v2/public/catalog/kit-types
```

## API Key Types

Different API key types have different permissions and rate limits:

### Partner Keys
- **Purpose**: Healthcare partners and integration partners
- **Rate Limit**: 1,000 requests/hour
- **Scopes**: Order management, kit tracking, result access
- **Use Case**: EHR integrations, partner portals

### E-commerce Keys  
- **Purpose**: Online marketplaces and e-commerce platforms
- **Rate Limit**: 500 requests/hour
- **Scopes**: Order creation, basic tracking
- **Use Case**: Online storefronts, marketplace integrations

### Development Keys
- **Purpose**: Testing and development environments
- **Rate Limit**: 100 requests/hour
- **Scopes**: Limited to test data
- **Use Case**: Integration development, testing

## Scopes and Permissions

API keys are assigned specific scopes that control access to different endpoints:

| Scope | Description | Endpoints |
|-------|-------------|-----------|
| `orders:read` | Read order information | `GET /orders/*` |
| `orders:write` | Create and modify orders | `POST /orders/*` |
| `kits:read` | Read kit status and information | `GET /kits/*` |
| `kits:write` | Register and update kits | `POST /kits/*` |
| `results:read` | Access test results | `GET /results/*` |
| `catalog:read` | Access kit catalog | `GET /catalog/*` |

## Environments

### Production Environment
- **Base URL**: `https://api.c4hxp.com/v2/public/`
- **Key Prefix**: `c4hxp_live_*`
- **Use**: Live customer data and transactions

### Staging Environment  
- **Base URL**: `https://staging.api.c4hxp.com/v2/public/`
- **Key Prefix**: `c4hxp_test_*`
- **Use**: Integration testing with test data

### Development Environment
- **Base URL**: Provided by C4HXP team
- **Key Prefix**: `c4hxp_dev_*`
- **Use**: Local development and testing

## Implementation Examples

### Python
```python
import requests

class C4HXPClient:
    def __init__(self, key_id, secret, base_url=None):
        self.key_id = key_id
        self.secret = secret
        self.base_url = base_url or "https://api.c4hxp.com/v2/public/"
        
    def _headers(self):
        return {
            "Authorization": f"Api-Key {self.key_id}:{self.secret}",
            "Content-Type": "application/json"
        }
    
    def get_kit_types(self):
        response = requests.get(
            f"{self.base_url}catalog/kit-types",
            headers=self._headers()
        )
        return response.json()

# Usage
client = C4HXPClient(
    key_id="c4hxp_live_abc123",
    secret="sk_live_xyz789"
)
kit_types = client.get_kit_types()
```

### JavaScript/Node.js
```javascript
const axios = require('axios');

class C4HXPClient {
    constructor(keyId, secret, baseUrl = null) {
        this.keyId = keyId;
        this.secret = secret;
        this.baseUrl = baseUrl || 'https://api.c4hxp.com/v2/public/';
    }
    
    _headers() {
        return {
            'Authorization': `Api-Key ${this.keyId}:${this.secret}`,
            'Content-Type': 'application/json'
        };
    }
    
    async getKitTypes() {
        const response = await axios.get(`${this.baseUrl}catalog/kit-types`, {
            headers: this._headers()
        });
        return response.data;
    }
}

// Usage
const client = new C4HXPClient(
    'c4hxp_live_abc123',
    'sk_live_xyz789'
);
const kitTypes = await client.getKitTypes();
```

### PHP
```php
<?php

class C4HXPClient {
    private $keyId;
    private $secret;
    private $baseUrl;
    
    public function __construct($keyId, $secret, $baseUrl = null) {
        $this->keyId = $keyId;
        $this->secret = $secret;
        $this->baseUrl = $baseUrl ?: 'https://api.c4hxp.com/v2/public/';
    }
    
    private function headers() {
        return [
            'Authorization: Api-Key ' . $this->keyId . ':' . $this->secret,
            'Content-Type: application/json'
        ];
    }
    
    public function getKitTypes() {
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => $this->baseUrl . 'catalog/kit-types',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $this->headers()
        ]);
        
        $response = curl_exec($curl);
        curl_close($curl);
        
        return json_decode($response, true);
    }
}

// Usage
$client = new C4HXPClient(
    'c4hxp_live_abc123',
    'sk_live_xyz789'
);
$kitTypes = $client->getKitTypes();
?>
```

### cURL
```bash
# Set environment variables
export C4HXP_KEY_ID="c4hxp_live_abc123"
export C4HXP_SECRET="sk_live_xyz789"

# Make API call
curl -H "Authorization: Api-Key $C4HXP_KEY_ID:$C4HXP_SECRET" \
     -H "Content-Type: application/json" \
     https://api.c4hxp.com/v2/public/catalog/kit-types
```

## Security Best Practices

### Key Storage
- **Environment Variables**: Store keys in environment variables, not code
- **Secrets Management**: Use services like AWS Secrets Manager, HashiCorp Vault
- **Never Commit**: Never commit API keys to version control

```python
import os

# ✅ Good - Use environment variables
key_id = os.getenv('C4HXP_KEY_ID')
secret = os.getenv('C4HXP_SECRET')

# ❌ Bad - Hardcoded in code
key_id = "c4hxp_live_abc123"  # Don't do this!
```

### Key Rotation
- Rotate API keys regularly (every 90 days recommended)
- Use separate keys for different environments
- Monitor key usage through the C4HXP dashboard

### Network Security
- Always use HTTPS (never HTTP)
- Implement proper TLS certificate validation
- Consider IP whitelisting for production environments

### Error Handling
- Don't log API keys in error messages
- Handle authentication errors gracefully
- Implement retry logic for temporary failures

```python
def make_request(client, url):
    try:
        response = client.get(url)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 401:
            # Handle authentication error
            raise Exception("Invalid API credentials")
        elif e.response.status_code == 429:
            # Handle rate limiting
            raise Exception("Rate limit exceeded")
        else:
            raise
```

## Authentication Errors

### 401 Unauthorized
**Cause**: Invalid or missing API key

**Response:**
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid API key or secret"
  }
}
```

**Solutions:**
- Verify your API key and secret are correct
- Check that the key is active and not expired
- Ensure proper formatting of Authorization header

### 403 Forbidden
**Cause**: Valid API key but insufficient permissions

**Response:**
```json
{
  "error": {
    "code": "FORBIDDEN", 
    "message": "Insufficient permissions for this resource",
    "details": {
      "required_scope": "orders:write",
      "available_scopes": ["orders:read", "kits:read"]
    }
  }
}
```

**Solutions:**
- Check that your API key has the required scopes
- Contact C4HXP support to upgrade your key permissions

### 429 Too Many Requests
**Cause**: Rate limit exceeded

**Response:**
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "details": {
      "limit": 1000,
      "window": "1 hour", 
      "reset_at": "2024-01-15T11:00:00Z"
    }
  }
}
```

**Solutions:**
- Implement exponential backoff
- Monitor rate limit headers
- Consider upgrading your API key plan

## Rate Limit Headers

All API responses include rate limit information:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 998
X-RateLimit-Reset: 1705312800
```

**Header Definitions:**
- `X-RateLimit-Limit`: Total requests allowed per window
- `X-RateLimit-Remaining`: Requests remaining in current window
- `X-RateLimit-Reset`: Unix timestamp when limits reset

## Getting API Keys

### For Partners
1. Contact your C4HXP representative
2. Complete the partner onboarding process
3. Receive production and staging API keys
4. Test integration in staging environment

### For E-commerce Platforms
1. Apply through the C4HXP partner portal
2. Complete platform verification
3. Receive e-commerce API keys
4. Implement integration using provided SDKs

### For Development
1. Request development access
2. Receive limited development keys
3. Use for integration development only
4. Upgrade to production keys when ready

## Support

If you experience authentication issues:

- **Email**: api-support@c4hxp.com
- **Documentation**: [API Reference](api-reference.md)
- **Status**: https://status.c4hxp.com
- **Partner Portal**: https://partners.c4hxp.com 