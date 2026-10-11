CREATE TYPE enum_user_role AS ENUM (
    'superadmin',
    'admin',
    'wholesaler',
    'customer'
);

COMMENT ON TYPE enum_user_role IS 
'Roles de usuario para control de acceso al sistema:
- superadmin: Super administrador con acceso total al sistema. Puede crear otros admins y gestionar todos los aspectos del ecommerce.
- admin: Administrador que puede gestionar productos, ventas y crear usuarios mayoristas. Solo puede ser creado por superadmins.
- wholesaler: Cliente mayorista con descuentos especiales. Solo puede ser creado por admins.
- customer: Cliente regular que puede comprar productos y ver su historial de compras.';