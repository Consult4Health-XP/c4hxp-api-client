# Webhooks

Real-time notifications for order and result updates.

## Overview

Webhooks allow you to receive real-time notifications when events occur in the C4HXP system, eliminating the need to constantly poll the API for updates. When an event occurs, C4HXP sends an HTTP POST request to your configured endpoint.

## Webhook Events

### Order Events

#### `order.created`
Triggered when a new order is successfully created.

```json
{
  "event": "order.created",
  "data": {
    "id": 12345,
    "order_number": "C4H-ORD-2024-001234",
    "status": "pending",
    "recipient": {
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com"
    },
    "kit_types": ["hormone_panel"],
    "created_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "webhook_id": "wh_abc123",
    "api_version": "2.0.0"
  }
}
```

#### `order.confirmed`
Triggered when an order is confirmed and payment is processed.

#### `order.shipped`
Triggered when kits are shipped to the customer.

```json
{
  "event": "order.shipped",
  "data": {
    "id": 12345,
    "order_number": "C4H-ORD-2024-001234",
    "status": "shipped",
    "kits": [
      {
        "kit_id": "KIT-123456",
        "barcode": "123456789012",
        "tracking": {
          "carrier": "FedEx",
          "tracking_number": "1234567890",
          "estimated_delivery": "2024-01-18"
        }
      }
    ],
    "shipped_at": "2024-01-16T14:30:00Z"
  }
}
```

#### `order.cancelled`
Triggered when an order is cancelled.

### Kit Events

#### `kit.registered`
Triggered when a customer registers a kit.

```json
{
  "event": "kit.registered",
  "data": {
    "kit_barcode": "123456789012",
    "kit_type": "hormone_panel",
    "patient": {
      "first_name": "Jane",
      "last_name": "Smith",
      "email": "jane@example.com"
    },
    "collection_date": "2024-01-20T08:30:00Z",
    "registered_at": "2024-01-20T09:15:00Z"
  }
}
```

#### `kit.received_lab`
Triggered when a kit is received at the laboratory.

#### `kit.processing_started`
Triggered when sample processing begins.

#### `kit.processing_completed`
Triggered when sample processing is completed.

### Result Events

#### `results.available`
Triggered when test results become available.

```json
{
  "event": "results.available",
  "data": {
    "kit_barcode": "123456789012",
    "kit_type": "hormone_panel",
    "patient": {
      "first_name": "Jane",
      "last_name": "Smith",
      "email": "jane@example.com"
    },
    "result_summary": {
      "total_biomarkers": 8,
      "normal_count": 7,
      "abnormal_count": 1,
      "flags": ["high_cortisol"]
    },
    "completed_at": "2024-01-25T16:45:00Z",
    "pdf_available": true
  }
}
```

#### `results.reviewed`
Triggered when results are reviewed by a physician.

### System Events

#### `system.maintenance_scheduled`
Triggered when system maintenance is scheduled.

#### `system.maintenance_completed`
Triggered when system maintenance is completed.

## Setting Up Webhooks

### 1. Create Webhook Endpoint

Create an endpoint in your application to receive webhook events:

```python
from flask import Flask, request, jsonify
import hmac
import hashlib

app = Flask(__name__)

@app.route('/webhooks/c4hxp', methods=['POST'])
def handle_webhook():
    # Verify webhook signature
    signature = request.headers.get('X-C4HXP-Signature')
    if not verify_signature(request.data, signature):
        return 'Invalid signature', 401
    
    # Parse webhook data
    webhook_data = request.get_json()
    event_type = webhook_data.get('event')
    
    # Handle different event types
    if event_type == 'order.created':
        handle_order_created(webhook_data['data'])
    elif event_type == 'results.available':
        handle_results_available(webhook_data['data'])
    # ... handle other events
    
    return jsonify({'status': 'received'}), 200

def verify_signature(payload, signature):
    """Verify webhook signature for security"""
    webhook_secret = 'your_webhook_secret'
    expected_signature = hmac.new(
        webhook_secret.encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected_signature}", signature)
```

### 2. Register Webhook URL

Contact C4HXP support to register your webhook URL and receive your webhook secret.

**Required Information:**
- Webhook URL (must be HTTPS)
- Events you want to subscribe to
- Your API key for authentication verification

### 3. Configure Events

Specify which events you want to receive:

```json
{
  "webhook_url": "https://your-app.com/webhooks/c4hxp",
  "events": [
    "order.created",
    "order.shipped",
    "kit.registered",
    "results.available"
  ],
  "description": "Production webhook for order processing"
}
```

