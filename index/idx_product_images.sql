-- Índices en product_images
CREATE INDEX idx_product_images_product ON product_images(id_product);
CREATE INDEX idx_product_images_status ON product_images(id_status);