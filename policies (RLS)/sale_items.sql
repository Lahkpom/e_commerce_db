-- Política para sale_items: inserción pública
CREATE POLICY "Public insert sale_items" ON sale_items
    FOR INSERT
    WITH CHECK (true);

-- Política para sale_items: lectura basada en acceso a la venta
CREATE POLICY "Read sale_items from accessible sales" ON sale_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sales s 
            WHERE s.id_sale = sale_items.id_sale 
            AND s.customer_email = current_setting('request.jwt.claims', true)::json->>'email'
        )
    );