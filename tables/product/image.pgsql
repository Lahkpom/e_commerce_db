CREATE TABLE image (
    image_id    BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    variant_id  BIGINT          NOT NULL REFERENCES variant(variant_id) ON DELETE CASCADE,
    image_url   TEXT            NOT NULL,
    image_order INTEGER         NOT NULL CHECK (image_order > 0),
    row_status  enum_row_status NOT NULL DEFAULT 'active',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NULL,

    CONSTRAINT uq_variant_order UNIQUE (variant_id, image_order)
);
-- ########################################################################################
CREATE INDEX idx_variant_image_variant ON image(variant_id);
-- ########################################################################################
CREATE TRIGGER trg_variant_image_update
    BEFORE UPDATE ON image
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE image              IS 'Imágenes de cada variante';
COMMENT ON COLUMN image.image_url   IS 'Almacenadas en el bucket de supabase.';
COMMENT ON COLUMN image.image_order IS 'Orden de importancia de las fotos. Es el orden en que se van a mostrar en el carousel de cada variante. La que posea el orden nro 1 será la imagen principal a mostrar como portada del producto.';