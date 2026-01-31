-- Tabla de categorías de productos
CREATE TABLE categories (
    id_category     SERIAL PRIMARY KEY,
    description     VARCHAR(100)    NOT NULL UNIQUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- Categorías
INSERT INTO categories (description) VALUES 
    ('child'),
    ('man'),
    ('woman');