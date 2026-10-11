-- Vista organizada: Producto → Talles → Colores
CREATE OR REPLACE VIEW v_variants_by_size
WITH (security_invoker = true)
AS
SELECT DISTINCT
    p.id_product,
    p.name        AS product_name,
    s.id_size,
    s.size,
    s.sort_order,
    s.description AS size_description

FROM products        p
JOIN variants pv ON p.id_product = pv.id_product
JOIN sizes            s  ON pv.id_size   = s.id_size
WHERE pv.row_status = 'active'
  AND p.cod_status  = 'A'
ORDER BY p.id_product, s.sort_order;



COMMENT ON VIEW v_variants_by_size              IS 'Vista: Talle → Colores disponibles';
