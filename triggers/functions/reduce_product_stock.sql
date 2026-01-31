-- Función para reducir stock automáticamente al confirmar venta
CREATE OR REPLACE FUNCTION reduce_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo reducir stock cuando el estado cambia a 'approved'
    IF NEW.id_payment_status = (SELECT id_status FROM payment_status WHERE description = 'approved')
       AND OLD.id_payment_status != NEW.id_payment_status THEN
        
        UPDATE products p
        SET stock = stock - si.quantity
        FROM sale_items si
        WHERE si.id_sale = NEW.id_sale
          AND si.id_product = p.id_product;
          
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;