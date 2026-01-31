-- Tabla de items de venta
CREATE TABLE sale_items (
    id_sale_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sale UUID NOT NULL REFERENCES sales(id_sale) ON DELETE CASCADE,
    id_product UUID NOT NULL REFERENCES products(id_product),
    product_name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sale_items IS 'Items individuales de cada venta (snapshot de productos al momento de venta)';
COMMENT ON COLUMN sale_items.product_name IS 'Nombre del producto al momento de la venta (snapshot)';
COMMENT ON COLUMN sale_items.unit_price IS 'Precio unitario al momento de la venta (snapshot)';