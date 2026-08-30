
-- Tabla de productos


-- Tabla de variantes por productos


-- Tabla de imágenes por variante de productos


-- Tabla de ventas


-- Tabla de items por venta


-- Tabla de perfiles de usuario (extensión de auth.users)
CREATE TABLE user_profiles (
    id              UUID            PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name       VARCHAR(255)    NOT NULL,
    phone           VARCHAR(50)     NULL,
    company_name    VARCHAR(255)    NULL,  -- Solo para mayoristas
    role_id         INTEGER         NOT NULL REFERENCES roles(role_id) DEFAULT 1, -- Default: customer
    cod_status      VARCHAR(2)      NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NULL
);

-- Tabla cara almacenar el carrito de compras

CREATE TABLE cart (
    id_user     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    id_variant  UUID        NOT NULL REFERENCES product_variants(id_variant) ON DELETE CASCADE,
    quantity    INTEGER     NOT NULL CHECK (quantity > 0) DEFAULT 1,
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL,
    
    PRIMARY KEY (id_user, id_variant)
);

-- ----------------------------------------------------------------------------
-- 4. ÍNDICES PARA MEJORAR PERFORMANCE
-- ----------------------------------------------------------------------------










CREATE INDEX idx_user_profiles_role     ON user_profiles(role_id);



CREATE INDEX idx_cart_user              ON cart(id_user);

-- ----------------------------------------------------------------------------
-- 5. FUNCIONES Y TRIGGERS PARA AUTOMATIZACIÓN
-- ----------------------------------------------------------------------------

-- Función para obtener el rol del usuario autenticado
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT
LANGUAGE SQL
SECURITY DEFINER  -- Ejecuta con permisos del creador (bypasea RLS)
SET search_path = public
AS $$
    SELECT 
        r.name
    FROM 
        user_profiles up
        JOIN roles r 
            ON up.role_id = r.role_id
    WHERE 
        up.id = auth.uid()
    LIMIT 
        1;
$$;

CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name, phone, role_id)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'phone', NULL),
        1  -- Default: customer
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que se ejecuta cuando se crea un user en auth.users
CREATE TRIGGER trg_create_user_profile
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_user_profile();

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER 
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;














CREATE TRIGGER trg_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_cart_updated_at
    BEFORE UPDATE ON cart
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();







-- ----------------------------------------------------------------------------
-- 7. VISTAS ÚTILES
-- ----------------------------------------------------------------------------

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
JOIN product_variants pv ON p.id_product = pv.id_product
JOIN sizes            s  ON pv.id_size   = s.id_size
WHERE pv.row_status = 'active'
  AND p.cod_status  = 'A'
ORDER BY p.id_product, s.sort_order;

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
JOIN product_variants   pv  ON vi.id_variant    = pv.id_variant
JOIN products           p   ON pv.id_product    = p.id_product
JOIN colors             c   ON pv.id_color      = c.id_color
JOIN sizes              s   ON pv.id_size       = s.id_size
WHERE vi.row_status = 'active'
ORDER BY vi.id_variant, vi.order_position;

-- Vista de detalle de producto
CREATE OR REPLACE VIEW v_product_detail
WITH (security_invoker = true)
AS
SELECT
    p.id_product,
    p.name                                AS product_name,
    p.short_desc,
    p.long_desc,
    p.base_price,
    cat.description                       AS category,
    p.cod_status                          AS status,

    COUNT(DISTINCT pv.id_variant)         AS total_variants,
    COUNT(DISTINCT pv.id_size)            AS total_sizes,
    COUNT(DISTINCT pv.id_color)           AS total_colors,
    COALESCE(SUM(pv.stock), 0)            AS total_stock,
    COALESCE(MIN(pv.price), p.base_price) AS min_price,
    COALESCE(MAX(pv.price), p.base_price) AS max_price,

    p.created_at,
    p.updated_at

FROM products   p
JOIN categories cat ON p.id_category = cat.id_category
LEFT JOIN product_variants pv ON p.id_product = pv.id_product
    AND pv.row_status = 'active'
WHERE p.row_status = 'active'
GROUP BY p.id_product, cat.description;

-- Política para que usuarios vean SOLO SUS ventas (si están logueados) O ventas anónimas con su mismo email
CREATE OR REPLACE VIEW v_users_with_roles
WITH (security_invoker = true)
AS
SELECT
    up.id,
    au.email,
    up.full_name,
    up.phone,
    up.company_name,
    r.name          AS role_name,
    r.description   AS role_description,
    up.cod_status   AS status,
    up.created_at,
    up.updated_at,
    au.last_sign_in_at,
    au.email_confirmed_at
FROM user_profiles up
    JOIN auth.users au 
        ON up.id = au.id
    JOIN roles r 
        ON up.role_id = r.role_id
WHERE up.row_status = 'active';

-- Función para obtener variante con imágenes
CREATE OR REPLACE FUNCTION get_variant_with_images(p_id_variant UUID)
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

