-- Función para obtener variante con imágenes
CREATE OR REPLACE FUNCTION get_variant_with_images (p_id_variant UUID)
RETURNS json 
SET search_path = public
AS $$
DECLARE
    result json;
BEGIN
    SELECT json_build_object(
        'id_variant'    , pv.id_variant,
        'id_product'    , pv.id_product,
        'product_name'  , p.name,
        'sku'           , pv.sku,
        'price'         , pv.price,
        'stock'         , pv.stock,

        'color', json_build_object(
            'id_color'      , c.id_color,
            'name'          , c.name,
            'description'   , c.description,
            'hex_code'      , c.hex_code
        ),

        'size', json_build_object(
            'id_size'       , s.id_size,
            'size'          , s.size,
            'description'   , s.description
        ),

        'images', COALESCE(
            (
                SELECT json_agg(
                    json_build_object(
                        'id_image'      , vi.id_image,
                        'image_url'     , vi.image_url,
                        'order_position', vi.order_position
                    )
                    ORDER BY vi.order_position
                )
                FROM variant_images vi
                WHERE vi.id_variant = pv.id_variant
                  AND vi.row_status = 'active'
            ),
            '[]'::json
        )
    ) INTO result
    FROM product_variants pv
    JOIN products   p ON pv.id_product  = p.id_product
    JOIN colors     c ON pv.id_color    = c.id_color
    JOIN sizes      s ON pv.id_size     = s.id_size
    WHERE pv.id_variant = p_id_variant;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;