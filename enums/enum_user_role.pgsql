CREATE TYPE enum_user_role AS ENUM (
    'ADMIN',
    'OPERATOR',
    'WHOLESALER',
    'CUSTOMER'
);

COMMENT ON TYPE enum_user_role IS 
'Roles de usuario para control de acceso al sistema:
- ADMIN: Administrador con acceso total al sistema. Puede gestionar todos los aspectos del ecommerce y crear operadores.
- OPERATOR: Operador que puede gestionar productos, ventas y crear usuarios mayoristas. Solo puede ser creado por administradores.
- WHOLESALER: Cliente mayorista con descuentos especiales. Solo puede ser creado por operadores.
- CUSTOMER: Cliente regular que puede comprar productos y ver su historial de compras.';