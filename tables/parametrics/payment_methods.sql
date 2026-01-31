-- Tabla de métodos de pago
CREATE TABLE payment_methods (
    id_method SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_payment_method_status CHECK (status IN ('active', 'inactive'))
);

-- Métodos de pago
INSERT INTO payment_methods (description) VALUES 
    ('mercadopago'),
    ('transferencia'),
    ('efectivo');