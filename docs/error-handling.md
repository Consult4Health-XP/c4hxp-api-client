# Error Handling

Complete guide to handling errors when working with the C4HXP API.

## Error Response Format

All API errors follow a consistent JSON structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error description",
    "details": {
      // Additional error-specific information
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

## HTTP Status Codes

The API uses standard HTTP status codes to indicate the success or failure of requests:

| Code | Status | Description |
|------|--------|-------------|
| `200` | OK | Request successful |
| `201` | Created | Resource created successfully |
| `400` | Bad Request | Invalid request parameters |
| `401` | Unauthorized | Invalid or missing authentication |
| `403` | Forbidden | Valid auth but insufficient permissions |
| `404` | Not Found | Resource not found |
| `422` | Unprocessable Entity | Validation errors |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Internal Server Error | Unexpected server error |
| `502` | Bad Gateway | Upstream service error |
| `503` | Service Unavailable | Service temporarily unavailable |

## Error Codes

### Authentication Errors

#### `UNAUTHORIZED`
API key is invalid, missing, or malformed.

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid API key or secret",
    "details": {
      "hint": "Check that your API key format is correct: Api-Key {key_id}:{secret}"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

**Common Causes:**
- Invalid API key format
- Expired or revoked API key
- Missing Authorization header

**Solutions:**
- Verify API key format
- Check API key is active
- Ensure proper header format

#### `FORBIDDEN`
Valid authentication but insufficient permissions for the requested resource.

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

**Common Causes:**
- API key lacks required scopes
- Accessing resources outside your organization
- Development key used in production

**Solutions:**
- Request additional scopes from C4HXP
- Use appropriate API key type
- Check resource ownership

### Request Errors

#### `VALIDATION_ERROR`
Request parameters are invalid or missing required fields.

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "recipient.email",
        "issue": "Invalid email format",
        "provided": "invalid-email"
      },
      {
        "field": "recipient.address.zip",
        "issue": "Field is required",
        "provided": null
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

**Common Causes:**
- Missing required fields
- Invalid data formats
- Values outside allowed ranges

**Solutions:**
- Check required fields in API documentation
- Validate data before sending
- Use proper data types and formats

#### `RESOURCE_NOT_FOUND`
Requested resource doesn't exist or is not accessible.

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Order not found",
    "details": {
      "resource_type": "order",
      "resource_id": "12345"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

**Common Causes:**
- Invalid resource ID
- Resource belongs to different organization
- Resource has been deleted

**Solutions:**
- Verify resource ID is correct
- Check resource exists and is accessible
- Handle deleted resources gracefully

### Rate Limiting Errors

#### `RATE_LIMIT_EXCEEDED`
Too many requests sent in a given time period.

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "API rate limit exceeded",
    "details": {
      "limit": 1000,
      "window": "1 hour",
      "reset_at": "2024-01-15T11:00:00Z",
      "retry_after": 1800
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

**Solutions:**
- Implement exponential backoff
- Monitor rate limit headers
- Consider upgrading your plan

### Business Logic Errors

#### `ORDER_INVALID_STATE`
Order is in a state that doesn't allow the requested operation.

```json
{
  "error": {
    "code": "ORDER_INVALID_STATE",
    "message": "Cannot cancel order in current state",
    "details": {
      "current_state": "shipped",
      "allowed_states": ["pending", "confirmed"]
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

#### `KIT_ALREADY_REGISTERED`
Attempting to register a kit that's already registered.

```json
{
  "error": {
    "code": "KIT_ALREADY_REGISTERED",
    "message": "Kit is already registered",
    "details": {
      "kit_barcode": "123456789012",
      "registered_at": "2024-01-15T10:30:00Z",
      "patient_id": "PAT-789012"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

### Server Errors

#### `INTERNAL_SERVER_ERROR`
Unexpected server error occurred.

```json
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred",
    "details": {
      "reference_id": "err_abc123",
      "support_contact": "api-support@c4hxp.com"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

**Actions:**
- Retry the request after a delay
- Contact support if error persists
- Include reference_id when contacting support

## Error Handling Best Practices

### 1. Always Check Status Codes

Check HTTP status codes before processing responses:

```python
import requests

def make_api_request(url, headers, data=None):
    try:
        if data:
            response = requests.post(url, headers=headers, json=data)
        else:
            response = requests.get(url, headers=headers)
        
        # Check if request was successful
        response.raise_for_status()
        return response.json()
        
    except requests.exceptions.HTTPError as e:
        # Handle HTTP errors
        error_data = e.response.json() if e.response.content else {}
        handle_api_error(e.response.status_code, error_data)
        raise
    except requests.exceptions.RequestException as e:
        # Handle network errors
        print(f"Network error: {e}")
        raise
```

### 2. Implement Retry Logic

Implement smart retry logic for transient errors:

```python
import time
import random
from functools import wraps

def retry_on_error(max_retries=3, backoff_factor=1):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except requests.exceptions.HTTPError as e:
                    status_code = e.response.status_code
                    
                    # Don't retry client errors (4xx) except rate limiting
                    if 400 <= status_code < 500 and status_code != 429:
                        raise
                    
                    if attempt == max_retries:
                        raise
                    
                    # Calculate delay with exponential backoff and jitter
                    delay = backoff_factor * (2 ** attempt) + random.uniform(0, 1)
                    print(f"Request failed, retrying in {delay:.2f} seconds...")
                    time.sleep(delay)
                    
            return None
        return wrapper
    return decorator

@retry_on_error(max_retries=3)
def create_order(client, order_data):
    return client.orders.create(order_data)
```

### 3. Handle Specific Error Types

Create specific handlers for different error types:

```python
class C4HXPError(Exception):
    """Base exception for C4HXP API errors"""
    def __init__(self, message, error_code=None, details=None):
        super().__init__(message)
        self.error_code = error_code
        self.details = details

class AuthenticationError(C4HXPError):
    """Authentication-related errors"""
    pass

class ValidationError(C4HXPError):
    """Validation-related errors"""
    pass

class RateLimitError(C4HXPError):
    """Rate limiting errors"""
    def __init__(self, message, retry_after=None, **kwargs):
        super().__init__(message, **kwargs)
        self.retry_after = retry_after

def handle_api_error(status_code, error_data):
    """Convert API errors to appropriate exceptions"""
    error_code = error_data.get('error', {}).get('code')
    message = error_data.get('error', {}).get('message', 'Unknown error')
    details = error_data.get('error', {}).get('details', {})
    
    if status_code == 401:
        raise AuthenticationError(message, error_code, details)
    elif status_code == 422:
        raise ValidationError(message, error_code, details)
    elif status_code == 429:
        retry_after = details.get('retry_after')
        raise RateLimitError(message, retry_after, error_code=error_code, details=details)
    else:
        raise C4HXPError(message, error_code, details)
```

### 4. Log Errors Appropriately

Log errors with appropriate detail levels:

```python
import logging

logger = logging.getLogger(__name__)

def make_request_with_logging(url, headers, data=None):
    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()
        
        logger.info(f"Request successful: {response.status_code}")
        return response.json()
        
    except requests.exceptions.HTTPError as e:
        error_data = e.response.json() if e.response.content else {}
        error_code = error_data.get('error', {}).get('code', 'UNKNOWN')
        request_id = error_data.get('meta', {}).get('request_id')
        
        # Log error with context
        logger.error(
            f"API error: {error_code} - {e.response.status_code} "
            f"Request ID: {request_id} URL: {url}"
        )
        
        # Don't log sensitive data like API keys
        safe_headers = {k: v for k, v in headers.items() if k.lower() != 'authorization'}
        logger.debug(f"Request headers: {safe_headers}")
        
        raise
```

### 5. Graceful Degradation

Implement fallback behavior when possible:

```python
def get_kit_types_with_fallback(client, use_cache=True):
    """Get kit types with fallback to cached data"""
    try:
        # Try to fetch fresh data
        kit_types = client.get_kit_types()
        
        # Cache successful response
        cache_kit_types(kit_types)
        return kit_types
        
    except (RateLimitError, C4HXPError) as e:
        logger.warning(f"API request failed: {e}")
        
        if use_cache:
            # Fall back to cached data
            cached_data = get_cached_kit_types()
            if cached_data:
                logger.info("Using cached kit types data")
                return cached_data
        
        # Re-raise if no fallback available
        raise
```

## Error Handling by Language

### Python

```python
import requests
from typing import Optional, Dict, Any

class C4HXPClient:
    def __init__(self, api_key: str, secret: str):
        self.api_key = api_key
        self.secret = secret
        self.base_url = "https://api.c4hxp.com/v2/public/"
    
    def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict[Any, Any]:
        url = f"{self.base_url}{endpoint}"
        headers = {
            "Authorization": f"Api-Key {self.api_key}:{self.secret}",
            "Content-Type": "application/json"
        }
        
        try:
            response = requests.request(method, url, headers=headers, json=data)
            response.raise_for_status()
            return response.json()
            
        except requests.exceptions.HTTPError as e:
            self._handle_http_error(e)
        except requests.exceptions.RequestException as e:
            raise C4HXPError(f"Network error: {e}")
    
    def _handle_http_error(self, error: requests.exceptions.HTTPError):
        response = error.response
        try:
            error_data = response.json()
        except ValueError:
            error_data = {"error": {"message": "Unknown error"}}
        
        error_info = error_data.get("error", {})
        code = error_info.get("code", "UNKNOWN")
        message = error_info.get("message", "Unknown error")
        details = error_info.get("details", {})
        
        if response.status_code == 401:
            raise AuthenticationError(message, code, details)
        elif response.status_code == 422:
            raise ValidationError(message, code, details)
        elif response.status_code == 429:
            retry_after = details.get("retry_after")
            raise RateLimitError(message, retry_after, error_code=code, details=details)
        else:
            raise C4HXPError(message, code, details)
```

### JavaScript

```javascript
class C4HXPError extends Error {
    constructor(message, errorCode = null, details = null) {
        super(message);
        this.name = 'C4HXPError';
        this.errorCode = errorCode;
        this.details = details;
    }
}

class AuthenticationError extends C4HXPError {
    constructor(message, errorCode, details) {
        super(message, errorCode, details);
        this.name = 'AuthenticationError';
    }
}

class ValidationError extends C4HXPError {
    constructor(message, errorCode, details) {
        super(message, errorCode, details);
        this.name = 'ValidationError';
    }
}

class RateLimitError extends C4HXPError {
    constructor(message, retryAfter = null, errorCode = null, details = null) {
        super(message, errorCode, details);
        this.name = 'RateLimitError';
        this.retryAfter = retryAfter;
    }
}

class C4HXPClient {
    constructor(apiKey, secret) {
        this.apiKey = apiKey;
        this.secret = secret;
        this.baseUrl = 'https://api.c4hxp.com/v2/public/';
    }
    
    async _makeRequest(method, endpoint, data = null) {
        const url = `${this.baseUrl}${endpoint}`;
        const headers = {
            'Authorization': `Api-Key ${this.apiKey}:${this.secret}`,
            'Content-Type': 'application/json'
        };
        
        const config = {
            method,
            headers
        };
        
        if (data) {
            config.body = JSON.stringify(data);
        }
        
        try {
            const response = await fetch(url, config);
            
            if (!response.ok) {
                await this._handleHttpError(response);
            }
            
            return await response.json();
            
        } catch (error) {
            if (error instanceof C4HXPError) {
                throw error;
            }
            throw new C4HXPError(`Network error: ${error.message}`);
        }
    }
    
    async _handleHttpError(response) {
        let errorData;
        try {
            errorData = await response.json();
        } catch {
            errorData = { error: { message: 'Unknown error' } };
        }
        
        const errorInfo = errorData.error || {};
        const code = errorInfo.code || 'UNKNOWN';
        const message = errorInfo.message || 'Unknown error';
        const details = errorInfo.details || {};
        
        switch (response.status) {
            case 401:
                throw new AuthenticationError(message, code, details);
            case 422:
                throw new ValidationError(message, code, details);
            case 429:
                const retryAfter = details.retry_after;
                throw new RateLimitError(message, retryAfter, code, details);
            default:
                throw new C4HXPError(message, code, details);
        }
    }
}
```

### PHP

```php
<?php

class C4HXPException extends Exception {
    protected $errorCode;
    protected $details;
    
    public function __construct($message, $errorCode = null, $details = null, $code = 0, Throwable $previous = null) {
        parent::__construct($message, $code, $previous);
        $this->errorCode = $errorCode;
        $this->details = $details;
    }
    
    public function getErrorCode() {
        return $this->errorCode;
    }
    
    public function getDetails() {
        return $this->details;
    }
}

class AuthenticationException extends C4HXPException {}
class ValidationException extends C4HXPException {}
class RateLimitException extends C4HXPException {
    protected $retryAfter;
    
    public function __construct($message, $retryAfter = null, $errorCode = null, $details = null) {
        parent::__construct($message, $errorCode, $details);
        $this->retryAfter = $retryAfter;
    }
    
    public function getRetryAfter() {
        return $this->retryAfter;
    }
}

class C4HXPClient {
    private $apiKey;
    private $secret;
    private $baseUrl;
    
    public function __construct($apiKey, $secret) {
        $this->apiKey = $apiKey;
        $this->secret = $secret;
        $this->baseUrl = 'https://api.c4hxp.com/v2/public/';
    }
    
    private function makeRequest($method, $endpoint, $data = null) {
        $url = $this->baseUrl . $endpoint;
        $headers = [
            'Authorization: Api-Key ' . $this->apiKey . ':' . $this->secret,
            'Content-Type: application/json'
        ];
        
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_CUSTOMREQUEST => strtoupper($method)
        ]);
        
        if ($data) {
            curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($curl);
        $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        $error = curl_error($curl);
        curl_close($curl);
        
        if ($error) {
            throw new C4HXPException("Network error: $error");
        }
        
        $responseData = json_decode($response, true);
        
        if ($httpCode >= 400) {
            $this->handleHttpError($httpCode, $responseData);
        }
        
        return $responseData;
    }
    
    private function handleHttpError($statusCode, $responseData) {
        $errorInfo = $responseData['error'] ?? [];
        $code = $errorInfo['code'] ?? 'UNKNOWN';
        $message = $errorInfo['message'] ?? 'Unknown error';
        $details = $errorInfo['details'] ?? [];
        
        switch ($statusCode) {
            case 401:
                throw new AuthenticationException($message, $code, $details);
            case 422:
                throw new ValidationException($message, $code, $details);
            case 429:
                $retryAfter = $details['retry_after'] ?? null;
                throw new RateLimitException($message, $retryAfter, $code, $details);
            default:
                throw new C4HXPException($message, $code, $details);
        }
    }
}
?>
```

## Testing Error Handling

### Unit Testing Error Scenarios

```python
import pytest
import requests_mock
from your_client import C4HXPClient, ValidationError, AuthenticationError

def test_validation_error_handling():
    with requests_mock.Mocker() as m:
        # Mock validation error response
        m.post('https://api.c4hxp.com/v2/public/orders/', 
               status_code=422,
               json={
                   "error": {
                       "code": "VALIDATION_ERROR",
                       "message": "Invalid request parameters",
                       "details": [
                           {
                               "field": "recipient.email",
                               "issue": "Invalid email format"
                           }
                       ]
                   }
               })
        
        client = C4HXPClient('test_key', 'test_secret')
        
        with pytest.raises(ValidationError) as exc_info:
            client.create_order({
                "recipient": {"email": "invalid-email"}
            })
        
        assert exc_info.value.error_code == "VALIDATION_ERROR"
        assert "Invalid email format" in str(exc_info.value.details)

def test_authentication_error_handling():
    with requests_mock.Mocker() as m:
        m.get('https://api.c4hxp.com/v2/public/orders/123',
              status_code=401,
              json={
                  "error": {
                      "code": "UNAUTHORIZED",
                      "message": "Invalid API key"
                  }
              })
        
        client = C4HXPClient('invalid_key', 'invalid_secret')
        
        with pytest.raises(AuthenticationError):
            client.get_order(123)
```

## Monitoring and Alerting

Set up monitoring for error patterns:

```python
import logging
from collections import defaultdict
from datetime import datetime, timedelta

class ErrorMonitor:
    def __init__(self):
        self.error_counts = defaultdict(int)
        self.last_reset = datetime.now()
    
    def record_error(self, error_code, status_code):
        # Reset counts every hour
        if datetime.now() - self.last_reset > timedelta(hours=1):
            self.error_counts.clear()
            self.last_reset = datetime.now()
        
        self.error_counts[f"{status_code}:{error_code}"] += 1
        
        # Alert on high error rates
        if self.error_counts[f"{status_code}:{error_code}"] > 10:
            self.send_alert(f"High error rate: {error_code}")
    
    def send_alert(self, message):
        # Implement alerting logic (email, Slack, etc.)
        logging.critical(f"ALERT: {message}")

# Usage in your client
monitor = ErrorMonitor()

def handle_api_error(status_code, error_data):
    error_code = error_data.get('error', {}).get('code', 'UNKNOWN')
    monitor.record_error(error_code, status_code)
    # ... rest of error handling
```

## Support and Troubleshooting

When contacting support about errors:

1. **Include Request ID**: Always include the `request_id` from error responses
2. **Provide Context**: Describe what you were trying to accomplish
3. **Include Error Details**: Full error response and status code
4. **Timestamp**: When the error occurred
5. **Environment**: Which environment (production, staging)

**Support Contact:**
- **Email**: api-support@c4hxp.com
- **Include in Subject**: `[API Error] {error_code}`
- **Response Time**: 4-24 hours depending on severity 