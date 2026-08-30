CREATE TABLE product (
    product_id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    product_category    enum_category   NOT NULL,
    product_name        VARCHAR(255)    NOT NULL UNIQUE,
    product_short_desc  VARCHAR(255)    NOT NULL,
    product_long_desc   TEXT            NOT NULL,
    row_status          enum_row_status NOT NULL DEFAULT 'active',
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP       NULL
);
-- ########################################################################################
CREATE TRIGGER trg_product_update
    BEFORE UPDATE ON product
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE product IS 'Catálogo de productos del ecommerce, sin tener en cuenta las variantes que pueda tener cada producto en cuanto a categoría, color y talle';
COMMENT ON TABLE product.product_short_desc IS 'Descripción para mostrar en el catalogo junto con otros productos';
COMMENT ON TABLE product.product_long_desc IS 'Descripción para mostrar dentro de la información detallada de este producto en partiular';