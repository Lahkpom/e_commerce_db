-- Tabla de estados de imágenes
CREATE TABLE image_status (
    id_status SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Estados de imágenes
INSERT INTO image_status (description) VALUES 
    ('active'),
    ('inactive'),
    ('deleted');