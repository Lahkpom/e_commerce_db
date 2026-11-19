CREATE TABLE shipping_zone (
    shipping_zone_id    BIGINT                  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipping_method     enum_shipping_method    NOT NULL UNIQUE,
    zone_name           VARCHAR(120)            NOT NULL,
    description         TEXT                    NULL,
    postal_codes        JSONB                   NOT NULL DEFAULT '[]'::jsonb,
    base_cost           DECIMAL(12, 2)          NOT NULL DEFAULT 0.00 CHECK (base_cost >= 0),
    estimated_days      VARCHAR(80)             NOT NULL,
    row_status          enum_row_status         NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NULL,
    updated_by          UUID                    NULL REFERENCES users(user_id) ON DELETE SET NULL
);
-- ########################################################################################
CREATE INDEX idx_shipping_zone_postal_codes ON shipping_zone USING GIN (postal_codes);
CREATE INDEX idx_shipping_zone_status      ON shipping_zone(row_status);
-- ########################################################################################
CREATE TRIGGER trg_shipping_zone_update
    BEFORE UPDATE ON shipping_zone
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE shipping_zone                       IS 'Zonas de envío, tarifas, plazos y códigos postales habilitados.';
COMMENT ON COLUMN shipping_zone.shipping_zone_id     IS 'Identificador único de la zona de envío.';
COMMENT ON COLUMN shipping_zone.shipping_method      IS 'Método de envío asociado a la zona.';
COMMENT ON COLUMN shipping_zone.zone_name            IS 'Nombre visible de la zona de envío.';
COMMENT ON COLUMN shipping_zone.description          IS 'Descripción adicional de las condiciones de envío de la zona.';
COMMENT ON COLUMN shipping_zone.postal_codes         IS 'Códigos postales argentinos de cuatro dígitos habilitados para la zona. Un arreglo vacío indica retiro o cobertura nacional por defecto.';
COMMENT ON COLUMN shipping_zone.base_cost            IS 'Costo base del envío en moneda local.';
COMMENT ON COLUMN shipping_zone.estimated_days       IS 'Plazo estimado de entrega o coordinación.';
COMMENT ON COLUMN shipping_zone.row_status           IS 'Estado lógico de la zona de envío.';
COMMENT ON COLUMN shipping_zone.created_at            IS 'Marca de tiempo UTC de creación del registro.';
COMMENT ON COLUMN shipping_zone.updated_at            IS 'Marca de tiempo UTC de la última modificación.';
COMMENT ON COLUMN shipping_zone.updated_by            IS 'Identificador del usuario o administrador que aplicó la última modificación.';
-- ########################################################################################
INSERT INTO shipping_zone (
    shipping_method,
    zone_name,
    description,
    postal_codes,
    base_cost,
    estimated_days
) VALUES
(
    'RETIRO_LLAVALLOL',
    'Retiro en Estación Llavallol',
    NULL,
    '[]'::jsonb,
    0.00,
    'En el día (a coordinar por WhatsApp)'
),
(
    'ENVIO_GBA_ZONA_SUR',
    'Envío a domicilio - GBA Zona Sur',
    NULL,
    '["1836", "1832", "1834", "1828", "1839", "1846", "1852", "1845", "1847", "1849", "1854", "1856", "1842", "1838", "1841", "1804", "1806", "1824", "1826", "1822", "1870", "1872", "1875", "1876", "1878", "1882", "1884", "1888"]'::jsonb,
    3000.00,
    '1 a 2 días hábiles'
),
(
    'ENVIO_GBA_GENERAL',
    'Envío a domicilio - CABA y GBA Norte/Oeste',
    NULL,
    (
        SELECT jsonb_agg(to_char(postal_code, 'FM0000') ORDER BY postal_code)
        FROM generate_series(1000, 1499) AS codes(postal_code)
    ) || '["1704", "1706", "1708", "1712", "1714", "1722", "1744", "1754", "1702", "1678", "1686", "1638", "1636", "1640", "1642", "1609", "1646", "1648", "1650", "1653", "1613", "1615", "1667", "1629", "1625"]'::jsonb,
    6000.00,
    '2 a 4 días hábiles'
),
(
    'ENVIO_CORREO_NACIONAL',
    'Envío Nacional por Correo',
    NULL,
    '[]'::jsonb,
    10000.00,
    '3 a 7 días hábiles'
);
