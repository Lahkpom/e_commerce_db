-- Vista de productos con información completa
CREATE OR REPLACE VIEW v_products_complete AS
SELECT 
    p.id_product,
    p.name_product,
    p.description,
    p.price,
    c.description AS desc_category,
    p.stock,
    p.sku,
    ps.description AS desc_status,
    p.created_at,
    p.updated_at,
    (
        SELECT image_url 
        FROM product_images pi 
        WHERE pi.id_product = p.id_product 
        AND pi.id_status = 1
        ORDER BY pi.order_position 
        LIMIT 1
    ) AS main_image
FROM products p
JOIN categories c ON p.id_category = c.id_category
JOIN product_status ps ON p.id_status = ps.id_status;
