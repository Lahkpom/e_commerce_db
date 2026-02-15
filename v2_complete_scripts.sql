-- ============================================================================
-- SCRIPT SQL PARA ECOMMERCE - SUPABASE (PostgreSQL)
-- ============================================================================
-- VERSIÓN CORREGIDA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TABLAS PARAMÉTRICAS (Catálogos)
-- ----------------------------------------------------------------------------

-- Tabla de statuses general (paramétrica cerrada)
CREATE TABLE status (
    cod_status  VARCHAR(2)  PRIMARY KEY,
    description VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL
);

-- Tabla de categorías de productos
CREATE TABLE categories (
    id_category SERIAL      PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE, 
    description VARCHAR(50) NOT NULL UNIQUE,
    cod_status  VARCHAR(2)  NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL
);

-- Tabla de estados de ventas
CREATE TABLE sale_status (
    id_status   SERIAL      PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(50) NOT NULL UNIQUE,
    cod_status  VARCHAR(2)  NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL
);

-- Tabla de estados de pago
CREATE TABLE payment_status (
    id_status   SERIAL      PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(50) NOT NULL UNIQUE,
    cod_status  VARCHAR(2)  NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL
);

-- Tabla de métodos de pago
CREATE TABLE payment_methods (
    id_method   SERIAL      PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(50) NOT NULL UNIQUE,
    cod_status  VARCHAR(2)  NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL
);

-- Catálogo de talles
CREATE TABLE sizes (
    id_size     SERIAL      PRIMARY KEY,
    size        VARCHAR(10) NOT NULL, -- ❌ CORREGIDO: era VARCHAR(3), cambiado a VARCHAR(10) para soportar "XXXL"
    id_category INTEGER     NOT NULL REFERENCES categories(id_category),
    description TEXT        NULL,
    sort_order  INTEGER     NOT NULL DEFAULT 0,
    cod_status  VARCHAR(2)  NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL,

    CONSTRAINT uq_size_category UNIQUE (size, id_category)
);

-- Catálogo de colores
CREATE TABLE colors (
    id_color    SERIAL      PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL UNIQUE,
    hex_code    VARCHAR(7)   NOT NULL UNIQUE,
    cod_status  VARCHAR(2)   NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP    NULL
);

-- ----------------------------------------------------------------------------
-- 2. INSERTAR DATOS INICIALES EN TABLAS PARAMÉTRICAS
-- ----------------------------------------------------------------------------

-- Statuses generales
INSERT INTO status (cod_status, description) VALUES 
    ('A', 'active'),
    ('I', 'inactive'),
    ('D', 'deleted');

-- Categorías
INSERT INTO categories (name, description) VALUES 
    ('girls'    , 'niñas'),
    ('boys'     , 'niños'),
    ('men'      , 'hombres'),
    ('women'    , 'mujeres'),
    ('unisex'   , 'unisex');

-- Estados de ventas
INSERT INTO sale_status (name, description) VALUES 
    ('pending'  , 'pendiente'),
    ('preparing', 'preparando'),
    ('shipped'  , 'enviado'),
    ('delivered', 'entregado'),
    ('cancelled', 'cancelado');

-- Estados de pago
INSERT INTO payment_status (name, description) VALUES 
    ('pending'  , 'pendiente'),
    ('approved' , 'aprobado'),
    ('rejected' , 'rechazado'),
    ('refunded' , 'reembolsado');

-- Métodos de pago
INSERT INTO payment_methods (name, description) VALUES 
    ('mercadopago'  , 'mercado pago'),
    ('transfer'     , 'transferencia'),
    ('efective'     , 'efectivo');

-- Talles para Niños unisex (id_category = 5)
INSERT INTO sizes (size, id_category, description, sort_order) VALUES 
    ('18'   , 5, 'Talle 2 - Unisex - Aprox. 2 años'  , 1),
    ('19'   , 5, 'Talle 4 - Unisex - Aprox. 4 años'  , 2),
    ('20'   , 5, 'Talle 6 - Unisex - Aprox. 6 años'  , 3),
    ('21'   , 5, 'Talle 8 - Unisex - Aprox. 8 años'  , 4),
    ('22'   , 5, 'Talle 10 - Unisex - Aprox. 10 años', 5),
    ('23'   , 5, 'Talle 12 - Unisex - Aprox. 12 años', 6),
    ('24'   , 5, 'Talle 12 - Unisex - Aprox. 12 años', 7),
    ('25'   , 5, 'Talle 12 - Unisex - Aprox. 12 años', 8),
    ('26'   , 5, 'Talle 14 - Unisex - Aprox. 14 años', 9);

-- Talles para Hombres (id_category = 3) 35 al 45
INSERT INTO sizes (size, id_category, description, sort_order) VALUES 
    ('35'   , 3, 'Talle 35 - Hombre'    , 1),
    ('36'   , 3, 'Talle 36 - Hombre'    , 2),
    ('37'   , 3, 'Talle 37 - Hombre'    , 3),
    ('38'   , 3, 'Talle 38 - Hombre'    , 4),
    ('39'   , 3, 'Talle 39 - Hombre'    , 5),
    ('40'   , 3, 'Talle 40 - Hombre'    , 6),
    ('41'   , 3, 'Talle 41 - Hombre'    , 7),
    ('42'   , 3, 'Talle 42 - Hombre'    , 8),
    ('43'   , 3, 'Talle 43 - Hombre'    , 9),
    ('44'   , 3, 'Talle 44 - Hombre'    , 10),
    ('45'   , 3, 'Talle 45 - Hombre'    , 11),
    ('35/36', 3, 'Talle 35/36 - Hombre' , 1),
    ('37/38', 3, 'Talle 37/38 - Hombre' , 2),
    ('39/40', 3, 'Talle 39/40 - Hombre' , 3),
    ('41/42', 3, 'Talle 41/42 - Hombre' , 4),
    ('43/44', 3, 'Talle 43/44 - Hombre' , 5),
    ('45/46', 3, 'Talle 45/46 - Hombre' , 6);

-- Talles para Mujeres (id_category = 4) 35 al 40
INSERT INTO sizes (size, id_category, description, sort_order) VALUES 
    ('35'   , 4, 'Talle 35 - Mujer'     , 1),
    ('36'   , 4, 'Talle 36 - Mujer'     , 2),
    ('37'   , 4, 'Talle 37 - Mujer'     , 3),
    ('38'   , 4, 'Talle 38 - Mujer'     , 4),
    ('39'   , 4, 'Talle 39 - Mujer'     , 5),
    ('40'   , 4, 'Talle 40 - Mujer'     , 6),
    ('35/36', 4, 'Talle 35/36 - Mujer'  , 1),
    ('37/38', 4, 'Talle 37/38 - Mujer'  , 2),
    ('39/40', 4, 'Talle 39/40 - Mujer'  , 3);

