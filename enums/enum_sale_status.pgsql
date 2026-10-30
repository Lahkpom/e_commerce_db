CREATE TYPE enum_sale_status AS ENUM (
    'PENDIENTE',
    'PREPARACION',
    'ENVIADO',
    'ENTREGADO',
    'CANCELADO',
    'REEMBOLSADO',
    'AUDITORIA', -- Orden retenida por discrepancias de pago, fraude potencial o revisión manual
    'RECLAMO_ABIERTO',
    'CERRADO_CON_DEVOLUCION'
);