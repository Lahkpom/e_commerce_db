-- Trigger para sales
CREATE TRIGGER trg_sales_updated_at
    BEFORE UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para reducir stock cuando se aprueba el pago
CREATE TRIGGER trg_reduce_stock_on_payment
    AFTER UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION reduce_product_stock();