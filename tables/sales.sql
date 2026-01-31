-- Tabla de ventas
CREATE TABLE sales (
    id_sale UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
    date_completed TIMESTAMP NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NULL,
    customer_phone VARCHAR(50) NOT NULL,
    shipping_address TEXT NOT NULL,
    order_notes TEXT NOT NULL DEFAULT '',
    id_sale_status INTEGER NOT NULL REFERENCES sale_status(id_status),
    id_payment_method INTEGER NOT NULL REFERENCES payment_methods(id_method),
    id_payment_status INTEGER NOT NULL REFERENCES payment_status(id_status),
    mp_payment_id VARCHAR(100) NULL,
    mp_preference_id VARCHAR(100) NULL,
    shipping_cost DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (shipping_cost >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NULL
);

COMMENT ON TABLE sales IS 'Registro de ventas/órdenes de compra';
COMMENT ON COLUMN sales.mp_payment_id IS 'ID de transacción de Mercado Pago';
COMMENT ON COLUMN sales.mp_preference_id IS 'ID de preferencia de Mercado Pago';