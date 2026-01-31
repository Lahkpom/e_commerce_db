-- Tabla de productos
CREATE TABLE products (
    id_product UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_product VARCHAR(255) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    id_category INTEGER NOT NULL REFERENCES categories(id_category),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    sku VARCHAR(100) NOT NULL UNIQUE,
    id_status INTEGER NOT NULL REFERENCES product_status(id_status),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NULL,
    CONSTRAINT chk_price_positive CHECK (price >= 0)
);

COMMENT ON TABLE products IS 'Catálogo de productos del ecommerce';
COMMENT ON COLUMN products.sku IS 'Código único de producto (Stock Keeping Unit)';
COMMENT ON COLUMN products.stock IS 'Cantidad disponible en inventario';