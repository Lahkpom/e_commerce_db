CREATE TABLE user_login_log (
    log_id          BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY
    user_id         UUID            NULL REFERENCES users(user_id) ON DELETE SET NULL,
    attempted_email VARCHAR(255)    NOT NULL,
    is_success      BOOLEAN         NOT NULL,
    failure_reason  VARCHAR(100)    NULL,
    ip_address      INET            NULL,
    user_agent      TEXT            NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
-- ########################################################################################
CREATE INDEX idx_login_log_user         ON user_login_log(user_id, created_at DESC);
CREATE INDEX idx_login_log_ip           ON user_login_log(ip_address, created_at DESC);
CREATE INDEX idx_login_log_email_recent ON user_login_log(LOWER(attempted_email), created_at DESC) WHERE is_success = FALSE;
-- ########################################################################################
CREATE OR REPLACE FUNCTION trg_fn_update_user_last_login()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
    IF 
        NEW.is_success  = TRUE 
        AND NEW.user_id IS NOT NULL 
    THEN
        UPDATE 
            users
        SET 
            last_login_at           = NEW.created_at,
            failed_login_attempts   = 0,
            locked_until            = NULL
        WHERE 
            user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;
-- ----------------------------------------------------------------------------------------
CREATE TRIGGER trg_user_login_success
    AFTER INSERT ON user_login_log
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_update_user_last_login();
-- ########################################################################################
COMMENT ON TABLE user_login_log                     IS 'Registro histórico e inmutable de todos los intentos de inicio de sesión (éxitos y fallos).';
COMMENT ON COLUMN user_login_log.log_id             IS 'Identificador autoincremental de 64 bits para soportar alto volumen de registros.';
COMMENT ON COLUMN user_login_log.user_id            IS 'ID del usuario autenticado. NULL si el usuario no existe en la base o fue eliminado.';
COMMENT ON COLUMN user_login_log.attempted_email    IS 'Email ingresado en el formulario de login. Se guarda por si el user_id no existe';
COMMENT ON COLUMN user_login_log.is_success         IS 'Indica si la autenticación fue exitosa (true) o rechazada (false).';
COMMENT ON COLUMN user_login_log.failure_reason     IS 'Código o motivo del fallo (ej: INVALID_CREDENTIALS, ACCOUNT_LOCKED, USER_NOT_FOUND).';
COMMENT ON COLUMN user_login_log.ip_address         IS 'Dirección IP del cliente en formato nativo IPv4 o IPv6.';
COMMENT ON COLUMN user_login_log.user_agent         IS 'Cadena User-Agent del navegador o cliente HTTP para análisis de huella digital.';
COMMENT ON COLUMN user_login_log.created_at         IS 'Fecha y hora exacta en la que se procesó el intento de autenticación.';