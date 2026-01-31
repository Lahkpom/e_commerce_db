-- Índices en sales
CREATE INDEX idx_sales_status ON sales(id_sale_status);
CREATE INDEX idx_sales_payment_status ON sales(id_payment_status);
CREATE INDEX idx_sales_payment_method ON sales(id_payment_method);
CREATE INDEX idx_sales_created_at ON sales(created_at DESC);
CREATE INDEX idx_sales_customer_email ON sales(customer_email);
CREATE INDEX idx_sales_mp_payment_id ON sales(mp_payment_id);