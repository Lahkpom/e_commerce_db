CREATE TABLE image (
    image_id        BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    variant_id      BIGINT          NOT NULL REFERENCES variant(variant_id) ON DELETE CASCADE,
    image_url       TEXT            NOT NULL,
    display_order   INTEGER         NOT NULL CHECK (display_order >= 0) DEFAULT 0,
    is_primary      BOOLEAN         NOT NULL DEFAULT FALSE,
    row_status      enum_row_status NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NULL
);
-- ########################################################################################
CREATE INDEX idx_image_variant ON image(variant_id);
-- Solo puede existir UNA imagen con is_primary = TRUE por cada variante entre las que estén activas/no borradas.
CREATE UNIQUE INDEX uq_image_variant_primary 
    ON image (variant_id) 
    WHERE is_primary = TRUE AND row_status <> 'DELETED';
-- Optimiza la lectura de la galería ordenada (portada primero, luego por orden secuencial)
CREATE INDEX idx_image_variant_display 
    ON image (variant_id, display_order ASC) 
    WHERE row_status <> 'DELETED';
-- ########################################################################################
CREATE TRIGGER trg_image_updated_at
    BEFORE UPDATE ON image
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE image                 IS 'Imágenes pertenecientes a cada variante de producto.';
COMMENT ON COLUMN image.variant_id     IS 'Variante a la cual pertenece la fotografía.';
COMMENT ON COLUMN image.image_url      IS 'URL pública alojada en el bucket de almacenamiento (Supabase Storage).';
COMMENT ON COLUMN image.display_order  IS 'Posición relativa para ordenar la galería en el front.';
COMMENT ON COLUMN image.is_primary     IS 'Indica si es la portada principal de la variante. Máximo una activa por variante.';