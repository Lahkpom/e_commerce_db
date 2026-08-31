CREATE OR REPLACE VIEW v_customer_order_detail AS
SELECT 
    s.sale_id,
    s.user_id,
    s.customer_email,
    s.customer_name,
    s.customer_phone,
    s.shipping_address,
    s.sale_status,
    s.payment_method,
    s.payment_status,
    s.sale_quantity,
    s.sale_subtotal,
    s.sale_discounts,
    s.shipping_cost,
    s.sale_total,
    s.sale_shipped_date,
    s.created_at AS order_date,

    -- Arreglo JSON con los items comprados
    COALESCE(
        (
            SELECT json_agg(
                json_build_object(
                    'sale_item_id', si.sale_item_id,
                    'variant_id',   si.variant_id,
                    'product_name', si.product_name,
                    'variant_desc', si.variant_desc,
                    'sku',          si.sale_item_sku,
                    'unit_price',   si.sale_item_unit_price,
                    'quantity',     si.sale_item_quantity,
                    'subtotal',     si.sale_item_subtotal,
                    'color_desc',   col.color_desc,
                    'color_code',   col.color_code,
                    'size',         sz.size,
                    'image_url',    (
                        SELECT vi.image_url 
                        FROM variant_image vi 
                        WHERE vi.variant_id = si.variant_id 
                          AND vi.row_status = 'active'
                        ORDER BY vi.image_order ASC 
                        LIMIT 1
                    )
                ) ORDER BY si.created_at ASC
            )
            FROM sale_item si
            LEFT JOIN product_variant pv ON si.variant_id = pv.variant_id
            LEFT JOIN color col          ON pv.color_id   = col.color_id
            LEFT JOIN size sz            ON pv.size_id    = sz.size_id
            WHERE si.sale_id = s.sale_id
        ), 
        '[]'::json
    ) AS items

FROM sale s;