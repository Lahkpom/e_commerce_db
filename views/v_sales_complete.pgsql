-- Vista de ventas completas
CREATE OR REPLACE VIEW v_sales_complete 
WITH (security_invoker = true) 
AS
SELECT 
    s.id_sale,
    s.total,
    s.customer_name,
    s.customer_email,
    s.customer_phone,
    s.shipping_address,
    s.order_notes,
    ss.description AS sale_status,
    pm.description AS payment_method,
    ps.description AS payment_status,
    s.mp_payment_id,
    s.mp_preference_id,
    s.shipping_cost,
    s.created_at,
    s.date_completed,
    s.updated_at,
    (
        SELECT COUNT(*) 
        FROM sale_items si 
        WHERE si.id_sale = s.id_sale
    ) AS total_items
FROM sales s
JOIN sale_status        ss ON s.id_sale_status      = ss.id_status
JOIN payment_methods    pm ON s.id_payment_method   = pm.id_method
JOIN payment_status     ps ON s.id_payment_status   = ps.id_status;