## Security

### Signature Verification

All webhooks include a signature header for verification:

```http
X-C4HXP-Signature: sha256=5d41402abc4b2a76b9719d911017c592
```

**Verification Examples:**

```python
import hmac
import hashlib

def verify_webhook_signature(payload, signature, secret):
    """Verify webhook signature"""
    expected_signature = hmac.new(
        secret.encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected_signature}", signature)
```

```javascript
const crypto = require('crypto');

function verifyWebhookSignature(payload, signature, secret) {
    const expectedSignature = crypto
        .createHmac('sha256', secret)
        .update(payload)
        .digest('hex');
    
    return crypto.timingSafeEqual(
        Buffer.from(`sha256=${expectedSignature}`),
        Buffer.from(signature)
    );
}
```

```php
function verifyWebhookSignature($payload, $signature, $secret) {
    $expectedSignature = 'sha256=' . hash_hmac('sha256', $payload, $secret);
    return hash_equals($expectedSignature, $signature);
}
```

### HTTPS Requirement

All webhook URLs must use HTTPS. C4HXP will not send webhooks to HTTP endpoints.

### IP Whitelisting

C4HXP sends webhooks from these IP ranges:
- `52.1.1.1/32`
- `52.1.1.2/32`
- `52.1.1.3/32`

*(Contact support for current IP ranges)*

## Implementation Examples

### Flask (Python)

```python
from flask import Flask, request, jsonify
import logging

app = Flask(__name__)
logger = logging.getLogger(__name__)

@app.route('/webhooks/c4hxp', methods=['POST'])
def c4hxp_webhook():
    try:
        # Verify signature
        if not verify_signature(request.data, request.headers.get('X-C4HXP-Signature')):
            logger.warning("Invalid webhook signature")
            return 'Unauthorized', 401
        
        webhook_data = request.get_json()
        event_type = webhook_data.get('event')
        
        logger.info(f"Received webhook: {event_type}")
        
        # Process webhook asynchronously to avoid timeouts
        process_webhook_async(webhook_data)
        
        return jsonify({'received': True}), 200
        
    except Exception as e:
        logger.error(f"Webhook processing error: {e}")
        return 'Internal error', 500

def process_webhook_async(webhook_data):
    """Process webhook in background task"""
    # Use Celery, RQ, or similar for background processing
    pass
```

### Express (Node.js)

```javascript
const express = require('express');
const crypto = require('crypto');
const app = express();

app.use(express.raw({ type: 'application/json' }));

app.post('/webhooks/c4hxp', (req, res) => {
    const signature = req.headers['x-c4hxp-signature'];
    
    if (!verifySignature(req.body, signature)) {
        return res.status(401).send('Unauthorized');
    }
    
    const webhookData = JSON.parse(req.body);
    const eventType = webhookData.event;
    
    console.log(`Received webhook: ${eventType}`);
    
    // Process webhook
    processWebhook(webhookData);
    
    res.json({ received: true });
});

function processWebhook(webhookData) {
    switch (webhookData.event) {
        case 'order.created':
            handleOrderCreated(webhookData.data);
            break;
        case 'results.available':
            handleResultsAvailable(webhookData.data);
            break;
        default:
            console.log(`Unhandled webhook event: ${webhookData.event}`);
    }
}
```

### Laravel (PHP)

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class WebhookController extends Controller
{
    public function handleC4HXP(Request $request)
    {
        $signature = $request->header('X-C4HXP-Signature');
        $payload = $request->getContent();
        
        if (!$this->verifySignature($payload, $signature)) {
            Log::warning('Invalid webhook signature');
            return response('Unauthorized', 401);
        }
        
        $webhookData = $request->json()->all();
        $eventType = $webhookData['event'];
        
        Log::info("Received webhook: {$eventType}");
        
        // Dispatch job for background processing
        ProcessWebhook::dispatch($webhookData);
        
        return response()->json(['received' => true]);
    }
    
    private function verifySignature($payload, $signature)
    {
        $secret = config('services.c4hxp.webhook_secret');
        $expectedSignature = 'sha256=' . hash_hmac('sha256', $payload, $secret);
        return hash_equals($expectedSignature, $signature);
    }
}
```

## Event Handling Patterns

### Idempotency

Webhooks may be delivered multiple times. Implement idempotency to handle duplicates:

```python
def handle_webhook(webhook_data):
    webhook_id = webhook_data['meta']['webhook_id']
    
    # Check if already processed
    if webhook_already_processed(webhook_id):
        logger.info(f"Webhook {webhook_id} already processed, skipping")
        return
    
    # Process webhook
    process_webhook(webhook_data)
    
    # Mark as processed
    mark_webhook_processed(webhook_id)
