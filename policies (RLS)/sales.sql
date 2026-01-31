-- Política para sales: inserción pública (crear órdenes)
CREATE POLICY "Public insert sales" ON sales
    FOR INSERT
    WITH CHECK (true);

-- Política para sales: lectura solo por email (el cliente puede ver sus propias órdenes)
CREATE POLICY "Read own sales" ON sales
    FOR SELECT
    USING (customer_email = current_setting('request.jwt.claims', true)::json->>'email');