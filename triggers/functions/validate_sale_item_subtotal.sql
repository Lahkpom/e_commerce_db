-- Función para validar que el subtotal sea correcto
CREATE OR REPLACE FUNCTION validate_sale_item_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subtotal != (NEW.unit_price * NEW.quantity) THEN
        RAISE EXCEPTION 'El subtotal debe ser igual a unit_price × quantity';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;