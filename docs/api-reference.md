# API Reference

Complete reference for the C4HXP Laboratory Management API.

## Base URLs

| Environment | URL | Use Case |
|-------------|-----|----------|
| Production | `https://api.c4hxp.com/v2/public/` | Live integrations |
| Staging | `https://staging.api.c4hxp.com/v2/public/` | Testing and development |
| Development | Provided by C4HXP team | Integration development |

## Authentication

All API requests require authentication using your API key in the Authorization header:

```http
Authorization: Api-Key {key_id}:{secret}
```

**Example:**
```bash
curl -H "Authorization: Api-Key c4hxp_live_abc123:sk_live_xyz789" \
     https://api.c4hxp.com/v2/public/catalog/kit-types
```

## Response Format

All API responses use a consistent JSON structure:

```json
{
  "data": {
    // Response data here
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "version": "2.0.0"
  }
}
```

For paginated responses:
```json
{
  "data": [
    // Array of items
  ],
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123",
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 150,
      "total_pages": 8
    }
  }
}
```

## Error Format

Error responses include detailed information to help debug issues:

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
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

---

## 🛒 Catalog Endpoints

### List Available Kit Types

Get all available test kit types that can be ordered.

```http
GET /v2/public/catalog/kit-types
```

**Response:**
```json
{
  "data": [
    {
      "id": "hormone_panel",
      "name": "Comprehensive Hormone Panel",
      "description": "Complete hormone analysis including thyroid, reproductive, and stress hormones",
      "price": 199.99,
      "currency": "USD",
      "estimated_turnaround_days": 5,
      "category": "hormones",
      "collection_method": "blood_spot",
      "biomarkers": [
        "TSH",
        "Free T3",
        "Free T4",
        "Cortisol",
        "DHEA-S",
        "Testosterone",
        "Estradiol",
        "Progesterone"
      ],
      "available": true,
      "requires_fasting": false
    },
    {
      "id": "basic_metabolic",
      "name": "Basic Metabolic Panel",
      "description": "Essential health markers for overall wellness",
      "price": 79.99,
      "currency": "USD",
      "estimated_turnaround_days": 3,
      "category": "metabolic",
      "collection_method": "blood_spot",
      "biomarkers": [
        "Glucose",
        "HbA1c",
        "Total Cholesterol",
        "HDL",
        "LDL",
        "Triglycerides"
      ],
      "available": true,
      "requires_fasting": true
    }
  ]
}
```

---

## 🛍️ Order Endpoints

### Create Order

Create a new order for one or more test kits.

```http
POST /v2/public/orders/
```

**Request Body:**
```json
{
  "recipient": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "address": {
      "street1": "123 Main St",
      "street2": "Apt 456",
      "city": "Austin",
      "state": "TX",
      "zip": "78701",
      "country": "US"
    }
  },
  "kit_types": ["hormone_panel", "basic_metabolic"],
  "metadata": {
    "partner_reference": "ORDER-2024-001",
    "rush_processing": false,
    "special_instructions": "Customer prefers morning delivery"
  }
}
```

