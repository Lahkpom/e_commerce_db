CREATE TABLE sale (
    sale_id                 UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID                NULL REFERENCES users(user_id) ON DELETE SET NULL,
    tracking_token          UUID                NOT NULL DEFAULT gen_random_uuid(),
    
    -- Snapshot de contacto y entrega (inmutables tras la compra)
    customer_name           VARCHAR(255)        NOT NULL,
    customer_email          VARCHAR(255)        NOT NULL,
    customer_phone          VARCHAR(50)         NOT NULL,
    customer_tax_id_type    tax_id_type         NULL,
    customer_tax_id_number  VARCHAR(20)         NULL,
    customer_notes          TEXT                NULL,
    shipping_address        TEXT                NOT NULL,
    
    -- Totales financieros (moneda congelada)
    sale_quantity           INTEGER             NOT NULL CHECK (sale_quantity > 0),
    sale_subtotal           DECIMAL(12, 2)      NOT NULL CHECK (sale_subtotal > 0),
    sale_discount_amount    DECIMAL(12, 2)      NOT NULL DEFAULT 0.00 CHECK (sale_discount_amount >= 0),
    shipping_cost           DECIMAL(12, 2)      NOT NULL DEFAULT 0.00 CHECK (shipping_cost >= 0),
    sale_total              DECIMAL(12, 2)      NOT NULL CHECK (sale_total = (sale_subtotal - sale_discount_amount + shipping_cost) AND sale_total > 0),
    
    -- Fechas de logística
    sale_shipped_at         TIMESTAMPTZ         NULL,
    sale_delivered_at       TIMESTAMPTZ         NULL,
    
    -- Máquina de estados
    sale_status             enum_sale_status    NOT NULL DEFAULT 'PENDIENTE',
    payment_method          enum_payment_method NOT NULL,
    payment_status          enum_payment_status NOT NULL DEFAULT 'PENDIENTE',
    fiscal_rejection        BOOLEAN             NOT NULL DEFAULT FALSE,
    internal_notes          TEXT                NULL,
    
    -- Trazabilidad de pasarela de pago (Mercado Pago / Gateway)
    mp_payment_id           VARCHAR(100)        NULL,
    mp_preference_id        VARCHAR(100)        NULL,
    mp_merchant_order_id    VARCHAR(100)        NULL,
    
    -- Auditoría técnica
    created_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NULL,
    updated_by              UUID                NULL REFERENCES users(user_id) ON DELETE SET NULL
);
-- ########################################################################################
CREATE INDEX idx_sale_user              ON sale(user_id);
CREATE INDEX idx_sale_customer_email    ON sale(LOWER(customer_email));
CREATE INDEX idx_sale_customer_tax_id   ON sale (customer_tax_id_number);
CREATE INDEX idx_sale_status            ON sale(sale_status);
CREATE INDEX idx_sale_payment_status    ON sale(payment_status);
CREATE INDEX idx_sale_created_at        ON sale(created_at DESC);
CREATE INDEX idx_sale_mp_payment        ON sale(mp_payment_id)      WHERE mp_payment_id IS NOT NULL;
CREATE INDEX idx_sale_fiscal_rejection  ON sale(fiscal_rejection)   WHERE fiscal_rejection = TRUE;

CREATE UNIQUE INDEX uq_sale_tracking_token ON sale(tracking_token);
-- ########################################################################################
CREATE TRIGGER trg_sale_update
    BEFORE UPDATE ON sale
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE sale                       IS 'Cabecera consolidada de órdenes de compra con snapshot financiero y logístico.';
COMMENT ON COLUMN sale.user_id              IS 'Usuario registrado propietario de la orden. Queda en NULL si la compra fue como invitado.';
COMMENT ON COLUMN sale.tracking_token       IS 'Token criptográfico único utilizado para el acceso público seguro (magic link) al estado del pedido sin autenticación.';
COMMENT ON COLUMN sale.shipping_address     IS 'Dirección completa y normalizada de entrega (calle, número, piso, localidad, CP).';
COMMENT ON COLUMN sale.customer_notes       IS 'Observaciones o aclaraciones cargadas directamente por el cliente durante el checkout.';
COMMENT ON COLUMN sale.internal_notes       IS 'Anotaciones operativas y de seguimiento exclusivas para uso administrativo del personal de la tienda.';
COMMENT ON COLUMN sale.sale_quantity        IS 'Cantidad total acumulada de unidades de producto que contiene la compra.';
COMMENT ON COLUMN sale.sale_subtotal        IS 'Monto acumulado bruto en moneda local (suma de los subtotales de sale_item).';
COMMENT ON COLUMN sale.sale_discount_amount IS 'Descuento total deducido a la compra expresado en valor monetario fijo (no en porcentaje).';
COMMENT ON COLUMN sale.shipping_cost        IS 'Costo de envío cotizado y aplicado a la transacción.';
COMMENT ON COLUMN sale.sale_total           IS 'Monto final a cobrar tras aplicar descuentos fijos y cargos de envío. Validado por restricción CHECK.';
COMMENT ON COLUMN sale.sale_shipped_at      IS 'Marca de tiempo UTC en que la orden fue despachada y entregada al servicio de correo/logística.';
COMMENT ON COLUMN sale.sale_delivered_at    IS 'Marca de tiempo UTC en que la orden fue confirmada como recibida por el cliente.';
COMMENT ON COLUMN sale.sale_status          IS 'Estado del ciclo de vida operativo del pedido (PENDIENTE, PREPARACION, ENVIADO, ENTREGADO, CANCELADO, REEMBOLSADO).';
COMMENT ON COLUMN sale.payment_method       IS 'Medio seleccionado por el cliente para el abono (MERCADO_PAGO, TRANSFERENCIA, EFECTIVO).';
COMMENT ON COLUMN sale.payment_status       IS 'Estado de la liquidación del cobro (PENDIENTE, APROBADO, RECHAZADO, REEMBOLSADO).';
COMMENT ON COLUMN sale.fiscal_rejection     IS 'Tiene la finalidad de indicar cuando un intento de emisión de fatura fue rechazado por ARCA debido a inconsistencias en los datos..';
COMMENT ON COLUMN sale.mp_payment_id        IS 'Identificador de la transacción de pago retornado por la API de Mercado Pago.';
COMMENT ON COLUMN sale.mp_preference_id     IS 'Identificador del checkout preference creado para el cobro en Mercado Pago.';
COMMENT ON COLUMN sale.mp_merchant_order_id IS 'Identificador de orden comercial retornado por las notificaciones Webhook de Mercado Pago.';
COMMENT ON COLUMN sale.updated_by           IS 'Identificador del usuario o administrador que aplicó la última modificación manual.';