CREATE TABLE sale_jn (
    jn_id                   BIGINT              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jn_operation            VARCHAR(10)         NOT NULL CHECK (jn_operation IN ('UPDATE', 'DELETE')),
    jn_timestamp            TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    jn_changed_by           VARCHAR(255)        NULL, -- Usuario o contexto que ejecutó la modificación
    
    -- Snapshot idéntico del registro sale tal como estaba antes del cambio (OLD)
    sale_id                 UUID                NOT NULL,
    user_id                 UUID                NULL,
    tracking_token          UUID                NOT NULL,
    customer_name           VARCHAR(255)        NOT NULL,
    customer_email          VARCHAR(255)        NOT NULL,
    customer_phone          VARCHAR(50)         NOT NULL,
    customer_tax_id_type    tax_id_type         NULL,
    customer_tax_id_number  VARCHAR(20)         NULL,
    customer_notes          TEXT                NULL,
    shipping_address        TEXT                NOT NULL,
    internal_notes          TEXT                NULL,
    sale_quantity           INTEGER             NOT NULL,
    sale_subtotal           DECIMAL(12, 2)      NOT NULL,
    sale_discount_amount    DECIMAL(12, 2)      NOT NULL,
    shipping_cost           DECIMAL(12, 2)      NOT NULL,
    sale_total              DECIMAL(12, 2)      NOT NULL,
    sale_shipped_at         TIMESTAMPTZ         NULL,
    sale_delivered_at       TIMESTAMPTZ         NULL,
    sale_status             enum_sale_status    NOT NULL,
    payment_method          enum_payment_method NOT NULL,
    payment_status          enum_payment_status NOT NULL,
    fiscal_rejection        BOOLEAN             NOT NULL,
    mp_payment_id           VARCHAR(100)        NULL,
    mp_preference_id        VARCHAR(100)        NULL,
    mp_merchant_order_id    VARCHAR(100)        NULL,
    created_at              TIMESTAMPTZ         NOT NULL,
    updated_at              TIMESTAMPTZ         NULL,
    updated_by              UUID                NULL
);
-- ########################################################################################
-- Índice de optimización para consultar la cronología de una venta específica
CREATE INDEX idx_sale_jn_sale_id ON sale_jn(sale_id, jn_timestamp DESC);
-- ########################################################################################
-- 2. Función del trigger para capturar el snapshot previo
CREATE OR REPLACE FUNCTION trg_fn_audit_sale()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_changed_by VARCHAR(255);
BEGIN
    v_changed_by := NULLIF(current_setting('app.current_user', true), '');
    IF v_changed_by IS NULL THEN
        v_changed_by := SESSION_USER;
    END IF;

    INSERT INTO sale_jn (
        jn_operation,
        jn_timestamp,
        jn_changed_by,
        sale_id,
        user_id,
        tracking_token,
        customer_name,
        customer_email,
        customer_phone,
        customer_tax_id_type,
        customer_tax_id_number,
        customer_notes,
        shipping_address,
        internal_notes,
        sale_quantity,
        sale_subtotal,
        sale_discount_amount,
        shipping_cost,
        sale_total,
        sale_shipped_at,
        sale_delivered_at,
        sale_status,
        payment_method,
        payment_status,
        fiscal_rejection,
        mp_payment_id,
        mp_preference_id,
        mp_merchant_order_id,
        created_at,
        updated_at,
        updated_by
    ) VALUES (
        TG_OP,
        NOW(),
        v_changed_by,
        OLD.sale_id,
        OLD.user_id,
        OLD.tracking_token,
        OLD.customer_name,
        OLD.customer_email,
        OLD.customer_phone,
        OLD.customer_tax_id_type,
        OLD.customer_tax_id_number,
        OLD.customer_notes,
        OLD.shipping_address,
        OLD.internal_notes,
        OLD.sale_quantity,
        OLD.sale_subtotal,
        OLD.sale_discount_amount,
        OLD.shipping_cost,
        OLD.sale_total,
        OLD.sale_shipped_at,
        OLD.sale_delivered_at,
        OLD.sale_status,
        OLD.payment_method,
        OLD.payment_status,
        OLD.fiscal_rejection,
        OLD.mp_payment_id,
        OLD.mp_preference_id,
        OLD.mp_merchant_order_id,
        OLD.created_at,
        OLD.updated_at,
        OLD.updated_by
    );

    IF      TG_OP = 'UPDATE' THEN RETURN NEW;
    ELSIF   TG_OP = 'DELETE' THEN RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;
-- ########################################################################################
CREATE TRIGGER trg_sale_audit
    AFTER UPDATE OR DELETE ON sale
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_audit_sale();
-- ########################################################################################
COMMENT ON TABLE sale_jn                        IS 'Tabla journal histórica para auditoría total de modificaciones y bajas en órdenes de compra.';
COMMENT ON COLUMN sale_jn.jn_id                 IS 'Identificador único secuencial del registro histórico de auditoría.';
COMMENT ON COLUMN sale_jn.jn_operation          IS 'Operación que disparó el registro histórico (UPDATE o DELETE).';
COMMENT ON COLUMN sale_jn.jn_timestamp          IS 'Marca de tiempo UTC exacta en que se ejecutó la operación.';
COMMENT ON COLUMN sale_jn.jn_changed_by         IS 'Identificador del actor o sesión de base de datos que ejecutó la sentencia.';