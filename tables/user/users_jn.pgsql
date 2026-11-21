-- 1. Crear la tabla de Journal
CREATE TABLE users_jn (
    jn_id                   BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jn_operation            VARCHAR(10)     NOT NULL CHECK (jn_operation IN ('UPDATE', 'DELETE')),
    jn_timestamp            TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    jn_changed_by           VARCHAR(255)    NULL, -- usuario o service que ejecutó el cambio
    
    -- Snapshot del registro tal como estaba
    user_id                 UUID            NOT NULL,
    user_role               enum_user_role  NOT NULL,
    user_password           VARCHAR(255)    NOT NULL,
    user_name               VARCHAR(255)    NOT NULL,
    user_email              VARCHAR(255)    NOT NULL,
    user_phone              VARCHAR(50)     NULL,
    company_name            VARCHAR(255)    NULL,
    tax_id_type             tax_id_type     NULL,
    tax_id_number           VARCHAR(20)     NULL,
    is_email_verified       BOOLEAN         NOT NULL,
    failed_login_attempts   INTEGER         NOT NULL,
    locked_until            TIMESTAMPTZ     NULL,
    last_login_at           TIMESTAMPTZ     NULL,
    password_expires_at     TIMESTAMPTZ     NOT NULL,
    must_change_password    BOOLEAN         NOT NULL,
    row_status              enum_row_status NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL,
    updated_at              TIMESTAMPTZ     NULL
);

CREATE INDEX idx_users_jn_user_id ON users_jn(user_id, jn_timestamp DESC);

-- 2. Función del trigger para capturar el snapshot previo
CREATE OR REPLACE FUNCTION trg_fn_audit_users()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_changed_by VARCHAR(255);
BEGIN
    v_changed_by := NULLIF(current_setting('app.current_user', true), '');
    IF v_changed_by IS NULL THEN
        v_changed_by := SESSION_USER;
    END IF;

    INSERT INTO users_jn (
        jn_operation, 
        jn_timestamp,
        jn_changed_by,
        user_id, 
        user_role, 
        user_password, 
        user_name, 
        user_email,
        user_phone, 
        company_name,
        tax_id_type,
        tax_id_number,
        is_email_verified, 
        failed_login_attempts,
        locked_until, 
        last_login_at, 
        password_expires_at,
        must_change_password,
        row_status,
        created_at, 
        updated_at
    ) VALUES (
        TG_OP, 
        NOW(),
        v_changed_by,
        OLD.user_id, 
        OLD.user_role, 
        OLD.user_password, 
        OLD.user_name, 
        OLD.user_email,
        OLD.user_phone, 
        OLD.company_name, 
        OLD.tax_id_type,
        OLD.tax_id_number,
        OLD.is_email_verified, 
        OLD.failed_login_attempts,
        OLD.locked_until, 
        OLD.last_login_at, 
        OLD.password_expires_at,
        OLD.must_change_password,
        OLD.row_status,
        OLD.created_at, 
        OLD.updated_at
    );

    IF      TG_OP = 'UPDATE' THEN RETURN NEW;
    ELSIF   TG_OP = 'DELETE' THEN RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- 3. Vincular el trigger a la tabla users
CREATE TRIGGER trg_users_audit
    AFTER UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_audit_users();