# Project Tests

## Purpose
This folder contains test cases and sample data used to verify the AI Supplier & Quote Management System.

## Planned Test Cases

### 1. Purchase Request Validation
- Verify that required fields are present.
- Reject requests with missing or invalid information.

### 2. Supplier Matching
- Verify that eligible suppliers are selected based on the request requirements.

### 3. Quotation Extraction
- Test extraction of supplier name, price, currency, delivery time, warranty, and payment terms.
- Flag missing or uncertain fields for manual review.

### 4. Quotation Comparison
- Verify that supplier offers are compared using agreed criteria.
- Check that prices and currencies are handled correctly.

### 5. Human Approval
- Verify that a Purchase Order cannot be generated without explicit approval.
- Test rejection and pending-approval scenarios.

### 6. Error Handling
- Test invalid documents, missing fields, and failed service requests.

## Test Data
Use synthetic supplier records and quotation documents only.

## Current Status
Test cases are planned. Automated tests have not yet been implemented.
