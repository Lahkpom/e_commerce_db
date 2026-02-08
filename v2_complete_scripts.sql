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
    ('41'   , 4, 'Talle 41 - Mujer'     , 7),
    ('42'   , 4, 'Talle 42 - Mujer'     , 8),
    ('43'   , 4, 'Talle 43 - Mujer'     , 9),
    ('44'   , 4, 'Talle 44 - Mujer'     , 10),
    ('45'   , 4, 'Talle 45 - Mujer'     , 11),
    ('35/36', 4, 'Talle 35/36 - Mujer'  , 1),
    ('37/38', 4, 'Talle 37/38 - Mujer'  , 2),
    ('39/40', 4, 'Talle 39/40 - Mujer'  , 3),
    ('41/42', 4, 'Talle 41/42 - Mujer'  , 4),
    ('43/44', 4, 'Talle 43/44 - Mujer'  , 5),
    ('45/46', 4, 'Talle 45/46 - Mujer'  , 6);

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
        WHERE si.id_sale = NEW.id_sale
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
CREATE POLICY "Public read status" ON status
    FOR SELECT USING (true);

CREATE POLICY "Public read categories" ON categories
    FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read sale_status" ON sale_status
    FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read payment_status" ON payment_status
    FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read payment_methods" ON payment_methods
    FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read sizes" ON sizes
    FOR SELECT USING (cod_status = 'A');

CREATE POLICY "Public read colors" ON colors
    FOR SELECT USING (cod_status = 'A');

-- Políticas para products
CREATE POLICY "Public read active products" ON products
    FOR SELECT USING (cod_status = 'A');

-- Políticas para product_variants
CREATE POLICY "Public read active variants" ON product_variants
    FOR SELECT USING (cod_status = 'A');

-- Políticas para variant_images
CREATE POLICY "Public read active images" ON variant_images
    FOR SELECT USING (cod_status = 'A');

-- Políticas para sales
CREATE POLICY "Public insert sales" ON sales
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Public read sales" ON sales
    FOR SELECT USING (true);

-- Políticas para sale_items
CREATE POLICY "Public insert sale_items" ON sale_items
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Public read sale_items" ON sale_items
    FOR SELECT USING (true);

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
    p.name AS product_name,
    p.short_desc,
    p.long_desc,
    p.base_price,
    c.description AS category,
    p.cod_status AS status,
    
    -- Stock total
    COALESCE(SUM(pv.stock), 0) AS total_stock,
    
    -- Rango de precios
    COALESCE(MIN(pv.price), p.base_price) AS min_price,
    COALESCE(MAX(pv.price), p.base_price) AS max_price,
    
    -- Metadata
    COUNT(DISTINCT pv.id_variant) AS variant_count,
    COUNT(DISTINCT pv.id_color) AS color_count,
    COUNT(DISTINCT pv.id_size) AS size_count,
    
    p.created_at,
    p.updated_at,
    
    -- ✅ Array de imágenes: UNA por COLOR (sin repetir)
    COALESCE(
        (
            SELECT json_agg(
                json_build_object(
                    'id_color', col.id_color,
                    'color_name', col.name,
                    'color_description', col.description,
                    'hex_code', col.hex_code,
                    'image_url', (
                        -- Seleccionar la primera imagen de cualquier variante con este color
                        SELECT vi.image_url
                        FROM product_variants pv_inner
                        JOIN variant_images vi ON vi.id_variant = pv_inner.id_variant
                        WHERE pv_inner.id_product = p.id_product
                          AND pv_inner.id_color = col.id_color
                          AND pv_inner.cod_status = 'A'
                          AND vi.cod_status = 'A'
                        ORDER BY vi.order_position
                        LIMIT 1
                    )
                )
                ORDER BY col.id_color
            )
            FROM (
                -- Obtener colores únicos del producto
                SELECT DISTINCT c.id_color, c.name, c.description, c.hex_code
                FROM product_variants pv2
                JOIN colors c ON pv2.id_color = c.id_color
                WHERE pv2.id_product = p.id_product
                  AND pv2.cod_status = 'A'
            ) col
        ),
        '[]'::json
    ) AS color_images
    