-- Vista de ventas completas
CREATE OR REPLACE VIEW v_sales_complete 
WITH (security_invoker = true) 
AS
SELECT 
    s.id_sale,
    s.total,
    s.customer_name,
    s.customer_email,
    s.customer_phone,
    s.shipping_address,
    s.order_notes,
    ss.description AS sale_status,
    pm.description AS payment_method,
    ps.description AS payment_status,
    s.mp_payment_id,
    s.mp_preference_id,
    s.shipping_cost,
    s.created_at,
    s.date_completed,
    s.updated_at,
    (
        SELECT COUNT(*) 
        FROM sale_items si 
        WHERE si.id_sale = s.id_sale
    ) AS total_items
FROM sales s
JOIN sale_status        ss ON s.id_sale_status      = ss.id_status
JOIN payment_methods    pm ON s.id_payment_method   = pm.id_method
JOIN payment_status     ps ON s.id_payment_status   = ps.id_status;

-- Trae la información del carrito de compras de un usuario junto con toda la información necesaria para renderizar
CREATE OR REPLACE VIEW v_cart_complete
WITH (security_invoker = true)
AS
SELECT
    c.id_user,
    c.id_variant,
    c.quantity,
    c.created_at,
    c.updated_at,
    
    -- Info del producto
    p.id_product,
    p.name          AS product_name,
    pv.sku,
    pv.price,
    pv.stock,
    pv.cod_status   AS status,
    
    -- Info de color y talle
    col.description AS color_description,
    col.hex_code,
    sz.size,
    
    -- Imagen principal
    (
        SELECT image_url 
        FROM variant_images vi
        WHERE vi.id_variant = c.id_variant
          AND vi.row_status = 'active'
        ORDER BY vi.order_position
        LIMIT 1
    ) AS main_image,
    
    -- Subtotal calculado con precio actual
    (c.quantity * pv.price) AS subtotal,
    
    -- Validación de stock
    CASE 
        WHEN pv.stock >= c.quantity THEN true ELSE false
    END AS has_stock

FROM cart c
JOIN product_variants   pv  ON c.id_variant    = pv.id_variant
JOIN products           p   ON pv.id_product   = p.id_product
JOIN colors             col ON pv.id_color     = col.id_color
JOIN sizes              sz  ON pv.id_size      = sz.id_size;

-- Esta también es del carrito de compras pero hidrata la información de un carrito en el localstorage
CREATE OR REPLACE VIEW v_variant_public
WITH (security_invoker = false)  -- accesible para anónimos
AS
SELECT
    pv.id_variant,
    p.id_product,
    p.name              AS product_name,
    pv.sku,
    pv.price,
    pv.stock,

    -- Info de color y talle
    col.description     AS color_description,
    col.hex_code,
    sz.size,

    -- Imagen principal
    (
        SELECT image_url
        FROM variant_images vi
        WHERE vi.id_variant = pv.id_variant
          AND vi.row_status = 'active'
        ORDER BY vi.order_position
        LIMIT 1
    ) AS main_image

FROM product_variants pv
JOIN products   p   ON pv.id_product = p.id_product
JOIN colors     col ON pv.id_color   = col.id_color
JOIN sizes      sz  ON pv.id_size    = sz.id_size
WHERE pv.row_status = 'active';

-- ----------------------------------------------------------------------------
-- 8. COMENTARIOS
-- ----------------------------------------------------------------------------







COMMENT ON TABLE user_profiles                  IS 'Perfiles de usuario extendidos vinculados a auth.users';
COMMENT ON COLUMN user_profiles.id              IS 'FK a auth.users.id (mismo UUID)';
COMMENT ON COLUMN user_profiles.company_name    IS 'Nombre de empresa (solo para mayoristas)';
COMMENT ON COLUMN user_profiles.role_id         IS 'Rol del usuario (customer, wholesaler, admin, superadmin)';

COMMENT ON TABLE cart                           IS 'Carrito de compras de usuarios logueados';
COMMENT ON COLUMN cart.id_user                  IS 'Usuario dueño del carrito';
COMMENT ON COLUMN cart.id_variant               IS 'Variante del producto en el carrito';

COMMENT ON FUNCTION create_user_profile()       IS 'Auto-crea user_profile cuando se registra un nuevo usuario en auth.users';

COMMENT ON VIEW v_products_complete             IS 'Vista para homepage: 1 imagen por color';
COMMENT ON VIEW v_variants_by_size              IS 'Vista: Talle → Colores disponibles';
COMMENT ON VIEW v_variant_images                IS 'Imágenes de variante para carousel';
COMMENT ON VIEW v_users_with_roles              IS 'Vista de usuarios con información completa para panel admin';
COMMENT ON VIEW v_cart_complete                 IS 'Carrito con info completa de productos (precios/stock actualizados)';
COMMENT ON VIEW v_variant_public                IS 'Datos públicos de variantes activas, accesible para usuarios anónimos. Usada para hidratar el carrito desde localStorage.';




-- ESTE NO LO EJECUTO PORQUE DIÓ ERROR
COMMENT ON VIEW v_product_detail                IS 'Vista completa para detalle de producto';

-- ----------------------------------------------------------------------------
-- 9. GRANTS
-- ----------------------------------------------------------------------------

GRANT SELECT ON v_variant_public TO anon;