**Response (201 Created):**
```json
{
  "data": {
    "id": 12345,
    "order_number": "C4H-ORD-2024-001234",
    "status": "pending",
    "recipient": {
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "address": {
        "street1": "123 Main St",
        "street2": "Apt 456",
        "city": "Austin",
        "state": "TX",
        "zip": "78701",
        "country": "US"
      }
    },
    "kit_types": ["hormone_panel", "basic_metabolic"],
    "total_amount": 279.98,
    "currency": "USD",
    "estimated_delivery": "2024-01-18",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Order

Retrieve order details and current status.

```http
GET /v2/public/orders/{order_id}
```

**Parameters:**
- `order_id` (integer): The order ID

**Response:**
```json
{
  "data": {
    "id": 12345,
    "order_number": "C4H-ORD-2024-001234",
    "status": "shipped",
    "recipient": {
      // recipient details
    },
    "kit_types": ["hormone_panel", "basic_metabolic"],
    "kits": [
      {
        "kit_id": "KIT-HOR-123456",
        "kit_type": "hormone_panel",
        "barcode": "123456789012",
        "status": "shipped",
        "tracking": {
          "carrier": "FedEx",
          "tracking_number": "1234567890",
          "estimated_delivery": "2024-01-18"
        }
      },
      {
        "kit_id": "KIT-MET-123457",
        "kit_type": "basic_metabolic",
        "barcode": "123456789013",
        "status": "shipped",
        "tracking": {
          "carrier": "FedEx",
          "tracking_number": "1234567890",
          "estimated_delivery": "2024-01-18"
        }
      }
    ],
    "total_amount": 279.98,
    "currency": "USD",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-16T14:22:00Z"
  }
}
```

### Public Order Lookup

Look up order by order number (no authentication required).

```http
GET /v2/public/orders/lookup/{order_number}
```

**Parameters:**
- `order_number` (string): The order number (e.g., "C4H-ORD-2024-001234")

**Response:**
```json
{
  "data": {
    "order_number": "C4H-ORD-2024-001234",
    "status": "shipped",
    "estimated_delivery": "2024-01-18",
    "tracking_available": true,
    "kits_count": 2,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

---

## 🔬 Kit Endpoints

### Register Kit

Register a kit with patient demographic information.

```http
POST /v2/public/kits/register
```

**Request Body:**
```json
{
  "kit_barcode": "123456789012",
  "patient": {
    "first_name": "Jane",
    "last_name": "Smith",
    "date_of_birth": "1990-01-15",
    "gender": "female",
    "email": "jane@example.com",
    "phone": "+1234567890"
  },
  "collection_info": {
    "collection_date": "2024-01-20T08:30:00Z",
    "fasting_hours": 12,
    "medications": ["Levothyroxine 50mcg"],
    "notes": "Sample collected first thing in morning"
  }
}
```

**Response (200 OK):**
```json
{
  "data": {
    "kit_barcode": "123456789012",
    "registration_id": "REG-123456",
    "status": "registered",
    "patient_id": "PAT-789012",
    "collection_date": "2024-01-20T08:30:00Z",
    "registered_at": "2024-01-20T09:15:00Z",
    "next_steps": [
      "Ship kit to laboratory using provided prepaid label",
      "Track kit status at https://track.c4hxp.com/123456789012",
      "Results will be available in 3-5 business days"
    ]
  }
}
```

### Get Kit Status

Get current kit status and tracking information.

```http
GET /v2/public/kits/{kit_barcode}
```

**Parameters:**
- `kit_barcode` (string): The kit barcode

**Response:**
```json
{
  "data": {
    "kit_barcode": "123456789012",
    "kit_type": "hormone_panel",
    "status": "in_lab",
    "patient": {
      "first_name": "Jane",
      "last_name": "Smith",
      "email": "jane@example.com"
    },
    "timeline": [
      {
        "event": "kit_shipped",
        "timestamp": "2024-01-16T10:00:00Z",
        "description": "Kit shipped to customer"
      },
      {
        "event": "kit_registered",
        "timestamp": "2024-01-20T09:15:00Z",
        "description": "Kit registered with patient information"
      },
      {
        "event": "kit_received_lab",
        "timestamp": "2024-01-22T14:30:00Z",
        "description": "Kit received at laboratory"
      },
      {
        "event": "processing_started",
        "timestamp": "2024-01-23T08:00:00Z",
        "description": "Sample processing began"
      }
    ],
    "estimated_completion": "2024-01-25T17:00:00Z",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

---

## 📊 Results Endpoints

### Get Kit Results

Retrieve test results for a specific kit.

```http
GET /v2/public/results/kit/{kit_barcode}
```

**Parameters:**
- `kit_barcode` (string): The kit barcode

**Response:**
```json
{
  "data": {
    "kit_barcode": "123456789012",
    "kit_type": "hormone_panel",
    "status": "completed",
    "patient": {
      "first_name": "Jane",
      "last_name": "Smith"
    },
    "completed_at": "2024-01-25T16:45:00Z",
    "results": [
      {
        "biomarker": "TSH",
        "value": 2.1,
        "unit": "mIU/L",
        "reference_range": "0.4 - 4.0",
        "status": "normal",
        "flags": []
      },
      {
        "biomarker": "Free T3",
        "value": 3.8,
        "unit": "pg/mL",
        "reference_range": "2.3 - 4.2",
        "status": "normal",
        "flags": []
      },
      {
        "biomarker": "Free T4",
        "value": 1.6,
        "unit": "ng/dL",
        "reference_range": "0.8 - 1.8",
        "status": "normal",
        "flags": []
      },
      {
        "biomarker": "Cortisol",
        "value": 18.5,
        "unit": "μg/dL",
        "reference_range": "4.0 - 22.0",
        "status": "normal",
        "flags": ["morning_collection"]
      }
    ],
    "pdf_url": "/v2/public/results/123456789012/pdf",
    "physician_review": {
      "reviewed": true,
      "reviewer": "Dr. Sarah Johnson, MD",
      "reviewed_at": "2024-01-25T17:30:00Z",
      "notes": "All hormone levels within normal ranges. Continue current regimen."
    }
  }
}
```

### Download Result PDF

Download a formatted PDF report of test results.

```http
GET /v2/public/results/{result_id}/pdf
```

**Parameters:**
- `result_id` (string): The result ID or kit barcode

**Response:**
Returns a PDF file with appropriate headers:
```http
Content-Type: application/pdf
Content-Disposition: attachment; filename="results_123456789012.pdf"
```

---

## 🏥 Health Check Endpoint

### API Health Check

Check API availability and status.

```http
GET /v2/public/health
```

**Response:**
```json
{
  "data": {
    "status": "healthy",
    "version": "2.0.0",
    "timestamp": "2024-01-25T10:30:00Z",
    "services": {
      "database": "healthy",
      "lab_integration": "healthy",
      "notification_service": "healthy"
    },
    "uptime_seconds": 1234567
  }
}
```

---

## Status Codes

The API uses standard HTTP status codes:

| Code | Description |
|------|-------------|
| `200` | OK - Request successful |
| `201` | Created - Resource created successfully |
| `400` | Bad Request - Invalid request parameters |
| `401` | Unauthorized - Invalid or missing API key |
| `403` | Forbidden - Insufficient permissions |
| `404` | Not Found - Resource not found |
| `422` | Unprocessable Entity - Validation errors |
| `429` | Too Many Requests - Rate limit exceeded |
| `500` | Internal Server Error - Server error |
| `503` | Service Unavailable - Service temporarily down |

## Order Status Values

| Status | Description |
|--------|-------------|
| `pending` | Order created, processing payment |
| `confirmed` | Payment processed, preparing shipment |
| `shipped` | Kits shipped to customer |
| `delivered` | Kits delivered to customer |
| `registered` | Customer registered kits |
| `in_lab` | Kits received at laboratory |
| `completed` | Results available |
| `cancelled` | Order cancelled |

## Kit Status Values

| Status | Description |
|--------|-------------|
| `created` | Kit created in system |
| `shipped` | Kit shipped to customer |
| `delivered` | Kit delivered to customer |
| `registered` | Kit registered by customer |
| `shipped_to_lab` | Kit shipped back to lab |
| `received_lab` | Kit received at laboratory |
| `processing` | Sample being processed |
| `completed` | Results available |
| `failed` | Processing failed |
| `cancelled` | Kit cancelled 