-- Trigger para validar subtotal en sale_items
CREATE TRIGGER trg_validate_subtotal
    BEFORE INSERT OR UPDATE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION validate_sale_item_subtotal();

-- Trigger para verificar stock
CREATE TRIGGER trg_check_stock
    BEFORE INSERT ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION check_product_stock();