-- Datos iniciales de colors
INSERT INTO colors (name, description, hex_code) VALUES 
    ('black'        , 'Negro'   , '#000000'),
    ('pink'         , 'Rosa'    , '#FFC0CB'),
    ('beige'        , 'Beige'   , '#F5F5DC'),
    ('white'        , 'Blanco'  , '#FFFFFF'),
    ('fuchsia'      , 'Fuxia'   , '#FF00FF'),
    ('brown'        , 'Marrón'  , '#A52A2A'),
    ('camel'        , 'Camel'   , '#C19A6B'),
    ('blue'         , 'Azul'    , '#0000FF'),
    ('saddlebrown'  , 'Suela'   , '#8B4513'),
    ('green'        , 'Verde'   , '#008000'),
    ('yellow'       , 'Amarillo', '#FFFF00'),
    ('orange'       , 'Naranja' , '#FFA500'),
    ('violet'       , 'Violeta' , '#EE82EE'),
    ('lilac'        , 'Lila'    , '#C8A2C8');

-- ----------------------------------------------------------------------------
-- 3. TABLAS PRINCIPALES
-- ----------------------------------------------------------------------------

-- Tabla de productos
CREATE TABLE products (
    id_product  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255)    NOT NULL UNIQUE,
    short_desc  VARCHAR(255)    NOT NULL,
    long_desc   TEXT            NOT NULL,
    base_price  DECIMAL(10, 2)  NOT NULL CHECK (base_price >= 0),
    id_category INTEGER         NOT NULL REFERENCES categories(id_category),
    cod_status  VARCHAR(2)      NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NULL
);

-- Tabla de variantes por productos
CREATE TABLE product_variants (
    id_variant  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    id_product  UUID            NOT NULL REFERENCES products(id_product) ON DELETE CASCADE,
    id_color    INTEGER         NOT NULL REFERENCES colors(id_color),
    id_size     INTEGER         NOT NULL REFERENCES sizes(id_size),
    sku         VARCHAR(100)    NOT NULL UNIQUE,
    price       DECIMAL(10, 2)  NOT NULL CHECK (price >= 0),
    stock       INTEGER         NOT NULL DEFAULT 0 CHECK (stock >= 0),
    cod_status  VARCHAR(2)      NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NULL,

    CONSTRAINT uq_product_color_size UNIQUE (id_product, id_color, id_size)
);

-- Tabla de imágenes por variante de productos
CREATE TABLE variant_images (
    id_image        UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    id_variant      UUID            NOT NULL REFERENCES product_variants(id_variant) ON DELETE CASCADE,
    image_url       VARCHAR(500)    NOT NULL,
    order_position  INTEGER         NOT NULL CHECK (order_position > 0),
    cod_status      VARCHAR(2)      NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NULL,

    CONSTRAINT uq_variant_order UNIQUE (id_variant, order_position)
);

-- Tabla de ventas
CREATE TABLE sales (
    id_sale             UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    total               DECIMAL(10, 2)  NOT NULL CHECK (total >= 0),
    date_completed      TIMESTAMP       NULL,
    customer_name       VARCHAR(255)    NOT NULL,
    customer_email      VARCHAR(255)    NULL,
    customer_phone      VARCHAR(50)     NOT NULL,
    shipping_address    TEXT            NOT NULL,
    order_notes         TEXT            NOT NULL DEFAULT '',
    id_sale_status      INTEGER         NOT NULL REFERENCES sale_status(id_status),
    id_payment_method   INTEGER         NOT NULL REFERENCES payment_methods(id_method),
    id_payment_status   INTEGER         NOT NULL REFERENCES payment_status(id_status),
    mp_payment_id       VARCHAR(100)    NULL,
    mp_preference_id    VARCHAR(100)    NULL,
    shipping_cost       DECIMAL(10, 2)  NOT NULL DEFAULT 0 CHECK (shipping_cost >= 0),
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP       NULL
);

