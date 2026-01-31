-- Tabla de estados de ventas
CREATE TABLE sale_status (
    id_status SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Estados de ventas
INSERT INTO sale_status (description) VALUES 
    ('pending'),
    ('preparing'),
    ('shipped'),
    ('delivered'),
    ('cancelled');