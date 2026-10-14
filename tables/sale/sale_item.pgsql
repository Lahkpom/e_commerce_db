CREATE TABLE sale_item (
    sale_item_id            UUID            PRIMARY KEY DEFAULT gen_random_uuid(), -- Tendría  que ser un BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY??
    sale_id                 UUID            NOT NULL REFERENCES sale(sale_id) ON DELETE CASCADE,
    variant_id              UUID            NOT NULL REFERENCES variant(variant_id) ON DELETE SET NULL,
    variant_desc            VARCHAR(255)    NOT NULL,
    product_name            VARCHAR(255)    NOT NULL,
    sale_item_sku           VARCHAR(100)    NOT NULL,
    sale_item_unit_price    DECIMAL(10, 2)  NOT NULL CHECK (sale_item_unit_price > 0),
    sale_item_quantity      INTEGER         NOT NULL CHECK (sale_item_quantity > 0),
    sale_item_subtotal      DECIMAL(10, 2)  NOT NULL CHECK (sale_item_subtotal = sale_item_unit_price * sale_item_quantity AND sale_item_subtotal > 0),
    created_at              TIMESTAMP       NOT NULL DEFAULT NOW()
);
-- ########################################################################################
CREATE INDEX idx_sale_item_sale        ON sale_item(sale_id);
CREATE INDEX idx_sale_item_variant     ON sale_item(variant_id);
-- ########################################################################################
-- Función para verificar stock
CREATE OR REPLACE FUNCTION check_variant_stock()
RETURNS TRIGGER 
SET search_path = public
AS $$
DECLARE
    available_stock INTEGER;
    variant_info VARCHAR;
BEGIN
    SELECT variant_stock, sale_item_sku INTO available_stock, variant_info
    FROM variant
    WHERE variant_id = NEW.variant_id;
    
    IF available_stock < NEW.sale_item_quantity THEN
        RAISE EXCEPTION 'Stock insuficiente para variante %. Disponible: %, Solicitado: %', 
            variant_info, available_stock, NEW.sale_item_quantity;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- ----------------------------------------------------------------------------------------
CREATE TRIGGER trg_check_variant_stock
    BEFORE INSERT ON sale_item
    FOR EACH ROW
    EXECUTE FUNCTION check_variant_stock();
-- ########################################################################################
COMMENT ON TABLE sale_item IS 'Items de cada venta (snapshot)';