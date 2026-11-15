CREATE OR REPLACE VIEW v_public_product_catalog AS
SELECT 
    p.product_id,
    p.product_category,
    p.target_gender,
    p.product_name,
    p.product_short_desc AS short_desc,

    -- Precio mínimo entre las variantes activas del producto
    MIN(pv.variant_price) AS min_price,

    -- Cantidad de talles distintos activos
    COUNT(DISTINCT pv.variant_size) AS size_count,

    -- Cantidad de colores distintos y activos entre variantes activas
    COUNT(DISTINCT c.color_id) AS color_count,

    -- Carrusel de portadas: 1 imagen principal por cada color activo del producto
    COALESCE(
        JSONB_AGG(
            DISTINCT JSONB_BUILD_OBJECT( -- Metadata para el crousel
                'color_id',   c.color_id,
                'color_name', c.color_name,
                'color_code', c.color_code,
                'image_url',  img.image_url
            )
        ) FILTER (WHERE img.image_url IS NOT NULL),
        '[]'::jsonb
    ) AS main_images_url

FROM product p
JOIN variant pv 
    ON  pv.product_id = p.product_id
    AND pv.row_status = 'ACTIVE'
JOIN color c 
    ON  c.color_id    = pv.color_id
    AND c.row_status  = 'ACTIVE'
LEFT JOIN image img 
    ON  img.product_id = p.product_id
    AND img.color_id   = c.color_id
    AND img.is_primary = TRUE

WHERE 
    p.row_status = 'ACTIVE'

GROUP BY 
    p.product_id,
    p.product_category,
    p.target_gender,
    p.product_name,
    p.product_short_desc;

COMMENT ON VIEW v_public_product_catalog IS 
'Catálogo público de productos activos filtrable por target_gender. Agrupa el precio mínimo, conteo de talles y colores activos, y una imagen primaria por cada color disponible.';