FROM products p
JOIN categories c ON p.id_category = c.id_category
LEFT JOIN product_variants pv ON p.id_product = pv.id_product 
    AND pv.cod_status = 'A'
WHERE p.cod_status = 'A'
GROUP BY p.id_product, c.description;

-- Vista organizada: Producto → Talles → Colores
CREATE OR REPLACE VIEW v_variants_by_size WITH (security_invoker = true) AS
SELECT 
    p.id_product,
    p.name AS product_name,
    s.id_size,
    s.size,
    s.sort_order,
    s.description AS size_description,
    
    -- Colores disponibles en este talle
    json_agg(
        json_build_object(
            'id_variant', pv.id_variant,
            'id_color', c.id_color,
            'color_name', c.name,
            'color_description', c.description,
            'hex_code', c.hex_code,
            'stock', pv.stock,
            'price', pv.price,
            'sku', pv.sku,
            'main_image', (
                SELECT image_url
                FROM variant_images vi
                WHERE vi.id_variant = pv.id_variant
                  AND vi.cod_status = 'A'
                ORDER BY vi.order_position
                LIMIT 1
            )
        )
        ORDER BY c.id_color
    ) AS available_colors
    
FROM products p
JOIN product_variants pv ON p.id_product = pv.id_product
JOIN sizes s ON pv.id_size = s.id_size
JOIN colors c ON pv.id_color = c.id_color
WHERE pv.cod_status = 'A'
GROUP BY p.id_product, p.name, s.id_size, s.size, s.sort_order, s.description
ORDER BY p.id_product, s.sort_order;

-- Vista de imágenes de variante específica
CREATE OR REPLACE VIEW v_variant_images WITH (security_invoker = true) AS
SELECT 
    vi.id_image,
    vi.id_variant,
    vi.image_url,
    vi.order_position,
    vi.cod_status AS status,
    
    pv.id_product,
    p.name AS product_name,
    c.name AS color_name,
    c.description AS color_description,
    c.hex_code,
    s.size,
    s.description AS size_description,
    
    vi.created_at
FROM variant_images vi
JOIN product_variants pv ON vi.id_variant = pv.id_variant
JOIN products p ON pv.id_product = p.id_product
JOIN colors c ON pv.id_color = c.id_color
JOIN sizes s ON pv.id_size = s.id_size
WHERE vi.cod_status = 'A'
ORDER BY vi.id_variant, vi.order_position;























-- HASTA ACÁ LLEGUÉ EN LA EJECUSIÓN PORQUE ME DIÓ UN ERROR


-- Vista de detalle de producto
CREATE OR REPLACE VIEW v_product_detail WITH (security_invoker = true) AS
SELECT 
    p.id_product,
    p.name AS product_name,
    p.short_desc,
    p.long_desc,
    p.base_price,
    cat.description AS category,
    p.cod_status AS status,
    
    COUNT(DISTINCT pv.id_variant) AS total_variants,
    COUNT(DISTINCT pv.id_size) AS total_sizes,
    COUNT(DISTINCT pv.id_color) AS total_colors,
    COALESCE(SUM(pv.stock), 0) AS total_stock,
    COALESCE(MIN(pv.price), p.base_price) AS min_price,
    COALESCE(MAX(pv.price), p.base_price) AS max_price,
    
    -- Talles disponibles
    COALESCE(
        json_agg(DISTINCT 
            json_build_object(
                'id_size', s.id_size,
                'size', s.size,
                'description', s.description,
                'sort_order', s.sort_order
            )
            ORDER BY json_build_object(
                'id_size', s.id_size,
                'size', s.size,
                'description', s.description,
                'sort_order', s.sort_order
            )->>'sort_order'
        ) FILTER (WHERE s.id_size IS NOT NULL),
        '[]'::json
    ) AS available_sizes,
    
    p.created_at,
    p.updated_at
    
