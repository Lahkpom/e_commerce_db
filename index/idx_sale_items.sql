-- Índices en sale_items
CREATE INDEX idx_sale_items_sale ON sale_items(id_sale);
CREATE INDEX idx_sale_items_product ON sale_items(id_product);