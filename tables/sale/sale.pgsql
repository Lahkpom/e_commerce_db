CREATE TABLE sale (
    sale_id             UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID                NULL REFERENCES users(user_id) ON DELETE SET NULL,
    customer_name       VARCHAR(255)        NOT NULL,
    customer_email      VARCHAR(255)        NOT NULL,
    customer_phone      VARCHAR(50)         NOT NULL,
    shipping_address    TEXT                NOT NULL,
    shipping_cost       DECIMAL(10, 2)      NOT NULL DEFAULT 0 CHECK (shipping_cost >= 0),
    sale_shipped_date   TIMESTAMP           NULL,
    sale_notes          TEXT                NOT NULL DEFAULT '',
    sale_quantity       INTEGER             NOT NULL CHECK (sale_quantity > 0),
    sale_discounts      DECIMAL(2, 2)       NOT NULL CHECK (sale_discounts >= 0),
    sale_subtotal       DECIMAL(10, 2)      NOT NULL CHECK (sale_subtotal > 0),
    sale_total          DECIMAL(10, 2)      NOT NULL CHECK (sale_total > 0),
    sale_status         enum_sale_status    NOT NULL DEFAULT 'pendiente',
    payment_method      enum_payment_method NOT NULL,
    payment_status      enum_payment_status NOT NULL DEFAULT 'pendiente',
    mp_payment_id       VARCHAR(100)        NULL,
    mp_preference_id    VARCHAR(100)        NULL,
    created_at          TIMESTAMP           NOT NULL DEFAULT NOW(),
    created_by          UUID                NULL REFERENCES users(user_id) ON DELETE SET NULL,
    updated_at          TIMESTAMP           NULL,
    updated_by          UUID                NULL REFERENCES users(user_id) ON DELETE SET NULL,
);
-- ########################################################################################
CREATE INDEX idx_sale_user ON sale(user_id);
-- ########################################################################################
CREATE TRIGGER trg_sale_update
    BEFORE UPDATE ON sale
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
-- Función para reducir stock
CREATE OR REPLACE FUNCTION reduce_variant_stock()
RETURNS TRIGGER 
SET search_path = public
AS $$
BEGIN
    -- Solo reducir stock cuando el pago cambia a 'approved'
    IF 
        NEW.payment_status       = 'aprobado'
        AND OLD.payment_status   IN ('pendiente', 'rechazado')
    THEN
        UPDATE 
            product_variant pv
        SET 
            variant_stock = variant_stock - si.quantity
        FROM 
            sale_item si
        WHERE 
            si.sale_id          = NEW.sale_id
            AND si.variant_id   = pv.variant_id;
    END IF;

    NEW.updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- ----------------------------------------------------------------------------------------
CREATE TRIGGER trg_reduce_variant_stock
    AFTER UPDATE ON sale
    FOR EACH ROW
    EXECUTE FUNCTION reduce_variant_stock();
-- ########################################################################################
COMMENT ON TABLE sale                       IS 'Historial de órdenes de compra';
COMMENT ON COLUMN sale.user_id              IS 'Usuario que realizó la compra. Si no se logea queda en null y pasa a ser el customer_email el dato de ancla. En caso que un usuario logeado lo haya creado y en un futuro este se elimine, queda la columna en null, persistiendo en la tabla todos los datos customer_*';
COMMENT ON COLUMN sale.sale_quantity        IS 'Cantidad de productos en total que posee la compra';
COMMENT ON COLUMN sale.sale_discounts       IS 'Porcentaje de descuento aplicado, si corresponde';
COMMENT ON COLUMN sale.sale_subtotal        IS 'Valor de la suma bruta de todos los productos que se hallan en la orden de compra';
COMMENT ON COLUMN sale.sale_total           IS 'Valor final después de restar descuentos y sumar envíos';
COMMENT ON COLUMN sale.sale_shipped_date    IS 'Fecha de entrega del producto';
COMMENT ON COLUMN sale.mp_payment_id        IS 'Dato que viene de MP al realizar el pago';
COMMENT ON COLUMN sale.mp_preference_id     IS 'Dato que viene de MP al realizar el pago';