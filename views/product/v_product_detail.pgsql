CREATE OR REPLACE VIEW v_product_detail
AS
SELECT
    p.product_id,
    p.product_name,
    p.product_short_desc,
    p.product_long_desc,
    p.product_category,
    p.row_status                                    AS status,

    COUNT(DISTINCT pv.variant_id)                   AS total_variants,
    COUNT(DISTINCT pv.size_id)                      AS total_sizes,
    COUNT(DISTINCT pv.color_id)                     AS total_colors,

    COALESCE(SUM(pv.variant_stock), 0)              AS total_stock,
    COALESCE(MIN(pv.variant_price), p.base_price)   AS min_price,
    COALESCE(MAX(pv.variant_price), p.base_price)   AS max_price

FROM product                    p
    LEFT JOIN variant   pv 
        ON p.product_id         = pv.product_id
        AND pv.row_status       = 'active'

WHERE 
    p.row_status = 'active'
GROUP BY 
    p.product_id, 
    p.product_category;