-- Política para product_images: lectura pública de imágenes activas
CREATE POLICY "Public read active images" ON product_images
    FOR SELECT
    USING (id_status = (SELECT id_status FROM image_status WHERE description = 'active'));