CREATE TABLE users (
    user_id                 UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id                 enum_user_role  NOT NULL DEFAULT 'customer',
    user_password           VARCHAR(255)    NOT NULL,
    user_name               VARCHAR(255)    NOT NULL,
    user_email              VARCHAR(255)    NOT NULL UNIQUE CHECK (user_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    user_phone              VARCHAR(50)     NULL,
    company_name            VARCHAR(255)    NULL,
    is_email_verified       BOOLEAN         NOT NULL DEFAULT FALSE,
    failed_login_attempts   INTEGER         NOT NULL DEFAULT 0 CHECK (failed_login_attempts >= 0),
    locked_until            TIMESTAMP       NULL,
    last_login_at           TIMESTAMP       NULL,
    row_status              enum_row_status NOT NULL DEFAULT 'active',
    created_at              TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP       NULL
);
-- ########################################################################################
CREATE INDEX idx_user_role          ON users(role_id);
CREATE INDEX idx_users_role_status  ON users(role_id, row_status);
-- ########################################################################################
CREATE TRIGGER trg_user_update
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE users                          IS 'Tabla principal de usuarios y credenciales del sistema.';
COMMENT ON COLUMN users.user_id                 IS 'Identificador único UUID generado aleatoriamente para cada usuario.';
COMMENT ON COLUMN users.role_id                 IS 'Rol del usuario (superadmin, admin, wholesaler, customer). Por defecto es 4 = customer';
COMMENT ON COLUMN users.user_password           IS 'Hash criptográfico de la contraseña (generado con BCrypt/Argon2 desde Java).';
COMMENT ON COLUMN users.user_name               IS 'Nombre completo o razón comercial de contacto del usuario.';
COMMENT ON COLUMN users.user_email              IS 'Correo electrónico único validado con formato regex estándar.';
COMMENT ON COLUMN users.user_phone              IS 'Número de teléfono o WhatsApp de contacto.';
COMMENT ON COLUMN users.company_name            IS 'Razón social de la empresa (aplica únicamente para cuentas mayoristas).';
COMMENT ON COLUMN users.is_email_verified       IS 'Indica si el usuario completó la verificación mediante token de correo.';
COMMENT ON COLUMN users.failed_login_attempts   IS 'Contador de intentos consecutivos fallidos para control de fuerza bruta.';
COMMENT ON COLUMN users.locked_until            IS 'Fecha y hora hasta la cual la cuenta permanece bloqueada temporalmente.';
COMMENT ON COLUMN users.last_login_at           IS 'Timestamp del último inicio de sesión exitoso.';