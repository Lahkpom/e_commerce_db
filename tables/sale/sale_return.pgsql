-- =============================================================================
-- TABLA: sale_return (Cabecera del expediente de devolución/cambio)
-- =============================================================================
CREATE TABLE sale_return (
    return_id                   UUID                    PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id                     UUID                    NOT NULL REFERENCES sale(sale_id) ON DELETE RESTRICT,
    tracking_token              UUID                    NOT NULL DEFAULT gen_random_uuid(),
    
    -- Clasificación y resolución
    return_reason               enum_return_reason      NOT NULL,
    return_resolution           enum_return_resolution  NOT NULL DEFAULT 'REEMBOLSO_DINERO',
    return_status               enum_return_status      NOT NULL DEFAULT 'SOLICITADA',
    
    -- Políticas de logística inversa
    shipping_covered_by_store   BOOLEAN                 NOT NULL DEFAULT TRUE,
    return_shipping_guide       VARCHAR(100)            NULL, -- Código de seguimiento de la etiqueta inversa de correo
    
    -- Liquidación financiera calculada
    refund_amount               DECIMAL(12, 2)          NOT NULL DEFAULT 0.00 CHECK (refund_amount >= 0),
    
    -- Declaración del cliente
    customer_notes              TEXT                    NOT NULL, -- Explicación del cliente al pedir la devolución
    
    -- Dictamen e inspección en depósito/taller
    inspection_notes            TEXT                    NULL, -- Detalle técnico tras abrir e inspeccionar las prendas
    inspection_evidence_path    TEXT                    NULL, -- URL/Bucket con fotografías del peritaje (clave ante rechazos)
    inspected_by                UUID                    NULL REFERENCES users(user_id) ON DELETE SET NULL,
    inspected_at                TIMESTAMPTZ             NULL,
    
    -- Trazabilidad temporal
    created_at                  TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ             NULL,
    closed_at                   TIMESTAMPTZ             NULL  -- Fecha efectiva de resolución final (aprobada/rechazada/liquidada)
);

-- Índices de consulta operativa
CREATE INDEX idx_sale_return_sale           ON sale_return(sale_id);
CREATE INDEX idx_sale_return_status         ON sale_return(return_status);
CREATE INDEX idx_sale_return_created_at     ON sale_return(created_at DESC);

CREATE UNIQUE INDEX uq_sale_return_tracking ON sale_return(tracking_token);

-- Trigger de actualización automática de timestamp
CREATE TRIGGER trg_sale_return_update
    BEFORE UPDATE ON sale_return
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios documentales
COMMENT ON TABLE sale_return                            IS 'Expediente de posventa, reclamos de arrepentimiento legal y cambios de producto.';
COMMENT ON COLUMN sale_return.sale_id                   IS 'Orden de compra original vinculada. ON DELETE RESTRICT impide borrar ventas con reclamos históricos.';
COMMENT ON COLUMN sale_return.tracking_token            IS 'Token de consulta pública para que el cliente siga el peritaje de su devolución sin loguearse.';
COMMENT ON COLUMN sale_return.return_reason             IS 'Motivo tipificado de la solicitud (Arrepentimiento 10 días, cambio de talle o defecto).';
COMMENT ON COLUMN sale_return.return_resolution         IS 'Mecanismo de compensación: devolución monetaria, envío de reemplazo o saldo a favor.';
COMMENT ON COLUMN sale_return.shipping_covered_by_store IS 'Define si el flete inverso corre por cuenta del comercio (obligatorio por ley en arrepentimiento).';
COMMENT ON COLUMN sale_return.return_shipping_guide     IS 'Número de tracking de la etiqueta provista al cliente para enviar el paquete de regreso.';
COMMENT ON COLUMN sale_return.refund_amount             IS 'Monto monetario exacto a devolver al comprador una vez superado el peritaje.';
COMMENT ON COLUMN sale_return.customer_notes            IS 'Manifestación del cliente describiendo el motivo o falla declarada.';
COMMENT ON COLUMN sale_return.inspection_notes          IS 'Dictamen pericial del operador de control de calidad tras recibir y examinar la prenda.';
COMMENT ON COLUMN sale_return.inspection_evidence_path  IS 'Enlace al repositorio de imágenes que respaldan el dictamen (fundamental en rechazos por uso).';
COMMENT ON COLUMN sale_return.inspected_by              IS 'Identificador del operador/auditor que revisó físicamente la mercadería en taller.';
COMMENT ON COLUMN sale_return.inspected_at              IS 'Marca temporal exacta en que se concluyó la inspección de calidad.';
COMMENT ON COLUMN sale_return.closed_at                 IS 'Marca temporal UTC en que concluyó formalmente el expediente de devolución.';