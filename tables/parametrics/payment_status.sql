-- Tabla de estados de pago
CREATE TABLE payment_status (
    id_status SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Estados de pago
INSERT INTO payment_status (description) VALUES 
    ('pending'),
    ('approved'),
    ('rejected'),
    ('refunded');