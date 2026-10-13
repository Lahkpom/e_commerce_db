CREATE TYPE enum_user_role AS ENUM (
    'SUPERADMIN',
    'ADMIN',
    'WHOLESALER',
    'CUSTOMER'
);

COMMENT ON TYPE enum_user_role IS 
'Roles de usuario para control de acceso al sistema:
- SUPERADMIN: Super administrador con acceso total al sistema. Puede crear otros admins y gestionar todos los aspectos del ecommerce.
- ADMIN: Administrador que puede gestionar productos, ventas y crear usuarios mayoristas. Solo puede ser creado por superadmins.
- WHOLESALER: Cliente mayorista con descuentos especiales. Solo puede ser creado por admins.
- CUSTOMER: Cliente regular que puede comprar productos y ver su historial de compras.';