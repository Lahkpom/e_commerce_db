CREATE TABLE color (
    color_id    SERIAL          PRIMARY KEY,
    color_name  VARCHAR(50)     NOT NULL UNIQUE,
    color_desc  TEXT            NOT NULL UNIQUE,
    color_code  VARCHAR(7)      NOT NULL UNIQUE CHECK (color_code ~* '^#[A-Fa-f0-9]{6}$')
    row_status  enum_row_status NOT NULL DEFAULT 'active',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NULL
);
-- ########################################################################################
CREATE TRIGGER trg_color_update
    BEFORE UPDATE ON color
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE color               IS 'Tabla para almacenar los colores en código HEX';
COMMENT ON COLUMN color.color_name   IS 'Nombre del color';
COMMENT ON COLUMN color.color_desc   IS 'Si quiere agregar alguna descripción llamativa';
COMMENT ON COLUMN color.color_code   IS 'El color_code se debe guardar en hexadecimal y en mayúsculas. Solo puede ser en su versión de 6 caracteres';
-- ########################################################################################
INSERT INTO color (color_name, color_desc, color_code) VALUES 
    ('black'        , 'Negro'   , '#000000'),
    ('pink'         , 'Rosa'    , '#FFC0CB'),
    ('beige'        , 'Beige'   , '#F5F5DC'),
    ('white'        , 'Blanco'  , '#FFFFFF'),
    ('fuchsia'      , 'Fuxia'   , '#FF00FF'),
    ('brown'        , 'Marrón'  , '#A52A2A'),
    ('camel'        , 'Camel'   , '#C19A6B'),
    ('blue'         , 'Azul'    , '#0000FF'),
    ('saddlebrown'  , 'Suela'   , '#8B4513'),
    ('green'        , 'Verde'   , '#008000'),
    ('yellow'       , 'Amarillo', '#FFFF00'),
    ('orange'       , 'Naranja' , '#FFA500'),
    ('violet'       , 'Violeta' , '#EE82EE'),
    ('lilac'        , 'Lila'    , '#C8A2C8');