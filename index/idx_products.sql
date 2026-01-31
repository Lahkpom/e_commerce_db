-- Índices en products
CREATE INDEX idx_products_category ON products(id_category);
CREATE INDEX idx_products_status ON products(id_status);
CREATE INDEX idx_products_sku ON products(sku);