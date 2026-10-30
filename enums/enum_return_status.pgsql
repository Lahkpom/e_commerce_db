-- Estados del ciclo operativo y logístico de la devolución (RMA)
CREATE TYPE enum_return_status AS ENUM (
    'SOLICITADA',
    'EN_TRANSITO',
    'RECIBIDO_EN_CONTROL',
    'APROBADA',
    'RECHAZADA',
    'CANCELADA'
);