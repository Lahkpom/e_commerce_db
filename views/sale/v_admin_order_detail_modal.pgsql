CREATE OR REPLACE VIEW v_admin_order_detail_modal AS
SELECT 
    s.sale_id,
    s.user_id,
    u.user_name AS account_name,
    s.customer_name,
    s.customer_email,
    s.customer_phone,
    s.shipping_address,
    s.shipping_cost,
    s.sale_notes,
    s.sale_quantity,
    s.sale_subtotal,
    s.sale_discounts,
    s.sale_total,
    s.sale_status,
    s.payment_method,
    s.payment_status,
    s.mp_payment_id,
    s.mp_preference_id,
    s.sale_shipped_date,
    s.created_at,
    s.created_by,
    cb.user_name AS created_by_name,
    s.updated_at,
    s.updated_by,
    ub.user_name AS updated_by_name,

    -- Desglose completo de items con stock actual en vivo
    COALESCE(
        (
            SELECT json_agg(
                json_build_object(
                    'sale_item_id',      si.sale_item_id,
                    'variant_id',        si.variant_id,
                    'product_name',      si.product_name,
                    'variant_desc',      si.variant_desc,
                    'sku',               si.sale_item_sku,
                    'sold_unit_price',   si.sale_item_unit_price,
                    'quantity',          si.sale_item_quantity,
                    'subtotal',          si.sale_item_subtotal,
                    'current_stock',     pv.variant_stock,
                    'current_price',     pv.variant_price,
                    'color_desc',        col.color_desc,
                    'color_code',        col.color_code,
                    'size',              sz.size,
                    'main_image',        (
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

FROM sale s
LEFT JOIN users u  ON s.user_id    = u.user_id
LEFT JOIN users cb ON s.created_by = cb.user_id
LEFT JOIN users ub ON s.updated_by = ub.user_id;