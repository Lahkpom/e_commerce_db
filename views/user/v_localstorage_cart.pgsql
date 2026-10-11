-- Esta también es del carrito de compras pero hidrata la información de un carrito en el localstorage
CREATE OR REPLACE VIEW v_localstorage_cart
AS
SELECT
    pv.variant_id,
    p.product_id,
    p.product_name,
    pv.variant_sku,
    pv.variant_price,
    pv.variant_stock,

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
            vi.variant_id       = pv.variant_id
            AND vi.row_status   = 'active'
        ORDER BY 
            vi.image_order
        LIMIT 1
    ) AS main_image

FROM variant pv
JOIN product    p   ON pv.product_id    = p.product_id
JOIN color      col ON pv.color_id      = col.color_id
JOIN size       sz  ON pv.size_id       = sz.size_id

WHERE 
    pv.row_status = 'active';

COMMENT ON VIEW v_localstorage_cart IS 'Datos públicos de variantes activas, accesible para usuarios anónimos. Usada para hidratar el carrito desde localStorage.';
