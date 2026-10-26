CREATE TABLE sale_item (
    sale_item_id    BIGINT              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id         UUID                NOT NULL REFERENCES sale(sale_id) ON DELETE CASCADE,
    variant_id      BIGINT              NULL REFERENCES variant(variant_id) ON DELETE SET NULL,
    
    -- Snapshot completo del producto vendido
    product_name    VARCHAR(255)        NOT NULL,
    product_desc    VARCHAR(255)        NOT NULL,
    variant_desc    VARCHAR(255)        NOT NULL,
    variant_sku     VARCHAR(100)        NOT NULL,
    variant_size    enum_numeric_size   NOT NULL,
    color_name      VARCHAR(100)        NOT NULL,
    image_url       TEXT                NOT NULL,
    
    -- Valores económicos
    unit_price      DECIMAL(12, 2)      NOT NULL CHECK (unit_price > 0),
    quantity        INTEGER             NOT NULL CHECK (quantity > 0),
    subtotal        DECIMAL(12, 2)      NOT NULL CHECK (subtotal = (unit_price * quantity) AND subtotal > 0),
    
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);
-- ########################################################################################
CREATE INDEX idx_sale_item_sale        ON sale_item(sale_id);
CREATE INDEX idx_sale_item_variant     ON sale_item(variant_id);
-- ########################################################################################
COMMENT ON TABLE sale_item                  IS 'Detalle de renglones de la compra con copia histórica inmutable del catálogo.';
COMMENT ON COLUMN sale_item.sale_id         IS 'Referencia a la cabecera de la venta. Si la cabecera se borra, sus ítems caen en cascada.';
COMMENT ON COLUMN sale_item.variant_id      IS 'Referencia a la variante viva del catálogo. Pasa a NULL si la variante es eliminada para preservar el renglón.';
COMMENT ON COLUMN sale_item.unit_price      IS 'Precio unitario final de venta acordado para esta variante.';
COMMENT ON COLUMN sale_item.quantity        IS 'Cantidad de unidades adquiridas de este ítem (mínimo 1).';
COMMENT ON COLUMN sale_item.subtotal        IS 'Monto resultante de multiplicar unit_price por quantity. Validado por restricción CHECK.';