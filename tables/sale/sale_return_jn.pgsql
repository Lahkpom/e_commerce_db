-- =============================================================================
-- 1. TABLA JOURNAL: sale_return_jn
-- =============================================================================

CREATE TABLE sale_return_jn (
    jn_id                       BIGINT                  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jn_operation                VARCHAR(10)             NOT NULL CHECK (jn_operation IN ('UPDATE', 'DELETE')),
    jn_timestamp                TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    jn_changed_by               VARCHAR(255)            NULL, -- Usuario de aplicación o sesión DB

    -- Snapshot idéntico del registro sale_return tal como estaba antes del cambio (OLD)
    return_id                   UUID                    NOT NULL,
    sale_id                     UUID                    NOT NULL,
    tracking_token              UUID                    NOT NULL,
    return_reason               enum_return_reason      NOT NULL,
    return_resolution           enum_return_resolution  NOT NULL,
    return_status               enum_return_status      NOT NULL,
    shipping_covered_by_store   BOOLEAN                 NOT NULL,
    return_shipping_guide       VARCHAR(100)            NULL,
    refund_amount               DECIMAL(12, 2)          NOT NULL,
    customer_notes              TEXT                    NOT NULL,
    inspection_notes            TEXT                    NULL,
    inspection_evidence_path    TEXT                    NULL,
    inspected_by                UUID                    NULL,
    inspected_at                TIMESTAMPTZ             NULL,
    created_at                  TIMESTAMPTZ             NOT NULL,
    updated_at                  TIMESTAMPTZ             NULL,
    closed_at                   TIMESTAMPTZ             NULL
);

-- Índice optimizado para consultar el historial de auditoría de una devolución puntual
CREATE INDEX idx_sale_return_jn_return_id ON sale_return_jn(return_id, jn_timestamp DESC);

-- FUNCIÓN DISPARADORA DEL TRIGGER: trg_fn_audit_sale_return()
CREATE OR REPLACE FUNCTION trg_fn_audit_sale_return()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_changed_by VARCHAR(255);
BEGIN
    -- Intenta capturar el usuario de la aplicación inyectado en el contexto transaccional
    v_changed_by := NULLIF(current_setting('app.current_user', true), '');
    IF v_changed_by IS NULL THEN
        v_changed_by := SESSION_USER;
    END IF;

    INSERT INTO sale_return_jn (
        jn_operation,
        jn_timestamp,
        jn_changed_by,
        return_id,
        sale_id,
        tracking_token,
        return_reason,
        return_resolution,
        return_status,
        shipping_covered_by_store,
        return_shipping_guide,
        refund_amount,
        customer_notes,
        inspection_notes,
        inspection_evidence_path,
        inspected_by,
        inspected_at,
        created_at,
        updated_at,
        closed_at
    ) VALUES (
        TG_OP,
        NOW(),
        v_changed_by,
        OLD.return_id,
        OLD.sale_id,
        OLD.tracking_token,
        OLD.return_reason,
        OLD.return_resolution,
        OLD.return_status,
        OLD.shipping_covered_by_store,
        OLD.return_shipping_guide,
        OLD.refund_amount,
        OLD.customer_notes,
        OLD.inspection_notes,
        OLD.inspection_evidence_path,
        OLD.inspected_by,
        OLD.inspected_at,
        OLD.created_at,
        OLD.updated_at,
        OLD.closed_at
    );

    IF TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;


CREATE TRIGGER trg_sale_return_audit
    AFTER UPDATE OR DELETE ON sale_return
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_audit_sale_return();

-- Comentarios documentales
COMMENT ON TABLE sale_return_jn                         IS 'Tabla journal histórica para auditoría total de modificaciones y bajas en solicitudes de devolución/RMA.';
COMMENT ON COLUMN sale_return_jn.jn_id                  IS 'Identificador único secuencial del registro histórico de auditoría.';
COMMENT ON COLUMN sale_return_jn.jn_operation           IS 'Operación que disparó el registro histórico (UPDATE o DELETE).';
COMMENT ON COLUMN sale_return_jn.jn_timestamp           IS 'Marca de tiempo UTC exacta en que se ejecutó la operación de auditoría.';
COMMENT ON COLUMN sale_return_jn.jn_changed_by          IS 'Identificador del actor o sesión que ejecutó la sentencia en base de datos.';