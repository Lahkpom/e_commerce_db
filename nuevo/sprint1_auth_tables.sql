-- ============================================================================
-- SPRINT 1: AUTH - TABLAS DE ROLES Y USER_PROFILES
-- ============================================================================
-- Ejecutar DESPUÉS del script principal de la base de datos
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TABLA DE ROLES
-- ----------------------------------------------------------------------------

CREATE TABLE roles (
    id_role     SERIAL      PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT        NOT NULL,
    cod_status  VARCHAR(2)  NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL
);

CREATE TABLE user_profiles (
    id              UUID            PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name       VARCHAR(255)    NOT NULL,
    phone           VARCHAR(50)     NULL,
    company_name    VARCHAR(255)    NULL,  -- Solo para mayoristas
    id_role         INTEGER         NOT NULL REFERENCES roles(id_role) DEFAULT 1, -- Default: customer
    cod_status      VARCHAR(2)      NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NULL
);













-- Índices
CREATE INDEX idx_roles_status ON roles(cod_status);

CREATE INDEX idx_user_profiles_role     ON user_profiles(id_role);
CREATE INDEX idx_user_profiles_status   ON user_profiles(cod_status);

CREATE INDEX idx_sales_user ON sales(id_user);









-- Trigger para updated_at
CREATE TRIGGER trg_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger que se ejecuta cuando se crea un user en auth.users
CREATE TRIGGER trg_create_user_profile
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_user_profile();









-- Insertar roles iniciales
INSERT INTO roles (name, description) VALUES
    ('customer'     , 'Cliente regular que puede comprar productos y ver su historial de compras.'),
    ('wholesaler'   , 'Cliente mayorista con descuentos especiales. Solo puede ser creado por admins.'),
    ('admin'        , 'Administrador que puede gestionar productos, ventas y crear usuarios mayoristas. Solo puede ser creado por superadmins.'),
    ('superadmin'   , 'Super administrador con acceso total al sistema. Puede crear otros admins y gestionar todos los aspectos del ecommerce.');












-- Comentarios
COMMENT ON TABLE roles              IS 'Roles de usuario para control de acceso';
COMMENT ON COLUMN roles.name        IS 'Nombre único del rol (customer, wholesaler, admin, superadmin)';
COMMENT ON COLUMN roles.description IS 'Descripción detallada de permisos y capacidades del rol';

COMMENT ON TABLE user_profiles                  IS 'Perfiles de usuario extendidos vinculados a auth.users';
COMMENT ON COLUMN user_profiles.id              IS 'FK a auth.users.id (mismo UUID)';
COMMENT ON COLUMN user_profiles.company_name    IS 'Nombre de empresa (solo para mayoristas)';
COMMENT ON COLUMN user_profiles.id_role         IS 'Rol del usuario (customer, wholesaler, admin, superadmin)';

COMMENT ON FUNCTION create_user_profile() IS 'Auto-crea user_profile cuando se registra un nuevo usuario en auth.users';

COMMENT ON POLICY "Public read roles" ON roles IS 'Cualquiera puede leer roles activos';

COMMENT ON POLICY "Users can view own profile"      ON user_profiles IS 'Usuarios ven su propio perfil';
COMMENT ON POLICY "Users can update own profile"    ON user_profiles IS 'Usuarios editan su perfil (excepto rol)';
COMMENT ON POLICY "Admins can view all profiles"    ON user_profiles IS 'Admins y superadmins ven todos los perfiles';

COMMENT ON COLUMN sales.id_user IS 'Usuario que realizó la compra (NULL si no creo una cuenta)';

COMMENT ON VIEW v_users_with_roles IS 'Vista de usuarios con información completa para panel admin';






CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name, phone, id_role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'phone', NULL),
        1  -- Default: customer
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;








ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;





-- Todos pueden leer roles (necesario para el frontend mostrar opciones)
-- Solo tú (via Supabase dashboard) puedes modificar roles
-- Nadie desde la app puede INSERT/UPDATE/DELETE roles
CREATE POLICY "Public read roles"
    ON roles
    FOR SELECT
    USING (cod_status = 'A');

-- Los usuarios pueden leer su propio perfil
CREATE POLICY "Users can view own profile"
    ON user_profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Los usuarios pueden actualizar su propio perfil (nombre, teléfono)
-- pero NO pueden cambiar su rol
CREATE POLICY "Users can update own profile"
    ON user_profiles
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (
        auth.uid() = id
        AND id_role = (
            SELECT id_role 
            FROM user_profiles 
            WHERE id = auth.uid()
        )  -- No puede cambiar su rol
    );

-- Los admins pueden ver todos los perfiles
CREATE POLICY "Admins can view all profiles"
    ON user_profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 
            FROM user_profiles up
                JOIN roles r 
                    ON up.id_role = r.id_role
            WHERE 
                up.id = auth.uid()
                AND r.name IN ('admin', 'superadmin')
        )
    );
-- Solo superadmins pueden crear admins
-- Esta política se aplicará cuando implementes la Edge Function para crear users

-- Los usuarios pueden ver:
-- 1. Sus propias compras (id_user = auth.uid())
-- 2. Compras anónimas con su email (customer_email = su email en auth.users)
CREATE POLICY "Users can view own sales"
    ON sales
    FOR SELECT
    USING (
        id_user = auth.uid()  -- Compras loggeadas
        OR customer_email = (
            SELECT email 
            FROM auth.users 
            WHERE id = auth.uid()
        )  -- Compras anónimas con mismo email
    );

-- Admins pueden ver todas las ventas
CREATE POLICY "Admins can view all sales"
    ON sales
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 
            FROM user_profiles up
                JOIN roles r 
                    ON up.id_role = r.id_role
            WHERE 
                up.id = auth.uid()
                AND r.name IN ('admin', 'superadmin')
        )
    );







CREATE OR REPLACE VIEW v_users_with_roles
WITH (security_invoker = true)
AS
SELECT
    up.id,
    au.email,
    up.full_name,
    up.phone,
    up.company_name,
    r.name          AS role_name,
    r.description   AS role_description,
    up.cod_status   AS status,
    up.created_at,
    up.updated_at,
    au.last_sign_in_at,
    au.email_confirmed_at
FROM user_profiles up
    JOIN auth.users au 
        ON up.id = au.id
    JOIN roles r 
        ON up.id_role = r.id_role
WHERE up.cod_status = 'A';