-- Tabla de items por venta
CREATE TABLE sale_items (
    id_sale_item    UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sale         UUID            NOT NULL REFERENCES sales(id_sale) ON DELETE CASCADE,
    id_variant      UUID            NOT NULL REFERENCES product_variants(id_variant),
    product_name    VARCHAR(255)    NOT NULL,
    variant_desc    VARCHAR(255)    NOT NULL,
    sku             VARCHAR(100)    NOT NULL,
    unit_price      DECIMAL(10, 2)  NOT NULL CHECK (unit_price >= 0),
    quantity        INTEGER         NOT NULL CHECK (quantity > 0),
    subtotal        DECIMAL(10, 2)  NOT NULL CHECK (subtotal >= 0),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 4. ÍNDICES PARA MEJORAR PERFORMANCE
-- ----------------------------------------------------------------------------

CREATE INDEX idx_products_category      ON products(id_category);
CREATE INDEX idx_products_status        ON products(cod_status);

CREATE INDEX idx_variants_product       ON product_variants(id_product);
CREATE INDEX idx_variants_color         ON product_variants(id_color);
CREATE INDEX idx_variants_size          ON product_variants(id_size);
CREATE INDEX idx_variants_status        ON product_variants(cod_status);
CREATE INDEX idx_variants_sku           ON product_variants(sku);

CREATE INDEX idx_variant_images_variant ON variant_images(id_variant);
CREATE INDEX idx_variant_images_status  ON variant_images(cod_status);

CREATE INDEX idx_sales_status           ON sales(id_sale_status);
CREATE INDEX idx_sales_payment_status   ON sales(id_payment_status);
CREATE INDEX idx_sales_payment_method   ON sales(id_payment_method);
CREATE INDEX idx_sales_created_at       ON sales(created_at DESC);
CREATE INDEX idx_sales_customer_email   ON sales(customer_email);
CREATE INDEX idx_sales_mp_payment_id    ON sales(mp_payment_id);

CREATE INDEX idx_sale_items_sale        ON sale_items(id_sale);
CREATE INDEX idx_sale_items_variant     ON sale_items(id_variant);

-- ----------------------------------------------------------------------------
-- 5. FUNCIONES Y TRIGGERS PARA AUTOMATIZACIÓN
-- ----------------------------------------------------------------------------

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

-- Triggers para updated_at
CREATE TRIGGER trg_status_updated_at
    BEFORE UPDATE ON status
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_sale_status_updated_at
    BEFORE UPDATE ON sale_status
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_payment_status_updated_at
    BEFORE UPDATE ON payment_status
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_payment_methods_updated_at
    BEFORE UPDATE ON payment_methods
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_sizes_updated_at
    BEFORE UPDATE ON sizes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_colors_updated_at
    BEFORE UPDATE ON colors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_variants_updated_at
    BEFORE UPDATE ON product_variants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_variant_images_updated_at
    BEFORE UPDATE ON variant_images
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_sales_updated_at
    BEFORE UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Función para validar subtotal
CREATE OR REPLACE FUNCTION validate_sale_item_subtotal()
RETURNS TRIGGER 
SET search_path = public
AS $$
BEGIN
    IF NEW.subtotal != (NEW.unit_price * NEW.quantity) THEN
        RAISE EXCEPTION 'El subtotal debe ser igual a unit_price × quantity';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_subtotal
    BEFORE INSERT OR UPDATE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION validate_sale_item_subtotal();

-- Función para verificar stock
CREATE OR REPLACE FUNCTION check_variant_stock()
RETURNS TRIGGER 
SET search_path = public
AS $$
DECLARE
    available_stock INTEGER;
    variant_info VARCHAR;
BEGIN
    SELECT stock, sku INTO available_stock, variant_info
    FROM product_variants
    WHERE id_variant = NEW.id_variant;
    
    IF available_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Stock insuficiente para variante %. Disponible: %, Solicitado: %', 
            variant_info, available_stock, NEW.quantity;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_variant_stock
    BEFORE INSERT ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION check_variant_stock();

-- Función para reducir stock
CREATE OR REPLACE FUNCTION reduce_variant_stock()
RETURNS TRIGGER 
SET search_path = public
AS $$
BEGIN
    -- Solo reducir stock cuando el pago cambia a 'approved'
    IF NEW.id_payment_status = (SELECT id_status FROM payment_status WHERE name = 'approved')
       AND (OLD.id_payment_status IS NULL OR OLD.id_payment_status != NEW.id_payment_status) THEN
        
        UPDATE product_variants pv
        SET stock = stock - si.quantity
        FROM sale_items si
        WHERE si.id_sale    = NEW.id_sale
          AND si.id_variant = pv.id_variant;
          
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reduce_variant_stock
    AFTER UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION reduce_variant_stock();

-- ----------------------------------------------------------------------------
-- 6. POLÍTICAS RLS (Row Level Security) - SEGURIDAD
-- ----------------------------------------------------------------------------

-- Habilitar RLS en TODAS las tablas
ALTER TABLE status              ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories          ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_status         ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_status      ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods     ENABLE ROW LEVEL SECURITY;
ALTER TABLE sizes               ENABLE ROW LEVEL SECURITY;
ALTER TABLE colors              ENABLE ROW LEVEL SECURITY;
ALTER TABLE products            ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants    ENABLE ROW LEVEL SECURITY;
ALTER TABLE variant_images      ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales               ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items          ENABLE ROW LEVEL SECURITY;

-- Políticas públicas de lectura para tablas paramétricas
CREATE POLICY "Public read status"          ON status           FOR SELECT USING (true);

CREATE POLICY "Public read categories"      ON categories       FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read sale_status"     ON sale_status      FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read payment_status"  ON payment_status   FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read payment_methods" ON payment_methods  FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read sizes"           ON sizes            FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read colors"          ON colors           FOR SELECT USING (cod_status = 'A');

-- Políticas para products
CREATE POLICY "Public read active products" ON products         FOR SELECT USING (cod_status = 'A');

-- Políticas para product_variants
CREATE POLICY "Public read active variants" ON product_variants FOR SELECT USING (cod_status = 'A');

-- Políticas para variant_images
CREATE POLICY "Public read active images"   ON variant_images   FOR SELECT USING (cod_status = 'A');

-- Políticas para sales
CREATE POLICY "Public insert sales"         ON sales            FOR INSERT WITH CHECK (true);

CREATE POLICY "Public read sales"           ON sales            FOR SELECT USING (true);

-- Políticas para sale_items
CREATE POLICY "Public insert sale_items"    ON sale_items       FOR INSERT WITH CHECK (true);

CREATE POLICY "Public read sale_items"      ON sale_items       FOR SELECT USING (true);

-- ❌ NOTA: La política de "Read sale_items from accessible sales" no funcionará
-- porque los usuarios no están autenticados en Supabase (no hay JWT).
-- Por eso sale_items tiene lectura pública por ahora.
-- Cuando implementes auth, podés cambiar esta política.

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
                  AND pv2.cod_status = 'A'
            ) col
        ),
        '[]'::json
    ) AS color_images
    
FROM products p
JOIN categories             c   ON p.id_category    = c.id_category
LEFT JOIN product_variants  pv  ON p.id_product     = pv.id_product AND pv.cod_status = 'A'
WHERE p.cod_status = 'A'
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
WHERE pv.cod_status = 'A'
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
WHERE vi.cod_status = 'A'
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
        AND pv.cod_status = 'A'
    WHERE p.cod_status = 'A'
    GROUP BY p.id_product, cat.description;

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
                  AND vi.cod_status = 'A'
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

-- ----------------------------------------------------------------------------
-- 8. COMENTARIOS
-- ----------------------------------------------------------------------------

COMMENT ON TABLE products                       IS 'Catálogo de productos del ecommerce';
COMMENT ON COLUMN products.base_price           IS 'Precio base/referencia de producción';

COMMENT ON TABLE product_variants               IS 'Variantes: combinación producto + talle + color';
COMMENT ON COLUMN product_variants.price        IS 'Precio de venta al público';

COMMENT ON TABLE variant_images                 IS 'Imágenes de cada variante';
COMMENT ON COLUMN variant_images.order_position IS 'Orden (1 = principal)';

COMMENT ON TABLE sales                          IS 'Órdenes de compra';
COMMENT ON TABLE sale_items                     IS 'Items de cada venta (snapshot)';

COMMENT ON VIEW v_products_complete             IS 'Vista para homepage: 1 imagen por color';
COMMENT ON VIEW v_variants_by_size              IS 'Vista: Talle → Colores disponibles';
COMMENT ON VIEW v_variant_images                IS 'Imágenes de variante para carousel';

-- ESTE NO LO EJECUTO PORQUE DIÓ ERROR
COMMENT ON VIEW v_product_detail                IS 'Vista completa para detalle de producto';

-- ----------------------------------------------------------------------------
-- FIN DEL SCRIPT
-- ----------------------------------------------------------------------------





