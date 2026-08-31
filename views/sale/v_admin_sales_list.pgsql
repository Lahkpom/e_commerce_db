CREATE OR REPLACE VIEW v_admin_sales_list AS
SELECT 
    s.sale_id,
    s.created_at AS order_date,
    s.customer_name,
    s.customer_email,
    s.customer_phone,
    s.sale_quantity AS total_items,
    s.sale_total,
    s.sale_status,
    s.payment_method,
    s.payment_status,
    s.mp_payment_id,
    s.sale_shipped_date,
    
    -- Indicador de si fue compra de usuario registrado o invitado
    CASE 
        WHEN s.user_id IS NOT NULL THEN TRUE ELSE FALSE 
    END AS is_registered_customer

FROM sale s
ORDER BY s.created_at DESC;