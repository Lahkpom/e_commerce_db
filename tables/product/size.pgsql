CREATE TABLE size (
    size_id     SERIAL          PRIMARY KEY,
    size        VARCHAR(10)     NOT NULL UNIQUE,
    size_desc   TEXT            NULL,
    size_order  INTEGER         NOT NULL DEFAULT 0,
    row_status  enum_row_status NOT NULL DEFAULT 'active',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NULL
);
-- ########################################################################################
CREATE TRIGGER trg_sizes_updated_at
    BEFORE UPDATE ON size
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE size               IS 'Tabla para almacenar los talles, diferenciado por tipo de cqategoría';
COMMENT ON COLUMN size.size         IS 'Puede ser tanto en números como en letras';
COMMENT ON COLUMN size.size_desc    IS 'Ideal que se aclare las medidas destalladas de la homra';
COMMENT ON COLUMN size.size_order   IS 'Para siempre poder indicar del talle mas chico al mas grande';
