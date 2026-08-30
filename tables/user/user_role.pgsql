CREATE TABLE user_role (
    role_id     SERIAL          PRIMARY KEY,
    role_name   VARCHAR(50)     NOT NULL UNIQUE,
    role_desc   TEXT            NOT NULL,
    row_status  enum_row_status NOT NULL DEFAULT 'active',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NULL
);
-- ########################################################################################
CREATE TRIGGER trg_user_role_update
    BEFORE UPDATE ON user_role
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE user_role              IS 'Roles de usuario para control de acceso';
COMMENT ON COLUMN user_role.role_name   IS 'Nombre único del rol (customer, wholesaler, admin, superadmin)';
COMMENT ON COLUMN user_role.role_desc   IS 'Descripción detallada de permisos y capacidades del rol';
-- ########################################################################################
INSERT INTO user_role (role_name, role_desc) VALUES
    ('superadmin'   , 'Super administrador con acceso total al sistema. Puede crear otros admins y gestionar todos los aspectos del ecommerce.'),
    ('admin'        , 'Administrador que puede gestionar productos, ventas y crear usuarios mayoristas. Solo puede ser creado por superadmins.'),
    ('wholesaler'   , 'Cliente mayorista con descuentos especiales. Solo puede ser creado por admins.'),
    ('customer'     , 'Cliente regular que puede comprar productos y ver su historial de compras.');