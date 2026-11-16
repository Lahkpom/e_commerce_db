CREATE OR REPLACE VIEW v_public_product_variants AS
SELECT
    p.product_id,
    p.product_name,
    p.product_long_desc,
    pv.variant_id,
    pv.variant_size,
    pv.variant_price,
    pv.variant_stock,
    c.color_id,
    c.color_name,
    c.color_code,
    COALESCE(
        (
            SELECT JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'image_url', i.image_url,
                    'is_primary', i.is_primary
                )
                ORDER BY i.is_primary DESC, i.created_at ASC, i.image_id ASC
            )
            FROM image i
            WHERE i.product_id = pv.product_id
                AND i.color_id = pv.color_id
        ),
        '[]'::jsonb
    ) AS images
FROM product p
JOIN variant pv
    ON pv.product_id = p.product_id
    AND pv.row_status = 'ACTIVE'
JOIN color c
    ON c.color_id = pv.color_id
    AND c.row_status = 'ACTIVE'
WHERE p.row_status = 'ACTIVE';

COMMENT ON VIEW v_public_product_variants IS
'Detalle público de variantes activas de productos activos. Incluye talle, color, precio, stock (también cero) e imágenes del producto y color, ordenadas con la principal primero.';
