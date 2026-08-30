CREATE OR REPLACE FUNCTION purge_expired_sessions_and_logs(
    p_session_days INTEGER DEFAULT 30,
    p_log_days INTEGER DEFAULT 90
)
RETURNS VOID 
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
    -- Borrar sesiones revocadas o vencidas hace más de X días
    DELETE FROM user_session
    WHERE (is_revoked = TRUE OR expires_at < NOW())
        AND created_at < NOW() - (p_session_days || ' days')::INTERVAL;

    -- Borrar logs de inicio de sesión antiguos
    DELETE FROM user_login_log
    WHERE created_at < NOW() - (p_log_days || ' days')::INTERVAL;
END;
$$;