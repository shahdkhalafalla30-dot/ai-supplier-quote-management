# AI Supplier & Quote Management System

An AI-powered system for managing supplier quotations, extracting quotation data, and comparing offers to support purchasing decisions.

## Project Overview

The system automates the purchasing quotation process, from receiving purchase requests to comparing supplier offers.

It uses AI to extract important information from quotation documents and helps the procurement team make informed decisions.

## Main Features

- Validate purchase requests.
- Match purchase requests with suitable suppliers.
- Send Requests for Quotation (RFQs) to suppliers.
- Process supplier quotations and PDF documents.
- Extract quotation information using AI.
- Compare supplier offers based on price and other terms.
- Require human approval before generating a purchase order.

## Planned Technologies

- **n8n:** Workflow automation.
- **PostgreSQL:** Database management.
- **Azure AI Document Intelligence:** Document and PDF extraction.
- **OpenAI API:** AI-assisted processing.

## Project Structure

- `docs/` — Project documentation and team tasks.
- `n8n-workflows/` — Planned automation workflows.
- `database/` — Database planning and schema documentation.
- `ai-extraction/` — AI extraction documentation.
- `tests/` — Planned test cases.

## Team Collaboration

The project is developed by a team of four members. Each member is responsible for an assigned part of the system.

See `docs/team-tasks.md` for team responsibilities.

## Safety and Validation

- Use synthetic data during development.
- Never commit API keys, passwords, or other secrets.
- Review uncertain AI-extracted values manually.
- Human approval is required before generating a purchase order.

## Project Status

Currently in the planning and repository setup phase. Implementation and testing are planned next.
