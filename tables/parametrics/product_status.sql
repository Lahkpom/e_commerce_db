-- Tabla de estados de productos
CREATE TABLE product_status (
    id_status SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Estados de productos
INSERT INTO product_status (description) VALUES 
    ('active'),
    ('inactive'),
    ('deleted');