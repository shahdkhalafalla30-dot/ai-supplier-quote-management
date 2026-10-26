# AI Quotation Data Extraction

## Purpose
Extract structured information from supplier quotation documents to support quotation comparison.

## Planned Fields
- Supplier name
- Quotation reference
- Quotation date
- Total price
- Currency
- Delivery time
- Warranty period
- Payment terms

## Planned Processing
1. Receive a quotation document.
2. Extract text and tables using the selected document processing service.
3. Convert the extracted information into structured fields.
4. Validate required fields and data types.
5. Flag missing or uncertain values for human review.
6. Pass validated quotation data to the comparison component.

## Planned Technologies
- Azure AI Document Intelligence for document and table extraction.
- OpenAI API for AI-assisted structuring or explanation, if needed.

## Security and Reliability
- Use synthetic quotation documents during development.
- Never commit API keys or credentials.
- Do not assume uncertain extracted values are correct.
- Keep the original quotation available for human verification.

## Current Status
Design and implementation are pending.
