-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- Crear un usuario
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- 1. Crear el usuario en auth.users usando la función de Supabase
SELECT supabase_auth.create_user(
    uid := gen_random_uuid(),
    email := 'blackanvilsoftworks@gmail.com',
    password := '12345678',
    email_confirm := true  -- Esto evita que tenga que confirmar el email
);

-- 2. Obtener el ID del usuario recién creado (para usarlo en el perfil)
-- Nota: Guarda este ID, lo necesitarás para verificar
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'blackanvilsoftworks@gmail.com';

-- 3. Insertar el perfil con rol superadmin
INSERT INTO user_profiles (id, full_name, id_role)
VALUES (
    (SELECT id FROM auth.users WHERE email = 'blackanvilsoftworks@gmail.com'),
    'Black Anvil',
    (SELECT id_role FROM roles WHERE name = 'superadmin')
);
