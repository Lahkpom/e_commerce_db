-- Vista principal para listado de productos (Homepage)
CREATE OR REPLACE VIEW v_products_complete
SELECT 
    p.product_id,
    p.product_name,
    p.product_short_desc,
    p.product_long_desc,
    p.product_category,
    p.row_status                        AS status,
    
    -- Stock total
    COALESCE(SUM(pv.variant_stock), 0)  AS total_stock,
        
    -- Metadata
    COUNT(DISTINCT pv.variant_id)       AS variant_count,
    COUNT(DISTINCT pv.color_id)         AS color_count,
    COUNT(DISTINCT pv.size_id)          AS size_count,
    
    p.created_at,
    p.updated_at,
    
    -- ✅ Array de imágenes: UNA por COLOR (sin repetir)
    COALESCE((
        SELECT json_agg(
            json_build_object(
                'color_id'  , col.color_id,
                'color_name', col.color_name,
                'color_desc', col.color_desc,
                'hex_code'  , col.color_code,
                'image_url' , (
                    -- Seleccionar la primera imagen de cualquier variante con este color
                    SELECT 
                        vi.image_url
                    FROM 
                        product_variant         pv_inner
                        JOIN variant_image      vi 
                            ON vi.variant_id    = pv_inner.variant_id
                    WHERE 
                        pv_inner.product_id     = p.product_id
                        AND pv_inner.color_id   = col.color_id
                        AND pv_inner.row_status = 'active'
                        AND vi.row_status       = 'active'
                    ORDER BY 
                        vi.order_position
                    LIMIT 1
                )
            )
            ORDER BY col.color_id
        )
        FROM (
            -- Obtener colores únicos del producto
            SELECT DISTINCT 
                c.color_id, 
                c.color_name, 
                c.color_desc, 
                c.color_code
            FROM 
                product_variant     pv2
                JOIN color          c 
                    ON pv2.color_id = c.color_id
            WHERE 
                pv2.product_id      = p.product_id
                AND pv2.row_status  = 'active'
        ) col
    ), '[]'::json) AS variant_main_images
    
FROM product p
LEFT JOIN product_variant pv ON p.product_id = pv.product_id AND pv.row_status = 'active'
WHERE 
    p.row_status = 'active'
GROUP BY 
    p.product_id, 
    c.color_desc, 
    c.color_name;

COMMENT ON VIEW v_products_complete IS 'Listado de todos los Productos que hay para listar en la web. Cada producto incluye la imagen con image_order = 1 de cada variante del producto para mostrar en un carousel la variedad';
