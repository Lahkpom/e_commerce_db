-- Función para validar stock antes de crear un sale_item
CREATE OR REPLACE FUNCTION check_product_stock()
RETURNS TRIGGER AS $$
DECLARE
    available_stock INTEGER;
BEGIN
    SELECT stock INTO available_stock
    FROM products
    WHERE id_product = NEW.id_product;
    
    IF available_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto. Disponible: %, Solicitado: %', 
            available_stock, NEW.quantity;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;