-- INSERTS DE PRUEBA PARA RELLENAR LA TABLA
-- INSERT de productos combinando todas las categorías (1-5) con artículos (1-5)
INSERT INTO products (name, short_desc, long_desc, base_price, id_category) VALUES
-- Categoría 1
('Art. 1 - Cat. 1', 'Descripción corta del Art. 1 - Cat. 1', 'Descripción larga del Artículo 1 en Categoría 1. Este es un producto de alta calidad diseñado para satisfacer todas tus necesidades.', 49.99, 1),
('Art. 2 - Cat. 1', 'Descripción corta del Art. 2 - Cat. 1', 'Descripción larga del Artículo 2 en Categoría 1. Características innovadoras que mejoran tu experiencia diaria.', 79.99, 1),
('Art. 3 - Cat. 1', 'Descripción corta del Art. 3 - Cat. 1', 'Descripción larga del Artículo 3 en Categoría 1. Diseño ergonómico y materiales premium para durabilidad.', 29.99, 1),
('Art. 4 - Cat. 1', 'Descripción corta del Art. 4 - Cat. 1', 'Descripción larga del Artículo 4 en Categoría 1. Tecnología de vanguardia con garantía extendida.', 99.99, 1),
('Art. 5 - Cat. 1', 'Descripción corta del Art. 5 - Cat. 1', 'Descripción larga del Artículo 5 en Categoría 1. Solución completa para profesionales exigentes.', 149.99, 1),

-- Categoría 2
('Art. 1 - Cat. 2', 'Descripción corta del Art. 1 - Cat. 2', 'Descripción larga del Artículo 1 en Categoría 2. Optimizado para máximo rendimiento en entornos exigentes.', 59.99, 2),
('Art. 2 - Cat. 2', 'Descripción corta del Art. 2 - Cat. 2', 'Descripción larga del Artículo 2 en Categoría 2. Diseño compacto con funcionalidades avanzadas.', 89.99, 2),
('Art. 3 - Cat. 2', 'Descripción corta del Art. 3 - Cat. 2', 'Descripción larga del Artículo 3 en Categoría 2. Versátil y adaptable a diferentes usos.', 39.99, 2),
('Art. 4 - Cat. 2', 'Descripción corta del Art. 4 - Cat. 2', 'Descripción larga del Artículo 4 en Categoría 2. Sistema inteligente con conectividad total.', 119.99, 2),
('Art. 5 - Cat. 2', 'Descripción corta del Art. 5 - Cat. 2', 'Descripción larga del Artículo 5 en Categoría 2. Producto flagship con todas las características premium.', 199.99, 2),

-- Categoría 3
('Art. 1 - Cat. 3', 'Descripción corta del Art. 1 - Cat. 3', 'Descripción larga del Artículo 1 en Categoría 3. Esencial para el día a día con diseño minimalista.', 44.99, 3),
('Art. 2 - Cat. 3', 'Descripción corta del Art. 2 - Cat. 3', 'Descripción larga del Artículo 2 en Categoría 3. Combinación perfecta de estilo y funcionalidad.', 74.99, 3),
('Art. 3 - Cat. 3', 'Descripción corta del Art. 3 - Cat. 3', 'Descripción larga del Artículo 3 en Categoría 3. Resistentes a condiciones extremas de uso.', 34.99, 3),
('Art. 4 - Cat. 3', 'Descripción corta del Art. 4 - Cat. 3', 'Descripción larga del Artículo 4 en Categoría 3. Innovación tecnológica certificada.', 109.99, 3),
('Art. 5 - Cat. 3', 'Descripción corta del Art. 5 - Cat. 3', 'Descripción larga del Artículo 5 en Categoría 3. Solución integral para necesidades especializadas.', 179.99, 3),

-- Categoría 4
('Art. 1 - Cat. 4', 'Descripción corta del Art. 1 - Cat. 4', 'Descripción larga del Artículo 1 en Categoría 4. Fabricado con materiales ecológicos y sostenibles.', 54.99, 4),
('Art. 2 - Cat. 4', 'Descripción corta del Art. 2 - Cat. 4', 'Descripción larga del Artículo 2 en Categoría 4. Diseño modular para personalización total.', 84.99, 4),
('Art. 3 - Cat. 4', 'Descripción corta del Art. 3 - Cat. 4', 'Descripción larga del Artículo 3 en Categoría 4. Portátil y fácil de almacenar.', 37.99, 4),
('Art. 4 - Cat. 4', 'Descripción corta del Art. 4 - Cat. 4', 'Descripción larga del Artículo 4 en Categoría 4. Compatible con sistemas de tercera generación.', 129.99, 4),
('Art. 5 - Cat. 4', 'Descripción corta del Art. 5 - Cat. 4', 'Descripción larga del Artículo 5 en Categoría 4. Incluye accesorios premium y manual detallado.', 219.99, 4),

-- Categoría 5
('Art. 1 - Cat. 5', 'Descripción corta del Art. 1 - Cat. 5', 'Descripción larga del Artículo 1 en Categoría 5. Perfecto para usuarios principiantes.', 39.99, 5),
('Art. 2 - Cat. 5', 'Descripción corta del Art. 2 - Cat. 5', 'Descripción larga del Artículo 2 en Categoría 5. Balance ideal entre precio y calidad.', 69.99, 5),
('Art. 3 - Cat. 5', 'Descripción corta del Art. 3 - Cat. 5', 'Descripción larga del Artículo 3 en Categoría 5. Mantenimiento mínimo y alta durabilidad.', 27.99, 5),
('Art. 4 - Cat. 5', 'Descripción corta del Art. 4 - Cat. 5', 'Descripción larga del Artículo 4 en Categoría 5. Sistema automatizado con control remoto.', 89.99, 5),
('Art. 5 - Cat. 5', 'Descripción corta del Art. 5 - Cat. 5', 'Descripción larga del Artículo 5 en Categoría 5. Edición limitada con certificado de autenticidad.', 159.99, 5);


-- Insertar variantes para productos de calzado (categorías 3, 4)
-- Los productos de categoría 3 (calzado hombre) usan talles 10-26 (id: 10-26)
-- Los productos de categoría 4 (calzado mujer) usan talles 27-40 (id: 27-40)
-- Los productos de categoría 5 (niños) usan talles 1-9 (id: 1-9)

