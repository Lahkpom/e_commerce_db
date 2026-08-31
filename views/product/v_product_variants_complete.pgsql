-- Vista de variantes completas
CREATE OR REPLACE VIEW v_product_variants_complete 
AS
SELECT 
    pv.variant_id,
    pv.product_id,
    p.product_name,
    p.product_short_desc,
    p.product_long_desc,
    pv.variant_sku,
    pv.variant_price,
    pv.variant_stock,
    
    col.color_id,
    col.color_name,
    col.color_desc,
    col.color_code,
    
    sz.size_id,
    sz.size,
    sz.size_desc,
    sz.size_order,
    
    p.product_category  AS category,
    pv.row_status       AS status,
    
    (
        SELECT 
            image_url 
        FROM 
            variant_image vi 
        WHERE 
            vi.variant_id = pv.variant_id 
            AND vi.row_status   = 'active'
        ORDER BY 
            vi.image_order 
        LIMIT 1
    ) AS main_image,
    
    (
        SELECT 
            COUNT(*)
        FROM 
            variant_image vi 
        WHERE 
            vi.variant_id       = pv.variant_id 
            AND vi.row_status   = 'active'
    ) AS image_count,
    
    pv.created_at,
    pv.updated_at
    
FROM product_variant    pv
JOIN product            p   ON pv.product_id    = p.product_id
JOIN color              col ON pv.color_id      = col.color_id
JOIN size               sz  ON pv.size_id       = sz.size_id;