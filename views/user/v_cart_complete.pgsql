-- 
CREATE OR REPLACE VIEW v_cart_complete
AS
SELECT
    c.user_id,
    c.variant_id,
    c.quantity,
    
    -- Info del producto
    p.product_id,
    p.product_name,
    pv.variant_sku,
    pv.variant_price,
    pv.variant_stock,
    pv.row_status   AS status,
    
    -- Info de color y talle
    col.color_desc,
    col.color_code,
    sz.size,
    
    -- Imagen principal
    (
        SELECT  
            image_url 
        FROM    
            variant_image vi
        WHERE   
            vi.variant_id       = c.variant_id
            AND vi.row_status   = 'active'
        ORDER BY 
            vi.image_order
        LIMIT 1
    ) AS main_image,
    
    -- Subtotal calculado con precio actual
    (c.quantity * pv.variant_price) AS subtotal,
    
    -- Validación de stock
    CASE 
        WHEN pv.variant_stock >= c.quantity THEN TRUE ELSE FALSE
    END AS has_stock

FROM cart               c
JOIN variant    pv  ON c.variant_id     = pv.variant_id
JOIN product            p   ON pv.product_id    = p.product_id
JOIN color              col ON pv.color_id      = col.color_id
JOIN size               sz  ON pv.size_id       = sz.size_id;

COMMENT ON VIEW v_cart_complete IS 'Trae la información del carrito de compras de un usuario registrado junto con toda la información necesaria para renderizar';