INSERT INTO product_variants (id_product, id_color, id_size, sku, price, stock, cod_status) VALUES
-- Producto 1: Art. 1 - Cat. 1 (Supongamos que es calzado hombre - usar talles hombre)
('30896883-a0e1-4779-80b4-be99eafd7375', 1, 15, 'ART1-CAT1-BLK-40', 89.99, 25, 'A'),  -- Negro, talle 40
('30896883-a0e1-4779-80b4-be99eafd7375', 4, 16, 'ART1-CAT1-WHT-41', 89.99, 20, 'A'),  -- Blanco, talle 41
('30896883-a0e1-4779-80b4-be99eafd7375', 8, 17, 'ART1-CAT1-BLU-42', 89.99, 18, 'A'),  -- Azul, talle 42
('30896883-a0e1-4779-80b4-be99eafd7375', 6, 18, 'ART1-CAT1-BRN-43', 89.99, 15, 'A'),  -- Marrón, talle 43
('30896883-a0e1-4779-80b4-be99eafd7375', 3, 19, 'ART1-CAT1-BGE-44', 89.99, 12, 'A'),  -- Beige, talle 44

-- Producto 2: Art. 2 - Cat. 1
('c88c3873-e65b-410d-95f2-290687891e4f', 4, 15, 'ART2-CAT1-WHT-40', 109.99, 30, 'A'),
('c88c3873-e65b-410d-95f2-290687891e4f', 1, 16, 'ART2-CAT1-BLK-41', 109.99, 25, 'A'),
('c88c3873-e65b-410d-95f2-290687891e4f', 10, 17, 'ART2-CAT1-GRN-42', 109.99, 22, 'A'),
('c88c3873-e65b-410d-95f2-290687891e4f', 12, 18, 'ART2-CAT1-ORG-43', 109.99, 18, 'A'),

-- Producto 3: Art. 3 - Cat. 1
('1396ff9e-9cb4-4840-affa-0ec29d4e8131', 8, 16, 'ART3-CAT1-BLU-41', 79.99, 15, 'A'),
('1396ff9e-9cb4-4840-affa-0ec29d4e8131', 1, 17, 'ART3-CAT1-BLK-42', 79.99, 20, 'A'),
('1396ff9e-9cb4-4840-affa-0ec29d4e8131', 4, 18, 'ART3-CAT1-WHT-43', 79.99, 18, 'A'),
('1396ff9e-9cb4-4840-affa-0ec29d4e8131', 6, 19, 'ART3-CAT1-BRN-44', 79.99, 12, 'A'),

-- Producto 4: Art. 4 - Cat. 1
('2d9438e6-ff1d-44d0-9042-85786d01885a', 1, 15, 'ART4-CAT1-BLK-40', 129.99, 8, 'A'),
('2d9438e6-ff1d-44d0-9042-85786d01885a', 4, 16, 'ART4-CAT1-WHT-41', 129.99, 10, 'A'),
('2d9438e6-ff1d-44d0-9042-85786d01885a', 8, 17, 'ART4-CAT1-BLU-42', 129.99, 6, 'A'),
('2d9438e6-ff1d-44d0-9042-85786d01885a', 3, 18, 'ART4-CAT1-BGE-43', 129.99, 5, 'A'),

-- Producto 5: Art. 5 - Cat. 1
('a6c5f810-b40d-4dbd-a14f-1f3c7731467c', 4, 16, 'ART5-CAT1-WHT-41', 159.99, 5, 'A'),
('a6c5f810-b40d-4dbd-a14f-1f3c7731467c', 1, 17, 'ART5-CAT1-BLK-42', 159.99, 7, 'A'),
('a6c5f810-b40d-4dbd-a14f-1f3c7731467c', 8, 18, 'ART5-CAT1-BLU-43', 159.99, 4, 'A'),

-- Producto 6: Art. 1 - Cat. 2 (Calzado mujer - talles 27-32, 38-40)
('8d582c40-9223-4e9f-b549-8e2484616c63', 2, 27, 'ART1-CAT2-PNK-35', 94.99, 20, 'A'),   -- Rosa, talle 35 mujer
('8d582c40-9223-4e9f-b549-8e2484616c63', 4, 28, 'ART1-CAT2-WHT-36', 94.99, 22, 'A'),   -- Blanco, talle 36
('8d582c40-9223-4e9f-b549-8e2484616c63', 13, 29, 'ART1-CAT2-VLT-37', 94.99, 18, 'A'),  -- Violeta, talle 37
('8d582c40-9223-4e9f-b549-8e2484616c63', 5, 30, 'ART1-CAT2-FUX-38', 94.99, 15, 'A'),   -- Fuxia, talle 38
('8d582c40-9223-4e9f-b549-8e2484616c63', 14, 31, 'ART1-CAT2-LIL-39', 94.99, 12, 'A'),  -- Lila, talle 39

-- Producto 7: Art. 2 - Cat. 2
('c83b56de-fd30-434f-b332-69931f2415a0', 4, 28, 'ART2-CAT2-WHT-36', 114.99, 25, 'A'),
('c83b56de-fd30-434f-b332-69931f2415a0', 1, 29, 'ART2-CAT2-BLK-37', 114.99, 20, 'A'),
('c83b56de-fd30-434f-b332-69931f2415a0', 13, 30, 'ART2-CAT2-VLT-38', 114.99, 18, 'A'),
('c83b56de-fd30-434f-b332-69931f2415a0', 2, 31, 'ART2-CAT2-PNK-39', 114.99, 15, 'A'),

-- Producto 8: Art. 3 - Cat. 2
('5877b3a3-216d-4ec5-8981-30d6146e1c68', 3, 29, 'ART3-CAT2-BGE-37', 84.99, 18, 'A'),
('5877b3a3-216d-4ec5-8981-30d6146e1c68', 4, 30, 'ART3-CAT2-WHT-38', 84.99, 22, 'A'),
('5877b3a3-216d-4ec5-8981-30d6146e1c68', 8, 31, 'ART3-CAT2-BLU-39', 84.99, 20, 'A'),
('5877b3a3-216d-4ec5-8981-30d6146e1c68', 1, 32, 'ART3-CAT2-BLK-40', 84.99, 16, 'A'),

-- Producto 9: Art. 4 - Cat. 2
('8e2ca035-9a77-4e7b-ac52-65feead35813', 4, 28, 'ART4-CAT2-WHT-36', 134.99, 10, 'A'),
('8e2ca035-9a77-4e7b-ac52-65feead35813', 13, 29, 'ART4-CAT2-VLT-37', 134.99, 8, 'A'),
('8e2ca035-9a77-4e7b-ac52-65feead35813', 5, 30, 'ART4-CAT2-FUX-38', 134.99, 6, 'A'),
('8e2ca035-9a77-4e7b-ac52-65feead35813', 2, 31, 'ART4-CAT2-PNK-39', 134.99, 7, 'A'),

-- Producto 10: Art. 5 - Cat. 2
('fac89514-ea0e-4999-9ef9-c797f8d94d7e', 13, 29, 'ART5-CAT2-VLT-37', 164.99, 6, 'A'),
('fac89514-ea0e-4999-9ef9-c797f8d94d7e', 4, 30, 'ART5-CAT2-WHT-38', 164.99, 8, 'A'),
('fac89514-ea0e-4999-9ef9-c797f8d94d7e', 1, 31, 'ART5-CAT2-BLK-39', 164.99, 5, 'A'),

