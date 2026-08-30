-- Política para que usuarios vean SOLO SUS ventas (si están logueados) O ventas anónimas con su mismo email
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
        ON up.role_id = r.role_id
WHERE up.row_status = 'active';

COMMENT ON VIEW v_users_with_roles              IS 'Vista de usuarios con información completa para panel admin';
