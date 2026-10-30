-- Motivo formal de la solicitud de posventa
CREATE TYPE enum_return_reason AS ENUM (
    'ARREPENTIMIENTO_LEGAL', -- Ejercicio del derecho dentro de los 10 días (Ley 24.240)
    'CAMBIO_TALLE',          -- Solicitud de cambio voluntario por calce/medidas
    'DEFECTO_FABRICACION'    -- Falla atribuible a costura, pegado o materiales
);