-- Producto 11: Art. 1 - Cat. 3 (Calzado hombre - talles combinados 21-26)
('bc899056-face-4905-bec9-e627d96e1251', 1, 21, 'ART1-CAT3-BLK-35/36', 99.99, 20, 'A'),   -- Negro, talle 35/36
('bc899056-face-4905-bec9-e627d96e1251', 4, 22, 'ART1-CAT3-WHT-37/38', 99.99, 22, 'A'),   -- Blanco, talle 37/38
('bc899056-face-4905-bec9-e627d96e1251', 8, 23, 'ART1-CAT3-BLU-39/40', 99.99, 18, 'A'),   -- Azul, talle 39/40
('bc899056-face-4905-bec9-e627d96e1251', 6, 24, 'ART1-CAT3-BRN-41/42', 99.99, 15, 'A'),   -- Marrón, talle 41/42
('bc899056-face-4905-bec9-e627d96e1251', 3, 25, 'ART1-CAT3-BGE-43/44', 99.99, 12, 'A'),   -- Beige, talle 43/44

-- Producto 12: Art. 2 - Cat. 3
('d18b8ebd-888e-4433-b81f-bdbd597a4674', 4, 21, 'ART2-CAT3-WHT-35/36', 119.99, 25, 'A'),
('d18b8ebd-888e-4433-b81f-bdbd597a4674', 1, 22, 'ART2-CAT3-BLK-37/38', 119.99, 20, 'A'),
('d18b8ebd-888e-4433-b81f-bdbd597a4674', 10, 23, 'ART2-CAT3-GRN-39/40', 119.99, 18, 'A'),
('d18b8ebd-888e-4433-b81f-bdbd597a4674', 12, 24, 'ART2-CAT3-ORG-41/42', 119.99, 15, 'A'),

-- Producto 13: Art. 3 - Cat. 3
('579f4b25-ad07-4d9f-a584-f7f35377a96e', 8, 22, 'ART3-CAT3-BLU-37/38', 89.99, 18, 'A'),
('579f4b25-ad07-4d9f-a584-f7f35377a96e', 1, 23, 'ART3-CAT3-BLK-39/40', 89.99, 22, 'A'),
('579f4b25-ad07-4d9f-a584-f7f35377a96e', 4, 24, 'ART3-CAT3-WHT-41/42', 89.99, 20, 'A'),
('579f4b25-ad07-4d9f-a584-f7f35377a96e', 6, 25, 'ART3-CAT3-BRN-43/44', 89.99, 16, 'A'),

-- Producto 14: Art. 4 - Cat. 3
('7c052b5e-e3ba-4a14-a7c4-fb6c052f09e9', 1, 21, 'ART4-CAT3-BLK-35/36', 139.99, 10, 'A'),
('7c052b5e-e3ba-4a14-a7c4-fb6c052f09e9', 4, 22, 'ART4-CAT3-WHT-37/38', 139.99, 8, 'A'),
('7c052b5e-e3ba-4a14-a7c4-fb6c052f09e9', 8, 23, 'ART4-CAT3-BLU-39/40', 139.99, 6, 'A'),
('7c052b5e-e3ba-4a14-a7c4-fb6c052f09e9', 3, 24, 'ART4-CAT3-BGE-41/42', 139.99, 7, 'A'),

-- Producto 15: Art. 5 - Cat. 3
('d89b73f3-e972-4281-be66-ec4fbe5588df', 4, 22, 'ART5-CAT3-WHT-37/38', 169.99, 6, 'A'),
('d89b73f3-e972-4281-be66-ec4fbe5588df', 1, 23, 'ART5-CAT3-BLK-39/40', 169.99, 8, 'A'),
('d89b73f3-e972-4281-be66-ec4fbe5588df', 8, 24, 'ART5-CAT3-BLU-41/42', 169.99, 5, 'A'),

-- Producto 16: Art. 1 - Cat. 4 (Calzado mujer - talles combinados 38-40)
('22affd5d-ffa3-4e95-9083-1ad56234c47b', 2, 38, 'ART1-CAT4-PNK-35/36', 104.99, 20, 'A'),   -- Rosa, talle 35/36 mujer
('22affd5d-ffa3-4e95-9083-1ad56234c47b', 4, 39, 'ART1-CAT4-WHT-37/38', 104.99, 22, 'A'),   -- Blanco, talle 37/38
('22affd5d-ffa3-4e95-9083-1ad56234c47b', 13, 40, 'ART1-CAT4-VLT-39/40', 104.99, 18, 'A'),  -- Violeta, talle 39/40
('22affd5d-ffa3-4e95-9083-1ad56234c47b', 5, 38, 'ART1-CAT4-FUX-35/36', 104.99, 15, 'A'),   -- Fuxia, talle 35/36
('22affd5d-ffa3-4e95-9083-1ad56234c47b', 14, 39, 'ART1-CAT4-LIL-37/38', 104.99, 12, 'A'),  -- Lila, talle 37/38

-- Producto 17: Art. 2 - Cat. 4
('5e7644ae-31e8-450c-b90b-7da3efe29ec8', 4, 38, 'ART2-CAT4-WHT-35/36', 124.99, 25, 'A'),
('5e7644ae-31e8-450c-b90b-7da3efe29ec8', 1, 39, 'ART2-CAT4-BLK-37/38', 124.99, 20, 'A'),
('5e7644ae-31e8-450c-b90b-7da3efe29ec8', 13, 40, 'ART2-CAT4-VLT-39/40', 124.99, 18, 'A'),
('5e7644ae-31e8-450c-b90b-7da3efe29ec8', 2, 38, 'ART2-CAT4-PNK-35/36', 124.99, 15, 'A'),

-- Producto 18: Art. 3 - Cat. 4
('699e117e-7c37-4ef6-aa92-665aae6270d4', 3, 39, 'ART3-CAT4-BGE-37/38', 94.99, 18, 'A'),
('699e117e-7c37-4ef6-aa92-665aae6270d4', 4, 40, 'ART3-CAT4-WHT-39/40', 94.99, 22, 'A'),
('699e117e-7c37-4ef6-aa92-665aae6270d4', 8, 38, 'ART3-CAT4-BLU-35/36', 94.99, 20, 'A'),
('699e117e-7c37-4ef6-aa92-665aae6270d4', 1, 39, 'ART3-CAT4-BLK-37/38', 94.99, 16, 'A'),

