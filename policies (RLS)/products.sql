-- Política para products: lectura pública de productos activos
CREATE POLICY "Public read active products" ON products
    FOR SELECT
    USING (id_status = (SELECT id_status FROM product_status WHERE description = 'active'));