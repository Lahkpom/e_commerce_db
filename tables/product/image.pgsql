CREATE TABLE image (
    image_id        BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id      UUID        NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    color_id        BIGINT      NOT NULL REFERENCES color(color_id),
    image_url       TEXT        NOT NULL,
    is_primary      BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NULL
);
-- ########################################################################################
-- Búsqueda rápida de galería por producto y color
CREATE INDEX idx_image_product_color 
    ON image (product_id, color_id, is_primary DESC, created_at ASC);
-- ########################################################################################
-- Solo UNA imagen principal (is_primary = TRUE) por cada combinación Producto + Color
CREATE UNIQUE INDEX uq_image_product_color_primary 
    ON image (product_id, color_id) 
    WHERE is_primary = TRUE;
-- ########################################################################################
CREATE TRIGGER trg_image_updated_at
    BEFORE UPDATE ON image
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE    image               IS 'Imágenes compartidas por todos los talles de un mismo producto y color.';
COMMENT ON COLUMN   image.product_id    IS 'Producto al que pertenece la galería.';
COMMENT ON COLUMN   image.color_id      IS 'Color específico del producto al que corresponden las fotografías.';
COMMENT ON COLUMN   image.is_primary    IS 'Portada principal del color en el catálogo. Máximo una por producto y color.';