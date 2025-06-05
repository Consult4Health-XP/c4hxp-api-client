#!/usr/bin/env python3
"""
Basic C4HXP API Integration Example

This example demonstrates the basic workflow:
1. Create an order
2. Track the order status
3. Register kit when received
4. Retrieve results when available

Prerequisites:
- pip install c4hxp-client
- Set environment variables: C4HXP_API_KEY, C4HXP_API_SECRET
"""

import os
import time
from c4hxp_client import C4HXPClient
from c4hxp_client.exceptions import (
    C4HXPAuthenticationError,
    C4HXPValidationError,
    C4HXPRateLimitError,
    C4HXPAPIError
)

def main():
    # Initialize client with environment variables
    try:
        client = C4HXPClient(
            api_key=os.getenv('C4HXP_API_KEY'),
            api_secret=os.getenv('C4HXP_API_SECRET'),
            # Use sandbox for testing
            base_url=os.getenv('C4HXP_BASE_URL', 'https://sandbox-api.c4hxp.com')
        )
        print("✅ Client initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize client: {e}")
        return

    # Step 1: Create an order
    print("\n🛍️ Creating order...")
    try:
        order = client.orders.create({
            "recipient": {
                "first_name": "John",
                "last_name": "Doe",
                "email": "john.doe@example.com",
                "phone": "+1234567890",
                "address": {
                    "street1": "123 Main Street",
                    "street2": "Apt 4B",
                    "city": "Anytown",
                    "state": "CA",
                    "zip": "12345",
                    "country": "US"
                }
            },
            "kit_types": ["hormone_panel"],
            "shipping_method": "standard",
            "notes": "Patient prefers morning delivery"
        })
        
        print(f"✅ Order created successfully!")
        print(f"   Order ID: {order['id']}")
        print(f"   Order Number: {order['order_number']}")
        print(f"   Status: {order['status']}")
        
    except C4HXPValidationError as e:
        print(f"❌ Validation error: {e.details}")
        return
    except C4HXPAuthenticationError:
        print("❌ Authentication failed. Check your API key and secret.")
        return
    except Exception as e:
        print(f"❌ Failed to create order: {e}")
        return

    # Step 2: Track order status
    print("\n📦 Tracking order...")
    try:
        order_status = client.orders.get(order['id'])
        print(f"Current status: {order_status['status']}")
        
        # Get detailed tracking if available
        if order_status['status'] != 'pending':
            tracking = client.orders.tracking(order['id'])
            print("📍 Tracking events:")
            for event in tracking.get('events', []):
                print(f"   {event['timestamp']}: {event['description']}")
                
    except Exception as e:
        print(f"❌ Failed to get order status: {e}")

    # Step 3: Get available kit types
    print("\n🧪 Available kit types...")
    try:
        kit_types = client.catalog.get_kit_types()
        print("Available tests:")
        for kit_type in kit_types.get('kit_types', []):
            print(f"   {kit_type['id']}: {kit_type['name']} - ${kit_type.get('price', 'N/A')}")
            
    except Exception as e:
        print(f"❌ Failed to get kit types: {e}")

    # Step 4: Simulate kit registration (normally done by patient)
    print("\n🔬 Simulating kit registration...")
    kit_barcode = "XP00012345"  # This would come from the actual kit
    
    try:
        registration = client.kits.register({
            "barcode": kit_barcode,
            "patient": {
                "first_name": "John",
                "last_name": "Doe",
                "date_of_birth": "1985-03-15"
            },
            "collection_date": "2024-01-15T09:30:00Z"
        })
        
        print(f"✅ Kit registered successfully!")
        print(f"   Kit Barcode: {kit_barcode}")
        print(f"   Status: {registration['status']}")
        
    except Exception as e:
        print(f"❌ Failed to register kit: {e}")

    # Step 5: Check kit status
    print("\n🔍 Checking kit status...")
    try:
        kit_status = client.kits.get_status(kit_barcode)
        print(f"Kit status: {kit_status['status']}")
        
        if 'tracking_events' in kit_status:
            print("Kit tracking:")
            for event in kit_status['tracking_events']:
                print(f"   {event['timestamp']}: {event['description']}")
                
    except Exception as e:
        print(f"❌ Failed to get kit status: {e}")

    # Step 6: Check for results (simulate)
    print("\n📊 Checking for results...")
    try:
        # In real usage, you'd check periodically or use webhooks
        results = client.results.get_by_kit(kit_barcode)
        
        if results['status'] == 'completed':
            print("✅ Results available!")
            print(f"Test Type: {results['test_type']}")
            print(f"Completed: {results['completed_at']}")
            
            print("📋 Test Results:")
            for test in results['results']:
                status_emoji = "✅" if test['status'] == 'normal' else "⚠️"
                print(f"   {status_emoji} {test['test_name']}: {test['value']} {test['unit']}")
                print(f"      Reference: {test['reference_range']}")
            
            # Get PDF URL
            pdf_url = client.results.get_pdf_url(results['id'])
            print(f"📄 PDF Report: {pdf_url}")
            
        else:
            print(f"⏳ Results not ready yet. Status: {results['status']}")
            
    except Exception as e:
        print(f"❌ Failed to get results: {e}")

    # Step 7: Check rate limit status
    print("\n📊 Rate limit status...")
    try:
        rate_limit = client.get_rate_limit_status()
        print(f"Requests remaining: {rate_limit['remaining']}")
        print(f"Reset time: {rate_limit['reset_time']}")
        
    except Exception as e:
        print(f"❌ Failed to get rate limit status: {e}")

    print("\n🎉 Integration example completed!")
    print("\nNext steps:")
    print("1. Set up webhooks for real-time notifications")
    print("2. Implement error handling and retry logic")
    print("3. Add logging for production monitoring")
    print("4. Test with your actual test environment")

if __name__ == "__main__":
    # Check for required environment variables
    if not os.getenv('C4HXP_API_KEY') or not os.getenv('C4HXP_API_SECRET'):
        print("❌ Missing required environment variables:")
        print("   Set C4HXP_API_KEY and C4HXP_API_SECRET")
        print("\nExample:")
        print("   export C4HXP_API_KEY=your_key_id")
        print("   export C4HXP_API_SECRET=your_secret")
        print("   export C4HXP_BASE_URL=https://sandbox-api.c4hxp.com")
        exit(1)
    
    main() 