-- Producto 19: Art. 4 - Cat. 4
('fc98c637-5f36-447e-a1a5-90123709ab48', 4, 38, 'ART4-CAT4-WHT-35/36', 144.99, 10, 'A'),
('fc98c637-5f36-447e-a1a5-90123709ab48', 13, 39, 'ART4-CAT4-VLT-37/38', 144.99, 8, 'A'),
('fc98c637-5f36-447e-a1a5-90123709ab48', 5, 40, 'ART4-CAT4-FUX-39/40', 144.99, 6, 'A'),
('fc98c637-5f36-447e-a1a5-90123709ab48', 2, 38, 'ART4-CAT4-PNK-35/36', 144.99, 7, 'A'),

-- Producto 20: Art. 5 - Cat. 4
('1b8190a2-d12b-4909-a628-5e81b1e7fbab', 13, 39, 'ART5-CAT4-VLT-37/38', 174.99, 6, 'A'),
('1b8190a2-d12b-4909-a628-5e81b1e7fbab', 4, 40, 'ART5-CAT4-WHT-39/40', 174.99, 8, 'A'),
('1b8190a2-d12b-4909-a628-5e81b1e7fbab', 1, 38, 'ART5-CAT4-BLK-35/36', 174.99, 5, 'A'),

-- Producto 21: Art. 1 - Cat. 5 (Niños - talles 1-9)
('b720e6e7-fb46-4a57-9800-d1eb32d96e77', 8, 1, 'ART1-CAT5-BLU-18', 64.99, 30, 'A'),   -- Azul, talle 18 niños
('b720e6e7-fb46-4a57-9800-d1eb32d96e77', 4, 2, 'ART1-CAT5-WHT-19', 64.99, 35, 'A'),   -- Blanco, talle 19
('b720e6e7-fb46-4a57-9800-d1eb32d96e77', 10, 3, 'ART1-CAT5-GRN-20', 64.99, 28, 'A'),   -- Verde, talle 20
('b720e6e7-fb46-4a57-9800-d1eb32d96e77', 11, 4, 'ART1-CAT5-YLW-21', 64.99, 25, 'A'),   -- Amarillo, talle 21
('b720e6e7-fb46-4a57-9800-d1eb32d96e77', 12, 5, 'ART1-CAT5-ORG-22', 64.99, 22, 'A'),   -- Naranja, talle 22

-- Producto 22: Art. 2 - Cat. 5
('bf2e9c93-5753-4968-8382-546cf6894f38', 4, 2, 'ART2-CAT5-WHT-19', 84.99, 40, 'A'),
('bf2e9c93-5753-4968-8382-546cf6894f38', 8, 3, 'ART2-CAT5-BLU-20', 84.99, 35, 'A'),
('bf2e9c93-5753-4968-8382-546cf6894f38', 10, 4, 'ART2-CAT5-GRN-21', 84.99, 30, 'A'),
('bf2e9c93-5753-4968-8382-546cf6894f38', 11, 5, 'ART2-CAT5-YLW-22', 84.99, 28, 'A'),

-- Producto 23: Art. 3 - Cat. 5
('0dd189e0-e206-460e-987c-cc3479495787', 8, 3, 'ART3-CAT5-BLU-20', 54.99, 30, 'A'),
('0dd189e0-e206-460e-987c-cc3479495787', 4, 4, 'ART3-CAT5-WHT-21', 54.99, 38, 'A'),
('0dd189e0-e206-460e-987c-cc3479495787', 10, 5, 'ART3-CAT5-GRN-22', 54.99, 32, 'A'),
('0dd189e0-e206-460e-987c-cc3479495787', 11, 6, 'ART3-CAT5-YLW-23', 54.99, 25, 'A'),

-- Producto 24: Art. 4 - Cat. 5
('f4c90390-6cec-4ac1-9ab4-ae2183df22ea', 4, 4, 'ART4-CAT5-WHT-21', 104.99, 20, 'A'),
('f4c90390-6cec-4ac1-9ab4-ae2183df22ea', 8, 5, 'ART4-CAT5-BLU-22', 104.99, 18, 'A'),
('f4c90390-6cec-4ac1-9ab4-ae2183df22ea', 10, 6, 'ART4-CAT5-GRN-23', 104.99, 15, 'A'),
('f4c90390-6cec-4ac1-9ab4-ae2183df22ea', 11, 7, 'ART4-CAT5-YLW-24', 104.99, 12, 'A'),

-- Producto 25: Art. 5 - Cat. 5
('4cbee8dc-4abd-4547-89e2-c3ff3dd251ff', 8, 5, 'ART5-CAT5-BLU-22', 134.99, 15, 'A'),
('4cbee8dc-4abd-4547-89e2-c3ff3dd251ff', 4, 6, 'ART5-CAT5-WHT-23', 134.99, 18, 'A'),
('4cbee8dc-4abd-4547-89e2-c3ff3dd251ff', 10, 7, 'ART5-CAT5-GRN-24', 134.99, 12, 'A'),
('4cbee8dc-4abd-4547-89e2-c3ff3dd251ff', 11, 8, 'ART5-CAT5-YLW-25', 134.99, 10, 'A');




-- Insertar 5 imágenes para cada variante con URLs aleatorias
INSERT INTO variant_images (id_variant, image_url, order_position, cod_status) VALUES
-- Variante 1
('8f298e68-18f6-4ee5-861f-8ea6478d1f1e', '/assets/images/productsContainer/children/product2_img1.jpg', 1, 'A'),
('8f298e68-18f6-4ee5-861f-8ea6478d1f1e', '/assets/images/productsContainer/children/product2_img2.jpg', 2, 'A'),
('8f298e68-18f6-4ee5-861f-8ea6478d1f1e', '/assets/images/productsContainer/children/product2_img3.jpg', 3, 'A'),
('8f298e68-18f6-4ee5-861f-8ea6478d1f1e', '/assets/images/productsContainer/children/product2_img1.jpg', 4, 'A'),
('8f298e68-18f6-4ee5-861f-8ea6478d1f1e', '/assets/images/productsContainer/children/product2_img2.jpg', 5, 'A'),

-- Variante 2
('daf0c7d1-4cae-4b1b-b7a4-35808a753016', '/assets/images/productsContainer/children/product2_img3.jpg', 1, 'A'),
('daf0c7d1-4cae-4b1b-b7a4-35808a753016', '/assets/images/productsContainer/children/product2_img1.jpg', 2, 'A'),
('daf0c7d1-4cae-4b1b-b7a4-35808a753016', '/assets/images/productsContainer/children/product2_img2.jpg', 3, 'A'),
('daf0c7d1-4cae-4b1b-b7a4-35808a753016', '/assets/images/productsContainer/children/product2_img3.jpg', 4, 'A'),
('daf0c7d1-4cae-4b1b-b7a4-35808a753016', '/assets/images/productsContainer/children/product2_img1.jpg', 5, 'A'),