FROM products p
JOIN categories cat ON p.id_category = cat.id_category
LEFT JOIN product_variants pv ON p.id_product = pv.id_product
    AND pv.cod_status = 'A'
LEFT JOIN sizes s ON pv.id_size = s.id_size
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
        'id_variant', pv.id_variant,
        'id_product', pv.id_product,
        'product_name', p.name,
        'sku', pv.sku,
        'price', pv.price,
        'stock', pv.stock,
        'color', json_build_object(
            'id_color', c.id_color,
            'name', c.name,
            'description', c.description,
            'hex_code', c.hex_code
        ),
        'size', json_build_object(
            'id_size', s.id_size,
            'size', s.size,
            'description', s.description
        ),
        'images', COALESCE(
            (
                SELECT json_agg(
                    json_build_object(
                        'id_image', vi.id_image,
                        'image_url', vi.image_url,
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
    JOIN products p ON pv.id_product = p.id_product
    JOIN colors c ON pv.id_color = c.id_color
    JOIN sizes s ON pv.id_size = s.id_size
    WHERE pv.id_variant = p_id_variant;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Vista de variantes completas
CREATE OR REPLACE VIEW v_product_variants_complete WITH (security_invoker = true) AS
SELECT 
    pv.id_variant,
    pv.id_product,
    p.name AS product_name,
    p.short_desc AS product_short_desc,
    p.long_desc AS product_long_desc,
    pv.sku,
    pv.price,
    pv.stock,
    
    col.id_color,
    col.name AS color_name,
    col.description AS color_desc,
    col.hex_code,
    
    sz.id_size,
    sz.size,
    sz.description AS size_desc,
    sz.sort_order,
    
    cat.description AS category,
    pv.cod_status AS status,
    
    (
        SELECT image_url 
        FROM variant_images vi 
        WHERE vi.id_variant = pv.id_variant 
        AND vi.cod_status = 'A'
        ORDER BY vi.order_position 
        LIMIT 1
    ) AS main_image,
    
    (
        SELECT COUNT(*)
        FROM variant_images vi 
        WHERE vi.id_variant = pv.id_variant 
        AND vi.cod_status = 'A'
    ) AS image_count,
    
    pv.created_at,
    pv.updated_at
    
FROM product_variants pv
JOIN products p ON pv.id_product = p.id_product
JOIN colors col ON pv.id_color = col.id_color
JOIN sizes sz ON pv.id_size = sz.id_size
JOIN categories cat ON p.id_category = cat.id_category;

-- Vista de ventas completas
CREATE OR REPLACE VIEW v_sales_complete WITH (security_invoker = true) AS
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
JOIN sale_status ss ON s.id_sale_status = ss.id_status
JOIN payment_methods pm ON s.id_payment_method = pm.id_method
JOIN payment_status ps ON s.id_payment_status = ps.id_status;

-- ----------------------------------------------------------------------------
-- 8. COMENTARIOS
-- ----------------------------------------------------------------------------

COMMENT ON TABLE products IS 'Catálogo de productos del ecommerce';
COMMENT ON COLUMN products.base_price IS 'Precio base/referencia de producción';

COMMENT ON TABLE product_variants IS 'Variantes: combinación producto + talle + color';
COMMENT ON COLUMN product_variants.price IS 'Precio de venta al público';

COMMENT ON TABLE variant_images IS 'Imágenes de cada variante';
COMMENT ON COLUMN variant_images.order_position IS 'Orden (1 = principal)';

COMMENT ON TABLE sales IS 'Órdenes de compra';
COMMENT ON TABLE sale_items IS 'Items de cada venta (snapshot)';

COMMENT ON VIEW v_products_complete IS 'Vista para homepage: 1 imagen por color';
COMMENT ON VIEW v_variants_by_size IS 'Vista: Talle → Colores disponibles';
COMMENT ON VIEW v_variant_images IS 'Imágenes de variante para carousel';
COMMENT ON VIEW v_product_detail IS 'Vista completa para detalle de producto';

-- ----------------------------------------------------------------------------
-- FIN DEL SCRIPT
-- ----------------------------------------------------------------------------