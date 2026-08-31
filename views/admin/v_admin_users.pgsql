CREATE OR REPLACE VIEW v_admin_users AS
SELECT 
    u.user_id,
    u.role_id,
    r.role_name,
    u.user_name,
    u.user_email,
    u.user_phone,
    COALESCE(u.company_name, 'NO CORRESPONDE') AS company_name,
    u.is_email_verified,
    u.failed_login_attempts,
    u.locked_until,
    
    -- Indicador booleano calculado de si la cuenta está actualmente bloqueada
    CASE 
        WHEN u.locked_until IS NOT NULL AND u.locked_until > NOW() THEN TRUE 
        ELSE FALSE 
    END AS is_currently_locked,
    
    u.last_login_at,
    u.row_status,
    u.created_at,
    u.updated_at,

    -- Métrica agregada: Historial de compras del usuario
    COALESCE(s.total_orders, 0) AS total_orders_count,
    COALESCE(s.total_spent, 0.00) AS total_spent_amount

FROM users u
JOIN user_role r ON u.role_id = r.role_id

-- Subconsulta para métricas de compras sin multiplicar filas
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(sale_id) AS total_orders,
        SUM(sale_total) AS total_spent
    FROM sale
    WHERE sale_status != 'cancelado' -- Omitir ventas canceladas si aplica
    GROUP BY user_id
) s ON u.user_id = s.user_id

WHERE u.role_id IN (3, 4);

COMMENT ON VIEW v_admin_users IS 'Vista de usuarios con información completa para panel admin. Solo trae a los wholesaler y customer';