-- Variante 3
('d45100fc-c6b8-45c3-a1f5-97145af572f2', '/assets/images/productsContainer/children/product2_img2.jpg', 1, 'A'),
('d45100fc-c6b8-45c3-a1f5-97145af572f2', '/assets/images/productsContainer/children/product2_img3.jpg', 2, 'A'),
('d45100fc-c6b8-45c3-a1f5-97145af572f2', '/assets/images/productsContainer/children/product2_img1.jpg', 3, 'A'),
('d45100fc-c6b8-45c3-a1f5-97145af572f2', '/assets/images/productsContainer/children/product2_img2.jpg', 4, 'A'),
('d45100fc-c6b8-45c3-a1f5-97145af572f2', '/assets/images/productsContainer/children/product2_img3.jpg', 5, 'A'),

-- Variante 4
('70291369-3a95-4db4-9275-0212a04c74c8', '/assets/images/productsContainer/children/product2_img1.jpg', 1, 'A'),
('70291369-3a95-4db4-9275-0212a04c74c8', '/assets/images/productsContainer/children/product2_img2.jpg', 2, 'A'),
('70291369-3a95-4db4-9275-0212a04c74c8', '/assets/images/productsContainer/children/product2_img3.jpg', 3, 'A'),
('70291369-3a95-4db4-9275-0212a04c74c8', '/assets/images/productsContainer/children/product2_img1.jpg', 4, 'A'),
('70291369-3a95-4db4-9275-0212a04c74c8', '/assets/images/productsContainer/children/product2_img2.jpg', 5, 'A'),

-- Variante 5
('7fa5ee73-6bb2-48e5-88eb-c6a8267b6fe1', '/assets/images/productsContainer/children/product2_img3.jpg', 1, 'A'),
('7fa5ee73-6bb2-48e5-88eb-c6a8267b6fe1', '/assets/images/productsContainer/children/product2_img1.jpg', 2, 'A'),
('7fa5ee73-6bb2-48e5-88eb-c6a8267b6fe1', '/assets/images/productsContainer/children/product2_img2.jpg', 3, 'A'),
('7fa5ee73-6bb2-48e5-88eb-c6a8267b6fe1', '/assets/images/productsContainer/children/product2_img3.jpg', 4, 'A'),
('7fa5ee73-6bb2-48e5-88eb-c6a8267b6fe1', '/assets/images/productsContainer/children/product2_img1.jpg', 5, 'A'),

-- Variante 6
('f20b7e36-d9dc-414f-9483-ba4deb228ed2', '/assets/images/productsContainer/children/product2_img2.jpg', 1, 'A'),
('f20b7e36-d9dc-414f-9483-ba4deb228ed2', '/assets/images/productsContainer/children/product2_img3.jpg', 2, 'A'),
('f20b7e36-d9dc-414f-9483-ba4deb228ed2', '/assets/images/productsContainer/children/product2_img1.jpg', 3, 'A'),
('f20b7e36-d9dc-414f-9483-ba4deb228ed2', '/assets/images/productsContainer/children/product2_img2.jpg', 4, 'A'),
('f20b7e36-d9dc-414f-9483-ba4deb228ed2', '/assets/images/productsContainer/children/product2_img3.jpg', 5, 'A'),

-- Variante 7
('238f21bf-6cb7-41bb-b1f2-8b44a0bf745d', '/assets/images/productsContainer/children/product2_img1.jpg', 1, 'A'),
('238f21bf-6cb7-41bb-b1f2-8b44a0bf745d', '/assets/images/productsContainer/children/product2_img2.jpg', 2, 'A'),
('238f21bf-6cb7-41bb-b1f2-8b44a0bf745d', '/assets/images/productsContainer/children/product2_img3.jpg', 3, 'A'),
('238f21bf-6cb7-41bb-b1f2-8b44a0bf745d', '/assets/images/productsContainer/children/product2_img1.jpg', 4, 'A'),
('238f21bf-6cb7-41bb-b1f2-8b44a0bf745d', '/assets/images/productsContainer/children/product2_img2.jpg', 5, 'A'),

-- Variante 8
('aabe9745-727b-4afa-8f2d-6bed67b7f095', '/assets/images/productsContainer/children/product2_img3.jpg', 1, 'A'),
('aabe9745-727b-4afa-8f2d-6bed67b7f095', '/assets/images/productsContainer/children/product2_img1.jpg', 2, 'A'),
('aabe9745-727b-4afa-8f2d-6bed67b7f095', '/assets/images/productsContainer/children/product2_img2.jpg', 3, 'A'),
('aabe9745-727b-4afa-8f2d-6bed67b7f095', '/assets/images/productsContainer/children/product2_img3.jpg', 4, 'A'),
('aabe9745-727b-4afa-8f2d-6bed67b7f095', '/assets/images/productsContainer/children/product2_img1.jpg', 5, 'A'),

-- Variante 9
('b94546c4-0b13-487c-8da3-be69dad28076', '/assets/images/productsContainer/children/product2_img2.jpg', 1, 'A'),
('b94546c4-0b13-487c-8da3-be69dad28076', '/assets/images/productsContainer/children/product2_img3.jpg', 2, 'A'),
('b94546c4-0b13-487c-8da3-be69dad28076', '/assets/images/productsContainer/children/product2_img1.jpg', 3, 'A'),
('b94546c4-0b13-487c-8da3-be69dad28076', '/assets/images/productsContainer/children/product2_img2.jpg', 4, 'A'),
('b94546c4-0b13-487c-8da3-be69dad28076', '/assets/images/productsContainer/children/product2_img3.jpg', 5, 'A'),

-- Variante 10
('98bc9773-15b4-468c-96ee-702809e15393', '/assets/images/productsContainer/children/product2_img1.jpg', 1, 'A'),
('98bc9773-15b4-468c-96ee-702809e15393', '/assets/images/productsContainer/children/product2_img2.jpg', 2, 'A'),
('98bc9773-15b4-468c-96ee-702809e15393', '/assets/images/productsContainer/children/product2_img3.jpg', 3, 'A'),
('98bc9773-15b4-468c-96ee-702809e15393', '/assets/images/productsContainer/children/product2_img1.jpg', 4, 'A'),
('98bc9773-15b4-468c-96ee-702809e15393', '/assets/images/productsContainer/children/product2_img2.jpg', 5, 'A');
