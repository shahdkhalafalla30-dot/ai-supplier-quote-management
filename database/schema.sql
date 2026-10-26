-- تفعيل إضافة الـ UUID لتوليد معرّفات فريدة
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -------------------------------------------------------------
-- 1. جدول الموردين (Suppliers)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50),
    category VARCHAR(100) NOT NULL,
    rating NUMERIC(2, 1) DEFAULT 5.0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 2. جدول طلبات الشراء الداخلية (Purchase Requests)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS purchase_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    department VARCHAR(100) NOT NULL,
    requested_by VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    target_delivery_date DATE,
    estimated_budget NUMERIC(12, 2),
    currency VARCHAR(10) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'RFQ_SENT', 'COMPARING', 'APPROVED', 'REJECTED', 'COMPLETED')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 3. جدول بنود طلب الشراء التفصيلية (Purchase Request Items)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS purchase_request_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES purchase_requests(id) ON DELETE CASCADE,
    item_name VARCHAR(255) NOT NULL,
    specifications TEXT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit VARCHAR(50) DEFAULT 'pcs'
);

-- -------------------------------------------------------------
-- 4. جدول دعوات طلبات عروض الأسعار (RFQ Invitations)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rfq_invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES purchase_requests(id) ON DELETE CASCADE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'SENT' CHECK (status IN ('SENT', 'RESPONDED', 'OVERDUE', 'NEEDS_REVIEW')),
    deadline_date DATE
);

-- -------------------------------------------------------------
-- 5. جدول عروض الأسعار المستخرجة (Supplier Quotations)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rfq_invitation_id UUID REFERENCES rfq_invitations(id) ON DELETE SET NULL,
    request_id UUID NOT NULL REFERENCES purchase_requests(id) ON DELETE CASCADE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
    quotation_reference VARCHAR(100),
    quotation_date DATE,
    total_price NUMERIC(12, 2) NOT NULL,
    discount NUMERIC(12, 2) DEFAULT 0.00,
    shipping_cost NUMERIC(12, 2) DEFAULT 0.00,
    currency VARCHAR(10) NOT NULL,
    delivery_time VARCHAR(100),
    warranty_period VARCHAR(100),
    payment_terms TEXT,
    quote_valid_until DATE,
    document_url TEXT NOT NULL,
    raw_ai_extraction JSONB,
    needs_review BOOLEAN DEFAULT FALSE,
    review_reason TEXT,
    status VARCHAR(50) DEFAULT 'RECEIVED' CHECK (status IN ('RECEIVED', 'UNDER_REVIEW', 'SELECTED', 'REJECTED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 6. جدول بنود عرض السعر (Quotation Items)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quote_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quote_id UUID NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    item_description VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL,
    total_line_price NUMERIC(12, 2) NOT NULL
);

-- -------------------------------------------------------------
-- 7. جدول مرفقات وملفات العروض الأصلية (Quote Files)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quote_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    file_hash VARCHAR(64) NOT NULL UNIQUE,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 8. جدول سجل الموافقات البشرية (Approval Records)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES purchase_requests(id) ON DELETE CASCADE,
    selected_quote_id UUID NOT NULL REFERENCES quotes(id) ON DELETE RESTRICT,
    approver_name VARCHAR(150) NOT NULL,
    approver_email VARCHAR(255) NOT NULL,
    decision VARCHAR(50) NOT NULL CHECK (decision IN ('APPROVED', 'REJECTED')),
    decision_reason TEXT,
    decided_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 9. جدول أوامر الشراء النهائية (Purchase Orders)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number VARCHAR(100) NOT NULL UNIQUE,
    approval_id UUID NOT NULL UNIQUE REFERENCES approvals(id) ON DELETE RESTRICT,
    quote_id UUID NOT NULL REFERENCES quotes(id) ON DELETE RESTRICT,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
    final_amount NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    pdf_path TEXT,
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 10. جدول سجلات التدقيق والحوكمة (Audit Logs)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor VARCHAR(150) NOT NULL,
    action VARCHAR(100) NOT NULL,
    operation_reference VARCHAR(100),
    old_state JSONB,
    new_state JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 11. جدول عرض مقارنة الأسعار البرمجية (View)
-- -------------------------------------------------------------
CREATE OR REPLACE VIEW view_quote_comparisons AS
SELECT 
    pr.id AS request_id,
    pr.title AS request_title,
    s.name AS supplier_name,
    s.rating AS supplier_rating,
    q.id AS quote_id,
    q.quotation_reference,
    q.total_price,
    q.discount,
    q.shipping_cost,
    (q.total_price - COALESCE(q.discount, 0) + COALESCE(q.shipping_cost, 0)) AS calculated_net_total,
    q.currency,
    q.delivery_time,
    q.warranty_period,
    q.payment_terms,
    q.needs_review,
    q.status AS quote_status
FROM quotes q
JOIN suppliers s ON q.supplier_id = s.id
JOIN purchase_requests pr ON q.request_id = pr.id;

-- -------------------------------------------------------------
-- 12. الفهارس لتحسين الأداء (Indexes)
-- -------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_suppliers_category ON suppliers(category);
CREATE INDEX IF NOT EXISTS idx_quotes_request_id ON quotes(request_id);
CREATE INDEX IF NOT EXISTS idx_quote_items_quote_id ON quote_items(quote_id);
CREATE INDEX IF NOT EXISTS idx_rfq_invitations_req ON rfq_invitations(request_id);
CREATE INDEX IF NOT EXISTS idx_quote_files_hash ON quote_files(file_hash);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ref ON audit_logs(operation_reference);
