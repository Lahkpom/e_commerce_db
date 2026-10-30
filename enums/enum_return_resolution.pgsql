-- Tipo de resolución acordada para la posventa
CREATE TYPE enum_return_resolution AS ENUM (
    'REEMBOLSO_DINERO',     -- Devolución del dinero abonado
    'CAMBIO_PRODUCTO',      -- Reemplazo por otro talle/prenda
    'CREDITO_TIENDA'        -- Cupón/saldo a favor del cliente
);