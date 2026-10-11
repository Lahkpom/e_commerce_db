-- Vista de imágenes de variante específica
CREATE OR REPLACE VIEW v_variant_images 
WITH (security_invoker = true) 
AS
SELECT 
    vi.id_image,
    vi.id_variant,
    vi.image_url,
    vi.order_position,
    vi.cod_status   AS status,
    
    pv.id_product,
    p.name          AS product_name,
    c.name          AS color_name,
    c.description   AS color_description,
    c.hex_code,
    s.size,
    s.description   AS size_description,
    
    vi.created_at
FROM variant_images vi
JOIN variants   pv  ON vi.id_variant    = pv.id_variant
JOIN products           p   ON pv.id_product    = p.id_product
JOIN colors             c   ON pv.id_color      = c.id_color
JOIN sizes              s   ON pv.id_size       = s.id_size
WHERE vi.row_status = 'active'
ORDER BY vi.id_variant, vi.order_position;

COMMENT ON VIEW v_variant_images                IS 'Imágenes de variante para carousel';
