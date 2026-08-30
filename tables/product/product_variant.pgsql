CREATE TABLE product_variant (
    variant_id          UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id          UUID                NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    color_id            INTEGER             NOT NULL REFERENCES color(color_id),
    size_id             INTEGER             NOT NULL REFERENCES size(size_id),
    target_gender       enum_target_gender  NOT NULL,
    variant_desc        VARCHAR(255)        NOT NULL,
    variant_sku         VARCHAR(100)        NOT NULL UNIQUE,
    variant_price       DECIMAL(10, 2)      NOT NULL CHECK (variant_price >= 0),
    variant_stock       INTEGER             NOT NULL DEFAULT 0 CHECK (variant_stock >= 0),
    row_status          enum_row_status     NOT NULL DEFAULT 'active',
    created_at          TIMESTAMP           NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP           NULL,

    CONSTRAINT uq_product_color_size UNIQUE (product_id, color_id, size_id)
);
-- ########################################################################################
CREATE INDEX idx_variant_product    ON product_variant(product_id);
CREATE INDEX idx_variant_color      ON product_variant(color_id);
CREATE INDEX idx_variant_size       ON product_variant(size_id);
-- ########################################################################################
CREATE TRIGGER trg_variant_update
    BEFORE UPDATE ON product_variant
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE product_variant                IS 'Variantes: combinación producto + talle + color';
COMMENT ON COLUMN product_variant.target_gender IS 'Indica a qué categoría corresponde el producto. (niños, niñas, mujeres, hombres)';
COMMENT ON COLUMN product_variant.variant_desc  IS 'Breve descripción particular de la variante a mostrar. Ideal indicar explisitamente la categoría para lectura del usuario';
COMMENT ON COLUMN product_variant.variant_price IS 'Precio al por menor para venta al público general';