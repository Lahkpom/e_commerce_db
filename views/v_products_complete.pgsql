-- Vista principal para listado de productos (Homepage)
-- ❌ CORREGIDO: Una imagen POR COLOR (no por variante)
CREATE OR REPLACE VIEW v_products_complete WITH (security_invoker = true) AS
SELECT 
    p.id_product,
    p.name          AS product_name,
    p.short_desc,
    p.long_desc,
    p.base_price,
    p.id_category,
    c.name          AS cat_name,
    c.description   AS category,
    p.cod_status    AS status,
    
    -- Stock total
    COALESCE(SUM(pv.stock), 0) AS total_stock,
    
    -- Rango de precios
    COALESCE(MIN(pv.price), p.base_price) AS min_price,
    COALESCE(MAX(pv.price), p.base_price) AS max_price,
    
    -- Metadata
    COUNT(DISTINCT pv.id_variant)   AS variant_count,
    COUNT(DISTINCT pv.id_color)     AS color_count,
    COUNT(DISTINCT pv.id_size)      AS size_count,
    
    p.created_at,
    p.updated_at,
    
    -- ✅ Array de imágenes: UNA por COLOR (sin repetir)
    COALESCE(
        (
            SELECT json_agg(
                json_build_object(
                    'id_color'          , col.id_color,
                    'color_name'        , col.name,
                    'color_description' , col.description,
                    'hex_code'          , col.hex_code,
                    'image_url'         , (
                        -- Seleccionar la primera imagen de cualquier variante con este color
                        SELECT vi.image_url
                        FROM product_variants pv_inner
                        JOIN variant_images vi ON vi.id_variant = pv_inner.id_variant
                        WHERE pv_inner.id_product   = p.id_product
                          AND pv_inner.id_color     = col.id_color
                          AND pv_inner.cod_status   = 'A'
                          AND vi.cod_status         = 'A'
                        ORDER BY vi.order_position
                        LIMIT 1
                    )
                )
                ORDER BY col.id_color
            )
            FROM (
                -- Obtener colores únicos del producto
                SELECT DISTINCT 
                    c.id_color, 
                    c.name, 
                    c.description, 
                    c.hex_code
                FROM product_variants pv2
                JOIN colors c ON pv2.id_color = c.id_color
                WHERE pv2.id_product = p.id_product
                  AND pv2.row_status = 'active'
            ) col
        ),
        '[]'::json
    ) AS color_images
    
FROM products p
JOIN categories             c   ON p.id_category    = c.id_category
LEFT JOIN product_variants  pv  ON p.id_product     = pv.id_product AND pv.row_status = 'active'
WHERE p.row_status = 'active'
GROUP BY p.id_product, c.description, c.name;

COMMENT ON VIEW v_products_complete             IS 'Vista para homepage: 1 imagen por color';
