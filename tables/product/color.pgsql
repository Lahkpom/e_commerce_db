CREATE TABLE color (
    color_id    BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    color_name  VARCHAR(50)     NOT NULL,
    color_desc  TEXT            NOT NULL,
    color_code  VARCHAR(7)      NOT NULL CHECK (color_code ~* '^#[A-Fa-f0-9]{6}$'),
    row_status  enum_row_status NOT NULL DEFAULT 'ACTIVE',
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NULL
);
-- ########################################################################################
-- Índices únicos parciales (excluyen los borrados lógicos)
CREATE UNIQUE INDEX uk_color_name_not_deleted 
    ON color (LOWER(color_name)) 
    WHERE row_status <> 'DELETED';

CREATE UNIQUE INDEX uk_color_code_not_deleted 
    ON color (UPPER(color_code)) 
    WHERE row_status <> 'DELETED';
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
    ('Negro'   , 'black'        , '#000000'),
    ('Rosa'    , 'pink'         , '#FFC0CB'),
    ('Beige'   , 'beige'        , '#F5F5DC'),
    ('Blanco'  , 'white'        , '#FFFFFF'),
    ('Fuxia'   , 'fuchsia'      , '#FF00FF'),
    ('Marrón'  , 'brown'        , '#A52A2A'),
    ('Camel'   , 'camel'        , '#C19A6B'),
    ('Azul'    , 'blue'         , '#0000FF'),
    ('Suela'   , 'saddlebrown'  , '#8B4513'),
    ('Verde'   , 'green'        , '#008000'),
    ('Amarillo', 'yellow'       , '#FFFF00'),
    ('Naranja' , 'orange'       , '#FFA500'),
    ('Violeta' , 'violet'       , '#EE82EE'),
    ('Lila'    , 'lilac'        , '#C8A2C8');