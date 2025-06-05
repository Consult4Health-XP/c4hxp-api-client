# Rate Limits

Understanding and working with C4HXP API rate limits.

## Overview

The C4HXP API implements rate limiting to ensure fair usage and maintain service quality for all users. Rate limits are applied per API key and are based on a sliding window approach.

## Rate Limit Tiers

Different API key types have different rate limits:

| Key Type | Requests/Hour | Requests/Day | Burst Limit |
|----------|---------------|--------------|-------------|
| **Partner** | 1,000 | 10,000 | 50/minute |
| **E-commerce** | 500 | 5,000 | 25/minute |
| **Development** | 100 | 1,000 | 10/minute |
| **Enterprise** | Custom | Custom | Custom |

### Rate Limit Windows

- **Hourly Window**: Rolling 60-minute window
- **Daily Window**: Rolling 24-hour window  
- **Burst Window**: Rolling 1-minute window for short bursts

## Rate Limit Headers

Every API response includes rate limit information in the headers:

```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1705315200
X-RateLimit-Window: 3600
X-RateLimit-Burst-Limit: 50
X-RateLimit-Burst-Remaining: 45
```

### Header Definitions

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Total requests allowed in the current window |
| `X-RateLimit-Remaining` | Requests remaining in the current window |
| `X-RateLimit-Reset` | Unix timestamp when the limit resets |
| `X-RateLimit-Window` | Window duration in seconds |
| `X-RateLimit-Burst-Limit` | Maximum burst requests per minute |
| `X-RateLimit-Burst-Remaining` | Burst requests remaining |

## Rate Limit Response

When you exceed your rate limit, you'll receive a `429 Too Many Requests` response:

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
    "request_id": "req_abc123"
  }
}
```

## Best Practices

### 1. Monitor Rate Limit Headers

Always check rate limit headers and adjust your request rate accordingly:

```python
import time
import requests

def make_request_with_rate_limiting(url, headers):
    response = requests.get(url, headers=headers)
    
    # Check rate limit headers
    remaining = int(response.headers.get('X-RateLimit-Remaining', 0))
    reset_time = int(response.headers.get('X-RateLimit-Reset', 0))
    
    # If running low on requests, slow down
    if remaining < 10:
        current_time = int(time.time())
        sleep_time = max(0, reset_time - current_time)
        print(f"Rate limit low, sleeping for {sleep_time} seconds")
        time.sleep(sleep_time)
    
    return response
```

### 2. Implement Exponential Backoff

When you hit rate limits, use exponential backoff to retry requests:

```python
import time
import random

def exponential_backoff_request(url, headers, max_retries=3):
    for attempt in range(max_retries + 1):
        response = requests.get(url, headers=headers)
        
        if response.status_code == 429:
            if attempt == max_retries:
                raise Exception("Max retries exceeded")
            
            # Exponential backoff with jitter
            base_delay = 2 ** attempt
            jitter = random.uniform(0, 1)
            delay = base_delay + jitter
            
            print(f"Rate limited, retrying in {delay:.2f} seconds...")
            time.sleep(delay)
            continue
            
        return response
    
    raise Exception("Request failed after all retries")
```

### 3. Batch Operations

Group multiple operations together to reduce API calls:

```python
# ✅ Good - Batch order creation
def create_multiple_orders(client, orders_data):
    # If API supports batch creation
    return client.orders.create_batch(orders_data)

# ❌ Less efficient - Individual order creation
def create_orders_individually(client, orders_data):
    results = []
    for order_data in orders_data:
        result = client.orders.create(order_data)  # Each call uses rate limit
        results.append(result)
    return results
```

### 4. Use Webhooks Instead of Polling

Instead of repeatedly polling for updates, use webhooks to receive notifications:

```python
# ❌ Bad - Polling for order updates
def poll_order_status(client, order_id):
    while True:
        order = client.orders.get(order_id)  # Uses rate limit
        if order.status == 'completed':
            break
        time.sleep(30)  # Still wastes API calls

# ✅ Good - Use webhooks
def setup_webhook(client):
    client.webhooks.create({
        'url': 'https://your-app.com/webhooks/c4hxp',
        'events': ['order.completed', 'results.available']
    })
```

### 5. Cache Responses

Cache responses that don't change frequently:

```python
import time
from functools import lru_cache

class C4HXPClient:
    def __init__(self, key_id, secret):
        self.key_id = key_id
        self.secret = secret
        self._kit_types_cache = None
        self._kit_types_cache_time = 0
    
    def get_kit_types(self, use_cache=True):
        # Cache kit types for 1 hour
        if (use_cache and 
            self._kit_types_cache and 
            time.time() - self._kit_types_cache_time < 3600):
            return self._kit_types_cache
        
        # Fetch from API
        response = self._make_request('/catalog/kit-types')
        self._kit_types_cache = response.json()
        self._kit_types_cache_time = time.time()
        
        return self._kit_types_cache
```

## Rate Limit Strategies

### 1. Request Queuing

Implement a queue system to manage API requests:

```python
import queue
import threading
import time

class RateLimitedQueue:
    def __init__(self, requests_per_second=1):
        self.requests_per_second = requests_per_second
        self.queue = queue.Queue()
        self.running = True
        
        # Start worker thread
        self.worker = threading.Thread(target=self._process_queue)
        self.worker.daemon = True
        self.worker.start()
    
    def _process_queue(self):
        while self.running:
            try:
                # Get next request
                request_func, args, kwargs = self.queue.get(timeout=1)
                
                # Execute request
                request_func(*args, **kwargs)
                
                # Rate limit delay
                time.sleep(1.0 / self.requests_per_second)
                
                self.queue.task_done()
            except queue.Empty:
                continue
    
    def add_request(self, func, *args, **kwargs):
        self.queue.put((func, args, kwargs))

