# Integration Scenarios

Real-world implementation examples for different business use cases.

## 🏥 **Healthcare Provider Integration**

### **Use Case: Primary Care Clinic**

Offer comprehensive diagnostic testing to patients with seamless workflow integration.

#### **Implementation: Order Creation from EMR**

```python
from c4hxp_client import C4HXPClient

client = C4HXPClient(
    api_key="c4hxp_live_clinic_abc123",
    api_secret="sk_live_xyz789"
)

def create_patient_order(patient_id, recommended_tests, provider_info):
    """Create diagnostic test order for patient"""
    
    patient = emr_system.get_patient(patient_id)
    
    order = client.orders.create({
        "recipient": {
            "first_name": patient.first_name,
            "last_name": patient.last_name,
            "email": patient.email,
            "phone": patient.phone,
            "address": patient.address
        },
        "kit_types": recommended_tests,
        "metadata": {
            "emr_patient_id": patient_id,
            "provider_name": provider_info.name,
            "clinic_id": "CLINIC_001"
        }
    })
    
    # Update EMR with order information
    emr_system.create_lab_order({
        "patient_id": patient_id,
        "external_order_id": order.id,
        "order_number": order.order_number,
        "status": "ordered"
    })
    
    return order
```

---

## 🛒 **E-commerce Platform Integration**

### **Use Case: Health & Wellness Marketplace**

Add diagnostic testing products with automated fulfillment.

#### **Implementation: Product Catalog Integration**

```javascript
const { C4HXPClient } = require('@c4hxp/api-client');

const client = new C4HXPClient({
    apiKey: 'c4hxp_live_ecommerce_def456',
    apiSecret: 'sk_live_uvw123'
});

app.get('/api/health-tests', async (req, res) => {
    try {
        const kitTypes = await client.catalog.getKitTypes();
        
        const products = kitTypes.data.map(kit => ({
            id: kit.id,
            name: kit.name,
            description: kit.description,
            price: kit.price,
            category: kit.category,
            inStock: kit.available
        }));
        
        res.json({ products });
        
    } catch (error) {
        res.status(500).json({ error: 'Failed to load health tests' });
    }
});
```

---

## 🔬 **Laboratory Integration**

### **Use Case: Diagnostic Laboratory LIMS Integration**

Automate order processing and result submission.

#### **Implementation: RESTful API Result Submission**

```python
from c4hxp_client import C4HXPInternalClient
import requests

internal_client = C4HXPInternalClient(
    api_key="c4hxp_live_lab_ghi789",
    api_secret="sk_live_rst456"
)

def submit_results_via_api(lims_sample):
    """Submit sample results via RESTful API - RECOMMENDED"""
    
    c4hxp_results = {
        "kit_barcode": lims_sample.sample_id,
        "test_results": [],
        "lab_reference": lims_sample.id,
        "completed_at": lims_sample.completed_at.isoformat()
    }
    
    for analyte in lims_sample.analytes:
        result = {
            "biomarker": analyte.name,
            "value": analyte.value,
            "unit": analyte.unit,
            "reference_range": analyte.reference_range,
            "status": determine_status(analyte.value, analyte.reference_range)
        }
        c4hxp_results["test_results"].append(result)
    
    # Real-time API submission
    response = internal_client.results.create(c4hxp_results)
    return response

def submit_results_via_mllp(hl7_message):
    """Submit HL7 results via MLLP - For enterprise labs"""
    
    import socket
    
    # HL7 over MLLP connection
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('mllp.c4hxp.com', 6661))
    
    # MLLP framing: <SB>message<EB><CR>
    mllp_message = f"\x0B{hl7_message}\x1C\x0D"
    
    sock.send(mllp_message.encode())
    ack_response = sock.recv(1024).decode()
    sock.close()
    
    return ack_response

def submit_results_via_sftp(hl7_file_path):
    """Submit HL7 file via SFTP - Traditional method"""
    
    import paramiko
    
    sftp_client = paramiko.SSHClient()
    sftp_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    sftp_client.connect(
        hostname='sftp.c4hxp.com',
        username='lab_partner_001',
        key_filename='/path/to/private_key'
    )
    
    sftp = sftp_client.open_sftp()
    remote_path = f'/incoming/{os.path.basename(hl7_file_path)}'
    sftp.put(hl7_file_path, remote_path)
    
    sftp.close()
    sftp_client.close()
```

---

## 🏢 **White-Label Solution**

### **Use Case: Complete Branded Health Platform**

Launch a complete branded diagnostic testing platform.

#### **Implementation: Custom Branded Portal**

```react
import React from 'react';
import { C4HXPClient } from '@c4hxp/api-client';

const BrandedHealthPortal = () => {
    const client = new C4HXPClient({
        apiKey: process.env.REACT_APP_C4HXP_KEY,
        apiSecret: process.env.REACT_APP_C4HXP_SECRET,
        baseUrl: 'https://api.yourbrand.com/v2/public/'
    });
    
    return (
        <BrandedLayout>
            <Header brand="YourBrand Health" />
            <TestCatalog />
            <OrderHistory />
            <ResultsPortal />
        </BrandedLayout>
    );
};
```

---

## 🎯 **Integration Best Practices**

### **Security & Compliance**
- Always use HTTPS endpoints
- Store API keys securely
- Implement proper error handling
- Use webhook signature verification

### **Performance Optimization**
- Implement response caching
- Use webhook notifications instead of polling
- Batch operations when possible
- Monitor API usage

### **Testing & Validation**
- Use staging environment for development
- Implement comprehensive test suites
- Test error scenarios and edge cases

---

## 📞 **Support & Resources**

Need help with your integration?

- **Technical Documentation**: [Complete API Reference](api-reference.md)
- **SDK Documentation**: [Python](../sdks/python/README.md) | [JavaScript](../sdks/javascript/README.md) | [PHP](../sdks/php/README.md)
- **Code Examples**: [Working Examples Repository](../examples/)
- **Technical Support**: [api-support@c4hxp.com](mailto:api-support@c4hxp.com)
- **Business Development**: [partnerships@c4hxp.com](mailto:partnerships@c4hxp.com) 