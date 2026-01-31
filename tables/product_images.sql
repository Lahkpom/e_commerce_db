-- Tabla de imágenes de productos
CREATE TABLE product_images (
    id_image UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_product UUID NOT NULL REFERENCES products(id_product) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    order_position INTEGER NOT NULL CHECK (order_position > 0),
    id_status INTEGER NOT NULL REFERENCES image_status(id_status),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_product_order UNIQUE (id_product, order_position)
);

COMMENT ON TABLE product_images IS 'Imágenes de productos (múltiples por producto)';
COMMENT ON COLUMN product_images.order_position IS 'Orden de visualización (1 = imagen principal)';