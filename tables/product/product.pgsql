CREATE TABLE product (
    product_id          UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    product_category    enum_category       NOT NULL,
    target_gender       enum_target_gender  NOT NULL,
    product_name        VARCHAR(255)        NOT NULL,
    product_short_desc  VARCHAR(255)        NOT NULL,
    product_long_desc   TEXT                NOT NULL,
    row_status          enum_row_status     NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NULL
);
-- ########################################################################################
CREATE UNIQUE INDEX uk_product_name_not_deleted 
    ON product (LOWER(product_name)) 
    WHERE row_status IN ('ACTIVE', 'INACTIVE');
-- ########################################################################################
CREATE INDEX idx_product_gender_status 
    ON product (target_gender, row_status)
    WHERE row_status IN ('ACTIVE', 'INACTIVE');
-- ########################################################################################
CREATE TRIGGER trg_product_update
    BEFORE UPDATE ON product
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE    product                     IS 'Catálogo de productos del ecommerce por categoría y género objetivo.';
COMMENT ON COLUMN   product.target_gender       IS 'Género al que apunta el producto (NINIAS, NINIOS, HOMBRES, MUJERES, UNISEX).';
COMMENT ON COLUMN   product.product_short_desc  IS 'Descripción breve para tarjetas del catálogo.';
COMMENT ON COLUMN   product.product_long_desc   IS 'Descripción completa para la vista de detalle del producto.';