```

### Async Processing

Process webhooks asynchronously to avoid timeouts:

```python
from celery import Celery

celery_app = Celery('webhooks')

@celery_app.task
def process_webhook_task(webhook_data):
    """Background task to process webhook"""
    event_type = webhook_data['event']
    
    if event_type == 'results.available':
        # Send notification to customer
        send_results_notification(webhook_data['data'])
    elif event_type == 'order.shipped':
        # Update internal tracking
        update_order_tracking(webhook_data['data'])

@app.route('/webhooks/c4hxp', methods=['POST'])
def webhook_handler():
    webhook_data = request.get_json()
    
    # Queue for background processing
    process_webhook_task.delay(webhook_data)
    
    return jsonify({'received': True}), 200
```

### Error Handling

Implement robust error handling and logging:

```python
def handle_webhook_with_retry(webhook_data):
    max_retries = 3
    
    for attempt in range(max_retries):
        try:
            process_webhook(webhook_data)
            return
        except Exception as e:
            logger.error(f"Webhook processing failed (attempt {attempt + 1}): {e}")
            
            if attempt == max_retries - 1:
                # Send to dead letter queue or alert
                handle_webhook_failure(webhook_data, e)
                raise
            
            time.sleep(2 ** attempt)  # Exponential backoff
```

## Testing Webhooks

### Local Development

Use tools like ngrok to expose your local development server:

```bash
# Install ngrok
npm install -g ngrok

# Expose local server
ngrok http 3000

# Use the provided HTTPS URL as your webhook endpoint
# Example: https://abc123.ngrok.io/webhooks/c4hxp
```

### Webhook Testing Tools

```python
def test_webhook_endpoint():
    """Test your webhook endpoint with sample data"""
    test_webhook = {
        "event": "order.created",
        "data": {
            "id": 12345,
            "order_number": "C4H-ORD-2024-001234",
            "status": "pending"
        },
        "meta": {
            "timestamp": "2024-01-15T10:30:00Z",
            "webhook_id": "wh_test123"
        }
    }
    
    # Test your webhook handler
    response = handle_webhook(test_webhook)
    assert response.status_code == 200
```

## Webhook Retry Policy

C4HXP implements automatic retries for failed webhook deliveries:

- **Retry Schedule**: 1 minute, 5 minutes, 30 minutes, 2 hours, 6 hours
- **Max Retries**: 5 attempts
- **Timeout**: 30 seconds per attempt
- **Success Criteria**: HTTP 2xx response

## Monitoring and Debugging

### Webhook Logs

Monitor webhook delivery status through the C4HXP dashboard or contact support for webhook logs.

### Health Endpoint

Implement a health check endpoint for webhook monitoring:

```python
@app.route('/webhooks/health', methods=['GET'])
def webhook_health():
    return jsonify({
        'status': 'healthy',
        'webhook_endpoint': '/webhooks/c4hxp',
        'last_webhook_received': get_last_webhook_time(),
        'processed_count_today': get_todays_webhook_count()
    })
```

## Troubleshooting

### Common Issues

**Webhook not received:**
- Check HTTPS configuration
- Verify endpoint is publicly accessible
- Check firewall/security group settings

**Signature verification failing:**
- Ensure using correct webhook secret
- Verify signature calculation method
- Check payload encoding

**Timeout errors:**
- Implement async processing
- Reduce processing time in webhook handler
- Return 200 status quickly

### Support

For webhook issues:
- **Email**: api-support@c4hxp.com
- **Subject**: `[Webhook] {issue_description}`
- **Include**: Webhook URL, event types, error details
- **Response Time**: 4-24 hours

## Best Practices

1. **Respond Quickly**: Return HTTP 200 within 30 seconds
2. **Process Asynchronously**: Use background jobs for heavy processing
3. **Implement Idempotency**: Handle duplicate webhook deliveries
4. **Verify Signatures**: Always verify webhook authenticity
5. **Log Everything**: Maintain comprehensive webhook logs
6. **Handle Failures Gracefully**: Implement retry and error handling
7. **Monitor Performance**: Track webhook processing metrics
8. **Use HTTPS**: Always use secure endpoints
9. **Validate Data**: Validate webhook payloads before processing
10. **Plan for Scale**: Design for high webhook volume 