# Usage
rate_limiter = RateLimitedQueue(requests_per_second=0.5)  # 1 request per 2 seconds

def process_orders():
    for order_data in orders:
        rate_limiter.add_request(create_order, order_data)
```

### 2. Distributed Rate Limiting

For applications with multiple servers, implement distributed rate limiting:

```python
import redis
import time

class DistributedRateLimiter:
    def __init__(self, redis_client, key_prefix="rate_limit"):
        self.redis = redis_client
        self.key_prefix = key_prefix
    
    def is_allowed(self, identifier, limit, window):
        key = f"{self.key_prefix}:{identifier}"
        current_time = int(time.time())
        window_start = current_time - window
        
        # Use Redis sorted set for sliding window
        pipe = self.redis.pipeline()
        
        # Remove old entries
        pipe.zremrangebyscore(key, 0, window_start)
        
        # Count current requests
        pipe.zcard(key)
        
        # Add current request
        pipe.zadd(key, {str(current_time): current_time})
        
        # Set expiry
        pipe.expire(key, window + 1)
        
        results = pipe.execute()
        current_count = results[1]
        
        return current_count < limit
```

## Monitoring and Alerting

### 1. Track Rate Limit Usage

Monitor your rate limit usage to optimize performance:

```python
import logging

class RateLimitMonitor:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    def log_rate_limit_status(self, response):
        headers = response.headers
        limit = headers.get('X-RateLimit-Limit')
        remaining = headers.get('X-RateLimit-Remaining')
        
        usage_percent = (1 - int(remaining) / int(limit)) * 100
        
        self.logger.info(f"Rate limit usage: {usage_percent:.1f}%")
        
        # Alert if usage is high
        if usage_percent > 80:
            self.logger.warning(f"High rate limit usage: {usage_percent:.1f}%")
```

### 2. Set Up Alerts

Configure alerts for rate limit issues:

```python
def check_rate_limit_health(client):
    try:
        response = client.get('/health')
        remaining = int(response.headers.get('X-RateLimit-Remaining', 0))
        limit = int(response.headers.get('X-RateLimit-Limit', 1))
        
        usage_percent = (1 - remaining / limit) * 100
        
        if usage_percent > 90:
            send_alert(f"Critical: Rate limit usage at {usage_percent:.1f}%")
        elif usage_percent > 75:
            send_warning(f"Warning: Rate limit usage at {usage_percent:.1f}%")
            
    except Exception as e:
        send_alert(f"Failed to check rate limit status: {e}")
```

## Upgrading Your Limits

### When to Upgrade

Consider upgrading your rate limits if you experience:

- Frequent `429` errors
- Delayed processing due to rate limiting
- Growing business requirements
- Need for real-time operations

### How to Request Higher Limits

1. **Document Your Use Case**: Explain why you need higher limits
2. **Provide Usage Metrics**: Show current usage patterns and projections
3. **Contact Support**: Reach out to api-support@c4hxp.com
4. **Consider Enterprise Plans**: Custom limits available for enterprise customers

### Enterprise Rate Limits

Enterprise customers can receive:

- **Custom Rate Limits**: Tailored to your specific needs
- **Dedicated Infrastructure**: Isolated rate limiting pools
- **Priority Support**: Faster response for rate limit issues
- **Advanced Monitoring**: Detailed rate limit analytics

## Testing Rate Limits

### 1. Test in Staging

Always test rate limit handling in the staging environment:

```python
def test_rate_limiting():
    client = C4HXPClient(staging_key_id, staging_secret)
    
    # Intentionally exceed rate limit
    for i in range(150):  # Exceeds 100/hour limit for dev keys
        try:
            response = client.get_kit_types()
            print(f"Request {i}: Success")
        except RateLimitExceeded:
            print(f"Request {i}: Rate limited")
            break
```

### 2. Simulate Production Load

Test your rate limiting strategy under realistic conditions:

```python
import concurrent.futures
import time

def load_test_rate_limiting():
    client = C4HXPClient(test_key_id, test_secret)
    
    def make_request(request_id):
        try:
            response = client.get_orders()
            return f"Request {request_id}: Success"
        except Exception as e:
            return f"Request {request_id}: Failed - {e}"
    
    # Simulate concurrent requests
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [
            executor.submit(make_request, i) 
            for i in range(100)
        ]
        
        for future in concurrent.futures.as_completed(futures):
            print(future.result())
```

## Common Issues and Solutions

### Issue: Sudden Rate Limit Increases

**Cause**: Code changes, new features, or batch operations

**Solution**:
- Review recent code changes
- Implement request throttling
- Use batch operations where possible

### Issue: Distributed System Rate Limiting

**Cause**: Multiple servers sharing the same API key

**Solution**:
- Implement distributed rate limiting
- Use separate API keys per service
- Coordinate request timing between services

### Issue: Webhooks vs Polling

**Cause**: Excessive polling for status updates

**Solution**:
- Implement webhook endpoints
- Reduce polling frequency
- Use conditional requests (ETags)

## Support

For rate limiting issues or limit increase requests:

- **Email**: api-support@c4hxp.com
- **Subject**: Include "Rate Limit" in the subject line
- **Include**: Current usage, business justification, and timeline
- **Response Time**: 1-2 business days for standard requests 