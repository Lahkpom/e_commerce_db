CREATE TABLE variant (
    variant_id          UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id          UUID                NOT NULL REFERENCES product(product_id),
    color_id            INTEGER             NOT NULL REFERENCES color(color_id),
    variant_size        enum_numeric_size   NOT NULL,
    target_gender       enum_target_gender  NOT NULL,
    variant_desc        VARCHAR(255)        NOT NULL,
    variant_sku         VARCHAR(100)        NOT NULL,
    variant_price       DECIMAL(10, 2)      NOT NULL CHECK (variant_price >= 0),
    variant_stock       INTEGER             NOT NULL DEFAULT 0 CHECK (variant_stock >= 0),
    row_status          enum_row_status     NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NULL
);
-- ########################################################################################
CREATE UNIQUE INDEX uk_product_color_size_not_deleted 
    ON variant (product_id, color_id, variant_size) 
    WHERE row_status <> 'DELETED';

CREATE UNIQUE INDEX uk_variant_sku_not_deleted 
    ON variant (LOWER(variant_sku)) 
    WHERE row_status <> 'DELETED';
-- ########################################################################################
CREATE INDEX idx_variant_product    ON variant(product_id);
CREATE INDEX idx_variant_color      ON variant(color_id);
-- ########################################################################################
CREATE TRIGGER trg_variant_update
    BEFORE UPDATE ON variant
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE variant                IS 'Variantes: combinación producto + talle + color';
COMMENT ON COLUMN variant.target_gender IS 'Indica a qué categoría corresponde el producto. (niños, niñas, mujeres, hombres)';
COMMENT ON COLUMN variant.variant_desc  IS 'Breve descripción particular de la variante a mostrar. Ideal indicar explisitamente la categoría para lectura del usuario';
COMMENT ON COLUMN variant.variant_price IS 'Precio al por menor para venta al público general';