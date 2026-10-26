-- =============================================================
-- SEED DATA: بيانات تجريبية لدورة مشتريات كاملة
-- =============================================================

-- 1. إضافة موردين تجريبيين
INSERT INTO suppliers (id, name, email, phone, category, rating, is_active) VALUES
('e0000000-0000-0000-0000-000000000001', 'TechSource Solutions', 'sales@techsource.test', '+201001112233', 'Hardware', 4.8, true),
('e0000000-0000-0000-0000-000000000002', 'Global IT Distribution', 'rfq@globalit.test', '+201004445566', 'Hardware', 4.5, true),
('e0000000-0000-0000-0000-000000000003', 'Office Supplies Co.', 'orders@officesupplies.test', '+201007778899', 'Office Supplies', 4.2, true)
ON CONFLICT (email) DO NOTHING;

-- 2. إضافة طلب شراء تجريبي
INSERT INTO purchase_requests (id, title, department, requested_by, category, target_delivery_date, estimated_budget, currency, status, notes) VALUES
('a0000000-0000-0000-0000-000000000001', 'High-Performance Laptops for AI Team', 'IT', 'Ahmed Ali', 'Hardware', CURRENT_DATE + INTERVAL '15 days', 60000.00, 'USD', 'PENDING', 'Need laptops with at least 32GB RAM and dedicated GPU for development.')
ON CONFLICT (id) DO NOTHING;

-- 3. إضافة بنود طلب الشراء
INSERT INTO purchase_request_items (id, request_id, item_name, specifications, quantity, unit) VALUES
('f0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Workstation Laptop', 'AMD Ryzen 7 or Intel i7, 32GB RAM, 1TB NVMe, RTX 4060', 10, 'pcs')
ON CONFLICT (id) DO NOTHING;

-- 4. دعوات عروض الأسعار (RFQ Invitations)
INSERT INTO rfq_invitations (id, request_id, supplier_id, status, deadline_date) VALUES
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'RESPONDED', CURRENT_DATE + INTERVAL '5 days'),
('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'RESPONDED', CURRENT_DATE + INTERVAL '5 days'),
('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000003', 'RESPONDED', CURRENT_DATE + INTERVAL '5 days')
ON CONFLICT (id) DO NOTHING;

-- 5. عروض أسعار متنافسة (Quotes)
INSERT INTO quotes (id, rfq_invitation_id, request_id, supplier_id, quotation_reference, quotation_date, total_price, currency, delivery_time, warranty_period, payment_terms, discount, shipping_cost, document_url, status) VALUES
('c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'QT-TECH-2026-01', CURRENT_DATE, 54000.00, 'USD', '15 days', '1 Year', 'Net 30', 1000.00, 500.00, 'storage/quotes/techsource_quote.pdf', 'RECEIVED'),
('c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'QT-GLOB-2026-99', CURRENT_DATE, 56000.00, 'USD', '7 days', '2 Years', '50% Advance, 50% on Delivery', 500.00, 300.00, 'storage/quotes/globalit_quote.pdf', 'SELECTED')
ON CONFLICT (id) DO NOTHING;

-- 6. بنود عروض الأسعار
INSERT INTO quote_items (quote_id, item_description, quantity, unit_price, total_line_price) VALUES
('c0000000-0000-0000-0000-000000000001', 'Workstation Laptop RTX 4060', 10, 5450.00, 54500.00),
('c0000000-0000-0000-0000-000000000002', 'Workstation Laptop RTX 4060', 10, 5620.00, 56200.00);

-- 7. ملفات المرفقات
INSERT INTO quote_files (quote_id, file_path, original_filename, file_type, file_hash) VALUES
('c0000000-0000-0000-0000-000000000001', 'storage/quotes/techsource_quote.pdf', 'techsource_quote.pdf', 'application/pdf', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
('c0000000-0000-0000-0000-000000000002', 'storage/quotes/globalit_quote.pdf', 'globalit_quote.pdf', 'application/pdf', 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb')
ON CONFLICT (file_hash) DO NOTHING;

-- 8. سجل الاعتماد البشري
INSERT INTO approvals (id, request_id, selected_quote_id, approver_name, approver_email, decision, decision_reason) VALUES
('d0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'Procurement Manager', 'manager@company.test', 'APPROVED', 'Selected Global IT due to fast delivery (7 days) and 2-year warranty despite slightly higher price.')
ON CONFLICT (id) DO NOTHING;

-- 9. أمر الشراء النهائي
INSERT INTO purchase_orders (po_number, approval_id, quote_id, supplier_id, final_amount, currency, pdf_path) VALUES
('PO-2026-0001', 'd0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 56000.00, 'USD', 'storage/orders/PO-2026-0001.pdf')
ON CONFLICT (po_number) DO NOTHING;

-- 10. سجل التدقيق
INSERT INTO audit_logs (actor, action, operation_reference, new_state) VALUES
('Ahmed Ali', 'CREATE_PR', 'PR-2026-001', '{"status": "PENDING", "budget": 60000}'::jsonb),
('Procurement Manager', 'APPROVE_QUOTE', 'QT-GLOB-2026-99', '{"decision": "APPROVED", "po_number": "PO-2026-0001"}'::jsonb);
