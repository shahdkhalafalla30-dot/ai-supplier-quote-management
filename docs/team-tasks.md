# Team Tasks and Responsibilities

## Project Name
AI Supplier & Quote Management System

## Team Size
4 Members

## Project Goal
Build an AI-powered system to automate supplier quotation requests, extract quotation details, compare supplier offers, and require human approval before generating a Purchase Order.

## Team Responsibilities

### Member 1: Project Coordination and Database
- Organize project documentation and requirements.
- Design the PostgreSQL database schema.
- Define tables for purchase requests, suppliers, quotations, and approvals.
- Document the data structure used by the team.

### Member 2: Supplier Management and RFQ Automation
- Define supplier information and eligibility criteria.
- Implement supplier matching for purchase requests.
- Build the n8n workflow for sending Requests for Quotation (RFQs).
- Document email workflow inputs and outputs.

### Member 3: AI and Quotation Data Extraction
- Prepare sample quotation documents using synthetic data.
- Implement quotation field extraction using the selected document AI service.
- Extract supplier name, price, currency, delivery time, warranty, and payment terms when available.
- Validate extracted fields and flag uncertain results for manual review.

### Member 4: Quotation Comparison and Approval
- Define transparent criteria for comparing supplier offers.
- Implement quotation comparison and ranking.
- Present comparison results for procurement review.
- Ensure human approval is required before Purchase Order generation.

## Collaboration Rules
- Each member should work on an agreed task and communicate changes to the team.
- Use Git branches for separate tasks and Pull Requests to review changes before merging.
- Agree on database schemas and input/output formats before integrating components.
- Test each component with sample data before integration.
- Document setup instructions, dependencies, and known limitations.

## Security Rules
- Never commit API keys, passwords, or real secrets.
- Use synthetic supplier and quotation data during development.
- Do not generate a Purchase Order without explicit human approval.

## Current Status
Repository created. Team responsibilities and implementation details are to be confirmed by all four members.
