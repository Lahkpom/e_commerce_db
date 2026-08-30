-- ME PARECE QUE ESTA FUNCIÓN NO SERÍA NECESARIA EN JAVA



CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT
LANGUAGE SQL
SECURITY DEFINER  -- Ejecuta con permisos del creador (bypasea RLS)
SET search_path = public
AS $$
    SELECT 
        r.name
    FROM 
        users u
        JOIN user_role r 
            ON u.role_id = r.role_id
    WHERE 
        u.id = auth.uid()
    LIMIT 
        1;
$$;