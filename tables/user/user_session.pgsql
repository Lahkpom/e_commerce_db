CREATE TABLE user_session (
    session_id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID            NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token_hash  VARCHAR(255)    NOT NULL UNIQUE,
    device_info         VARCHAR(255)    NULL,
    ip_address          INET            NULL,
    is_revoked          BOOLEAN         NOT NULL DEFAULT FALSE,
    expires_at          TIMESTAMP       NOT NULL,
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW(),
    last_activity_at    TIMESTAMP       NOT NULL DEFAULT NOW()
);
-- ########################################################################################
CREATE INDEX idx_user_session_lookup        ON user_session(user_id)            WHERE is_revoked = FALSE;
CREATE INDEX idx_user_session_token_active  ON user_session(refresh_token_hash) WHERE is_revoked = FALSE;
-- ########################################################################################
COMMENT ON TABLE user_session                       IS 'Sesiones activas y almacén de Refresh Tokens para rotación y revocación de JWT.';
COMMENT ON COLUMN user_session.session_id           IS 'Identificador único de la sesión activa del dispositivo.';
COMMENT ON COLUMN user_session.user_id              IS 'Usuario propietario de la sesión. Si el usuario se elimina, sus sesiones se borran en cascada.';
COMMENT ON COLUMN user_session.refresh_token_hash   IS 'Hash criptográfico (SHA-256) del Refresh Token entregado al cliente.';
COMMENT ON COLUMN user_session.device_info          IS 'Resumen legible del dispositivo o navegador (ej: Chrome 120 en Windows 10).';
COMMENT ON COLUMN user_session.ip_address           IS 'Última dirección IP registrada desde donde operó la sesión.';
COMMENT ON COLUMN user_session.is_revoked           IS 'Indica si la sesión fue cerrada explícitamente por logout o invalidación de seguridad.';
COMMENT ON COLUMN user_session.expires_at           IS 'Fecha límite de validez del Refresh Token.';
COMMENT ON COLUMN user_session.created_at           IS 'Fecha de inicio de la sesión.';
COMMENT ON COLUMN user_session.last_activity_at     IS 'Última vez que este Refresh Token fue utilizado para emitir un Access Token.';