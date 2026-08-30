-- Vista de variantes completas
CREATE OR REPLACE VIEW v_product_variants_complete 
WITH (security_invoker = true) 
AS
SELECT 
    pv.id_variant,
    pv.id_product,
    p.name          AS product_name,
    p.short_desc    AS product_short_desc,
    p.long_desc     AS product_long_desc,
    pv.sku,
    pv.price,
    pv.stock,
    
    col.id_color,
    col.name        AS color_name,
    col.description AS color_desc,
    col.hex_code,
    
    sz.id_size,
    sz.size,
    sz.description  AS size_desc,
    sz.sort_order,
    
    cat.description AS category,
    pv.cod_status   AS status,
    
    (
        SELECT image_url 
        FROM variant_images vi 
        WHERE vi.id_variant = pv.id_variant 
        AND vi.cod_status   = 'A'
        ORDER BY vi.order_position 
        LIMIT 1
    ) AS main_image,
    
    (
        SELECT COUNT(*)
        FROM variant_images vi 
        WHERE vi.id_variant = pv.id_variant 
        AND vi.cod_status   = 'A'
    ) AS image_count,
    
    pv.created_at,
    pv.updated_at
    
FROM product_variants pv
JOIN products   p   ON pv.id_product    = p.id_product
JOIN colors     col ON pv.id_color      = col.id_color
JOIN sizes      sz  ON pv.id_size       = sz.id_size
JOIN categories cat ON p.id_category    = cat.id_category;