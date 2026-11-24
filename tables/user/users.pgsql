CREATE TABLE users (
    user_id                 UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_role               enum_user_role  NOT NULL DEFAULT 'CUSTOMER',
    user_password           VARCHAR(255)    NOT NULL,
    user_name               VARCHAR(255)    NOT NULL,
    user_email              VARCHAR(255)    NOT NULL CHECK (user_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$'),
    user_phone              VARCHAR(50)     NULL,
    company_name            VARCHAR(255)    NULL,
    tax_id_type             tax_id_type     NULL,
    tax_id_number           VARCHAR(20)     NULL,
    is_email_verified       BOOLEAN         NOT NULL DEFAULT FALSE,
    failed_login_attempts   INTEGER         NOT NULL DEFAULT 0 CHECK (failed_login_attempts >= 0),
    locked_until            TIMESTAMPTZ     NULL,
    last_login_at           TIMESTAMPTZ     NULL,
    password_expires_at     TIMESTAMPTZ     NOT NULL DEFAULT (NOW() + INTERVAL '180 days'),
    must_change_password    BOOLEAN         NOT NULL DEFAULT FALSE,
    row_status              enum_row_status NOT NULL DEFAULT 'ACTIVE',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NULL
);
-- ########################################################################################
CREATE UNIQUE INDEX uk_user_email_not_deleted 
    ON users (LOWER(user_email)) 
    WHERE row_status <> 'DELETED';
-- ########################################################################################
CREATE INDEX idx_users_role_status  ON users(user_role, row_status);
CREATE INDEX idx_users_tax_id       ON users (tax_id_number);
-- ########################################################################################
CREATE TRIGGER trg_user_update
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE users                          IS 'Tabla principal de usuarios y credenciales administrada por Spring Boot.';
COMMENT ON COLUMN users.user_id                 IS 'Identificador único UUID.';
COMMENT ON COLUMN users.user_role               IS 'Rol del usuario (ADMIN, OPERATOR, WHOLESALER, CUSTOMER). Por defecto es CUSTOMER';
COMMENT ON COLUMN users.user_password           IS 'Hash criptográfico (BCrypt) generado por el backend.';
COMMENT ON COLUMN users.user_name               IS 'Nombre completo o razón social de contacto.';
COMMENT ON COLUMN users.user_email              IS 'Correo electrónico único validado.';
COMMENT ON COLUMN users.user_phone              IS 'Teléfono o WhatsApp.';
COMMENT ON COLUMN users.company_name            IS 'Razón social (para cuentas WHOLESALER).';
COMMENT ON COLUMN users.is_email_verified       IS 'Indica si validó el correo.';
COMMENT ON COLUMN users.failed_login_attempts   IS 'Contador de intentos fallidos para protección de fuerza bruta.';
COMMENT ON COLUMN users.locked_until            IS 'Bloqueo temporal por exceso de intentos fallidos.';
COMMENT ON COLUMN users.last_login_at           IS 'Último acceso con éxito.';
COMMENT ON COLUMN users.must_change_password    IS 'Indica si el usuario debe cambiar su contraseña antes de continuar.';
-- ########################################################################################
-- ########################################################################################
-- SCRIPT PARA GENERAR USUARIOS ADMINISTRADORES
-- ########################################################################################
-- ########################################################################################
-- 1. Habilitar la extensión (en Supabase ya suele venir activa)
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- 2. Insertar el administrador con su contraseña hasheada al vuelo
INSERT INTO users (
    user_id,
    user_name,
    user_email,
    user_password,
    user_role,
    row_status,
    is_email_verified,
    must_change_password
) VALUES (
    gen_random_uuid(),
    'NOMBRE',
    'admin@admin.com',
    crypt('MiClaveSegura123!', gen_salt('bf', 10)), -- Genera hash BCrypt estándar con costo 10
    'ADMIN',
    'ACTIVE',
    TRUE,
    TRUE -- Obliga al usuario a cambiar la contraseña al primer login
);