CREATE TABLE fiscal_receipt (
    fiscal_receipt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID NOT NULL REFERENCES sale(sale_id),
    return_id UUID REFERENCES sale_return(return_id),
    receipt_type fiscal_receipt_type NOT NULL,
    afip_cbte_tipo INT NOT NULL, -- 11: Factura C, 12: Nota de Débito C, 13: Nota de Crédito C
    point_of_sale INT NOT NULL,
    receipt_number BIGINT NOT NULL,
    cae VARCHAR(14) NOT NULL,
    cae_due_date DATE NOT NULL,
    issue_date DATE NOT NULL,
    
    -- Snapshot del receptor al momento de la emisión
    doc_type INT NOT NULL, -- 80: CUIT, 96: DNI, 99: Sin identificar
    doc_number VARCHAR(20) NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    
    -- Snapshot dinerario (Monotributo: total = neto)
    total_amount NUMERIC(12, 2) NOT NULL,
    net_amount NUMERIC(12, 2) NOT NULL,
    
    -- Código para renderizar QR de ARCA (según RG 4291/2018)
    qr_payload TEXT NOT NULL,
    
    -- Auditoría legal y de auditor
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES users(user_id),

    -- Restricción legal: No pueden existir dos comprobantes con el mismo tipo, punto de venta y número
    CONSTRAINT uq_receipt_number UNIQUE (receipt_type, point_of_sale, receipt_number)
);

-- Índices de búsqueda frecuente
CREATE INDEX idx_fiscal_receipt_sale ON fiscal_receipt(sale_id);
CREATE INDEX idx_fiscal_receipt_return ON fiscal_receipt(return_id);
CREATE INDEX idx_fiscal_receipt_cae ON fiscal_receipt(cae);
CREATE INDEX idx_fiscal_receipt_dates ON fiscal_receipt(issue_date);
