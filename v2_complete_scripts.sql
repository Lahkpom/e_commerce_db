-- ============================================================================
-- SCRIPT SQL PARA ECOMMERCE - SUPABASE (PostgreSQL)
-- ============================================================================
-- Ejecutar en orden secuencial
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TABLAS PARAMÉTRICAS (Catálogos)
-- ----------------------------------------------------------------------------

-- Tabla de statuses general (paramétrica cerrada) 'A', 'active' | 'I', 'inactive' | 'D', 'deleted'
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
    size        VARCHAR(3)  NOT NULL UNIQUE,
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
    id_color    SERIAL PRIMARY KEY,
    name        VARCHAR(50)     NOT NULL UNIQUE,
    description VARCHAR(100)    NOT NULL UNIQUE,
    hex_code    VARCHAR(7)      NOT NULL UNIQUE,
    cod_status  VARCHAR(2)      NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NULL
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

-- Talles para Niños (unisex) (id_category = 5)
INSERT INTO sizes (size, id_category, description, sort_order, cod_status) VALUES 
    ('2'    , 5, 'Talle 2 - Aprox. 2 años'  , 1, 'A'),
    ('4'    , 5, 'Talle 4 - Aprox. 4 años'  , 2, 'A'),
    ('6'    , 5, 'Talle 6 - Aprox. 6 años'  , 3, 'A'),
    ('8'    , 5, 'Talle 8 - Aprox. 8 años'  , 4, 'A'),
    ('10'   , 5, 'Talle 10 - Aprox. 10 años', 5, 'A'),
    ('12'   , 5, 'Talle 12 - Aprox. 12 años', 6, 'A'),
    ('14'   , 5, 'Talle 14 - Aprox. 14 años', 7, 'A');

-- Talles para Hombres (id_category = 2)
INSERT INTO sizes (size, id_category, description, sort_order, cod_status) VALUES 
    ('XS'   , 2, 'Extra Small'  , 1, 'A'),
    ('S'    , 2, 'Small'        , 2, 'A'),
    ('M'    , 2, 'Medium'       , 3, 'A'),
    ('L'    , 2, 'Large'        , 4, 'A'),
    ('XL'   , 2, 'Extra Large'  , 5, 'A'),
    ('XXL'  , 2, '2X Large'     , 6, 'A'),
    ('XXXL' , 2, '3X Large'     , 7, 'A');

-- Talles para Mujeres (id_category = 3)
INSERT INTO sizes (size, id_category, description, sort_order, cod_status) VALUES 
    ('XS'   , 3, 'Extra Small'  , 1, 'A'),
    ('S'    , 3, 'Small'        , 2, 'A'),
    ('M'    , 3, 'Medium'       , 3, 'A'),
    ('L'    , 3, 'Large'        , 4, 'A'),
    ('XL'   , 3, 'Extra Large'  , 5, 'A'),
    ('XXL'  , 3, '2X Large'     , 6, 'A');

-- Datos iniciales de colors
INSERT INTO colors (name, description, hex_code, cod_status) VALUES 
    ('red'      , 'Rojo'        , '#FF0000', 'A'),
    ('blue'     , 'Azul'        , '#0000FF', 'A'),
    ('green'    , 'Verde'       , '#00FF00', 'A'),
    ('black'    , 'Negro'       , '#000000', 'A'),
    ('white'    , 'Blanco'      , '#FFFFFF', 'A'),
    ('yellow'   , 'Amarillo'    , '#FFFF00', 'A'),
    ('pink'     , 'Rosa'        , '#FF69B4', 'A'),
    ('gray'     , 'Gris'        , '#808080', 'A'),
    ('brown'    , 'Marrón'      , '#8B4513', 'A'),
    ('orange'   , 'Naranja'     , '#FFA500', 'A'),
    ('purple'   , 'Violeta'     , '#800080', 'A'),
    ('beige'    , 'Beige'       , '#F5F5DC', 'A'),
    ('navy'     , 'Azul Marino' , '#000080', 'A'),
    ('turquoise', 'Turquesa'    , '#40E0D0', 'A');

-- ----------------------------------------------------------------------------
-- 3. TABLAS PRINCIPALES
-- ----------------------------------------------------------------------------

-- Tabla de productos
CREATE TABLE products (
    id_product      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255)    NOT NULL UNIQUE,
    short_desc      VARCHAR(255)    NOT NULL,
    long_desc       TEXT            NOT NULL,
    base_price      DECIMAL(10, 2)  NOT NULL CHECK (base_price >= 0),
    id_category     INTEGER         NOT NULL REFERENCES categories(id_category),
    cod_status      VARCHAR(2)      NOT NULL REFERENCES status(cod_status) DEFAULT 'A',
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NULL,
    
    CONSTRAINT chk_base_price_positive CHECK (base_price >= 0)
);

-- Tabla de variantes por productos (Talles por cada productos y colores por cada talle)
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
    id_sale_item    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sale         UUID NOT NULL REFERENCES sales(id_sale) ON DELETE CASCADE,
    id_variant      UUID NOT NULL REFERENCES product_variants(id_variant),
    
    -- Snapshot al momento de la venta
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

-- Índices en products
CREATE INDEX idx_products_category      ON products(id_category);
CREATE INDEX idx_products_status        ON products(cod_status);
CREATE INDEX idx_products_sku           ON products(sku);

-- Índices en product_variants
CREATE INDEX idx_variants_product       ON product_variants(id_product);
CREATE INDEX idx_variants_color         ON product_variants(id_color);
CREATE INDEX idx_variants_size          ON product_variants(id_size);
CREATE INDEX idx_variants_status        ON product_variants(cod_status);
CREATE INDEX idx_variants_sku           ON product_variants(sku);

-- Índices en variant_images
CREATE INDEX idx_variant_images_variant ON variant_images(id_variant);
CREATE INDEX idx_variant_images_status  ON variant_images(cod_status);

-- Índices en sales
CREATE INDEX idx_sales_status           ON sales(id_sale_status);
CREATE INDEX idx_sales_payment_status   ON sales(id_payment_status);
CREATE INDEX idx_sales_payment_method   ON sales(id_payment_method);
CREATE INDEX idx_sales_created_at       ON sales(created_at DESC);
CREATE INDEX idx_sales_customer_email   ON sales(customer_email);
CREATE INDEX idx_sales_mp_payment_id    ON sales(mp_payment_id);

-- Índices en sale_items
CREATE INDEX idx_sale_items_sale        ON sale_items(id_sale);
CREATE INDEX idx_sale_items_variant     ON sale_items(id_variant);

-- ----------------------------------------------------------------------------
-- 5. FUNCIONES Y TRIGGERS PARA AUTOMATIZACIÓN
-- ----------------------------------------------------------------------------

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para products
CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para updated_at
CREATE TRIGGER trg_variants_updated_at
    BEFORE UPDATE ON product_variants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para sales
CREATE TRIGGER trg_sales_updated_at
    BEFORE UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Función para validar que el subtotal sea correcto
CREATE OR REPLACE FUNCTION validate_sale_item_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subtotal != (NEW.unit_price * NEW.quantity) THEN
        RAISE EXCEPTION 'El subtotal debe ser igual a unit_price × quantity';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar subtotal en sale_items
CREATE TRIGGER trg_validate_subtotal
    BEFORE INSERT OR UPDATE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION validate_sale_item_subtotal();

-- Función para validar stock antes de crear un sale_item
CREATE OR REPLACE FUNCTION check_variant_stock()
RETURNS TRIGGER AS $$
DECLARE
    available_stock INTEGER;
    variant_info VARCHAR;
BEGIN
    SELECT stock, pv.sku INTO available_stock, variant_info
    FROM product_variants pv
    WHERE pv.id_variant = NEW.id_variant;
    
    IF available_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Stock insuficiente para variante %. Disponible: %, Solicitado: %', 
            variant_info, available_stock, NEW.quantity;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar stock
CREATE TRIGGER trg_check_variant_stock
    BEFORE INSERT ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION check_variant_stock();

-- Función para reducir stock automáticamente al confirmar venta
CREATE OR REPLACE FUNCTION reduce_variant_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_payment_status = (SELECT id_status FROM payment_status WHERE description = 'approved')
       AND OLD.id_payment_status != NEW.id_payment_status THEN
        
        UPDATE product_variants pv
        SET stock = stock - si.quantity
        FROM sale_items si
        WHERE si.id_sale = NEW.id_sale
          AND si.id_variant = pv.id_variant;
          
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para reducir stock cuando se aprueba el pago
CREATE TRIGGER trg_reduce_variant_stock
    AFTER UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION reduce_variant_stock();

-- ----------------------------------------------------------------------------
-- 6. POLÍTICAS RLS (Row Level Security) - SEGURIDAD
-- ----------------------------------------------------------------------------

-- Habilitar RLS en todas las tablas principales
ALTER TABLE products            ENABLE ROW LEVEL SECURITY;
ALTER TABLE variant_images      ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales               ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items          ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants    ENABLE ROW LEVEL SECURITY;

-- Política para products: lectura pública de productos activos
CREATE POLICY "Public read active products" ON products
    FOR SELECT
    USING (cod_status = 'A');

-- Política para product_variants: lectura pública de variantes activas con stock
CREATE POLICY "Public read active variants" ON product_variants
    FOR SELECT
    USING (cod_status = 'A');

-- Política para variant_images: lectura pública de imágenes activas
CREATE POLICY "Public read active images" ON variant_images
    FOR SELECT
    USING (cod_status = 'A');

-- Política para sales: inserción pública (crear órdenes)
CREATE POLICY "Public insert sales" ON sales
    FOR INSERT
    WITH CHECK (true);

-- Política para sales: lectura solo por email (el cliente puede ver sus propias órdenes)
CREATE POLICY "Read own sales" ON sales
    FOR SELECT
    USING (customer_email = current_setting('request.jwt.claims', true)::json->>'email');

-- Política para sale_items: inserción pública
CREATE POLICY "Public insert sale_items" ON sale_items
    FOR INSERT
    WITH CHECK (true);

-- Política para sale_items: lectura basada en acceso a la venta
CREATE POLICY "Read sale_items from accessible sales" ON sale_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sales s 
            WHERE s.id_sale = sale_items.id_sale 
            AND s.customer_email = current_setting('request.jwt.claims', true)::json->>'email'
        )
    );

-- ----------------------------------------------------------------------------
-- 7. COMENTARIOS EN TABLAS Y COLUMNAS (DOCUMENTACIÓN)
-- ----------------------------------------------------------------------------

COMMENT ON TABLE products                           IS 'Catálogo de productos del ecommerce';
COMMENT ON COLUMN products.base_price               IS 'Precio aproximado del costo de producción.';
COMMENT ON COLUMN products.sku                      IS 'Código único de producto (Stock Keeping Unit)';

COMMENT ON TABLE product_variants                   IS 'Variantes de productos: cada combinación de producto + talle + color';
COMMENT ON COLUMN product_variants.price            IS 'Precio a mostrar al cliente';

COMMENT ON TABLE variant_images                     IS 'Imágenes específicas de cada variante (ej: foto del producto en color rojo)';
COMMENT ON COLUMN variant_images.order_position     IS 'Orden de visualización (1 = imagen principal)';

COMMENT ON TABLE sales                              IS 'Registro de ventas/órdenes de compra';
COMMENT ON COLUMN sales.mp_payment_id               IS 'ID de transacción de Mercado Pago';
COMMENT ON COLUMN sales.mp_preference_id            IS 'ID de preferencia de Mercado Pago';

COMMENT ON TABLE sale_items                         IS 'Items individuales de cada venta (snapshot de productos al momento de venta)';
COMMENT ON COLUMN sale_items.product_name           IS 'Nombre del producto al momento de la venta (snapshot)';
COMMENT ON COLUMN sale_items.variant_description    IS 'Descripción de la variante (ej: "Rojo - Talle M")';
COMMENT ON COLUMN sale_items.unit_price             IS 'Precio unitario al momento de la venta (snapshot)';

COMMENT ON VIEW v_products_for_listing              IS 'Vista para listado de productos en homepage. Incluye array de imágenes de variantes para carousel.';
COMMENT ON VIEW v_variants_by_size                  IS 'Vista organizada por TALLE → COLORES. Ideal para selector de variantes.';
COMMENT ON VIEW v_variant_images                    IS 'Todas las imágenes de cada variante para carousels.';
COMMENT ON VIEW v_product_detail                    IS 'Vista completa para página de detalle de producto.';

-- ----------------------------------------------------------------------------
-- 8. VISTAS ÚTILES
-- ----------------------------------------------------------------------------

-- Vista de productos con información completa (Está desactualizada, ver si aún sirve o si es reemplazada con otra)
CREATE OR REPLACE VIEW v_products_complete AS
SELECT 
    p.id_product,
    p.name_product,
    p.description,
    p.price,
    c.description AS category,
    p.stock,
    p.sku,
    ps.description AS status,
    p.created_at,
    p.updated_at,
    (
        SELECT image_url 
        FROM variant_images pi
        JOIN product_variants pv ON pi.id_variant = pv.id_variant
        WHERE pi.id_product = p.id_product 
        AND pi.cod_status = 'A'
        AND pi.order_position = 1
    ) AS main_image
FROM products p
JOIN categories c ON p.id_category = c.id_category
JOIN product_status ps ON p.id_status = ps.id_status;

-- Vista de productos con stock disponible y rango de precios (reemplaza a la anterior?)
-- Tener en cuenta que lo que quiero es que me devuelva la información del producto en general, junto con:
-- Quiero una imagen de cada color que el producto tenga (Aún cuando el producto no esté disponible en ese color (no en colores no existan en el producto).)
-- Es decir que main_images debe devolver un conjunto de imágenes con una imagen por color que tenga declarado el producto y sin repetir.
-- Quiero mantenerle a esta view el nombre v_products_complete. 
-- No quiero una imagen por variantes como dijimos antes, sino una imagen por color. Entonces si un producto tiene 3 colores, quiero que me devuelva 
-- 3 imágenes (1 por cada color) aunque el producto tenga 10 variantes (combinaciones de colores y talles).
CREATE OR REPLACE VIEW v_products_for_listing AS
SELECT 
    p.id_product,
    p.name AS product_name,
    p.description,
    p.base_price,
    c.description AS category,
    ps.description AS status,
    p.sku_prefix,
    
    -- Stock total de todas las variantes
    COALESCE(SUM(pv.stock), 0) AS total_stock,
    
    -- Rango de precios
    MIN(pv.price) AS min_price,
    MAX(pv.price) AS max_price,
    
    -- Cantidad de variantes, colores y talles
    COUNT(DISTINCT pv.id_variant) AS variant_count,
    COUNT(DISTINCT pv.id_color) AS color_count,
    COUNT(DISTINCT pv.id_size) AS size_count,
    
    p.created_at,
    p.updated_at,
    
    -- Array de imágenes principales de cada variante (para carousel en homepage)
    COALESCE(
        (
            SELECT json_agg(
                json_build_object(
                    'id_variant', pv2.id_variant,
                    'image_url', vi.image_url,
                    'color_name', col.name,
                    'color_description', col.description,
                    'hex_code', col.hex_code
                )
                ORDER BY col.id_color
            )
            FROM product_variants pv2
            JOIN colors col ON pv2.id_color = col.id_color
            LEFT JOIN LATERAL (
                SELECT image_url
                FROM variant_images vi2
                WHERE vi2.id_variant = pv2.id_variant
                  AND vi2.cod_status = 'A'
                ORDER BY vi2.order_position
                LIMIT 1
            ) vi ON true
            WHERE pv2.id_product = p.id_product
              AND pv2.cod_status = 'A'
            GROUP BY pv2.id_variant, col.id_color, col.name, col.description, col.hex_code, vi.image_url
        ),
        '[]'::json
    ) AS variant_images
    
FROM products p
JOIN categories c ON p.id_category = c.id_category
JOIN product_status ps ON p.id_status = ps.id_status
LEFT JOIN product_variants pv ON p.id_product = pv.id_product 
    AND pv.cod_status = 'A'
GROUP BY p.id_product, c.description, ps.description;

-- Esta vista organiza: Producto → Talles → Colores disponibles en cada talle
CREATE OR REPLACE VIEW v_variants_by_size AS
SELECT 
    p.id_product,
    p.name AS product_name,
    s.id_size,
    s.size,
    s.sort_order,
    s.description AS size_description,
    
    -- Array de colores disponibles en este talle
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
GROUP BY p.id_product, p.name AS product_name, s.id_size, s.size, s.sort_order, s.description
ORDER BY p.id_product, s.sort_order;

-- Esta vista trae todas las imágenes de una variante específica (para usar cuando se ingresa a la vista de un producto en específico y se 
-- selecciona una variante)
CREATE OR REPLACE VIEW v_variant_images AS
SELECT 
    vi.id_image,
    vi.id_variant,
    vi.image_url,
    vi.order_position,
    vis.description AS status,
    
    -- Info de la variante
    pv.id_product,
    p.name_product,
    c.name AS color_name,
    c.description AS color_description,
    c.hex_code,
    s.size,
    s.description AS size_description,
    
    vi.created_at
FROM variant_images vi
JOIN image_status vis ON vi.id_status = vis.id_status
JOIN product_variants pv ON vi.id_variant = pv.id_variant
JOIN products p ON pv.id_product = p.id_product
JOIN colors c ON pv.id_color = c.id_color
JOIN sizes s ON pv.id_size = s.id_size
WHERE vi.id_status = (SELECT id_status FROM image_status WHERE description = 'active')
ORDER BY vi.id_variant, vi.order_position;

-- Esta vista trae todo lo necesario para la página de detalle de producto
CREATE OR REPLACE VIEW v_product_detail AS
SELECT 
    p.id_product,
    p.name_product,
    p.description,
    p.base_price,
    p.sku_prefix,
    cat.description AS category,
    ps.description AS status,
    
    -- Metadata de variantes
    COUNT(DISTINCT pv.id_variant) AS total_variants,
    COUNT(DISTINCT pv.id_size) AS total_sizes,
    COUNT(DISTINCT pv.id_color) AS total_colors,
    COALESCE(SUM(pv.stock), 0) AS total_stock,
    MIN(pv.price) AS min_price,
    MAX(pv.price) AS max_price,
    
    -- Array de talles disponibles
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
    ) FILTER (WHERE s.id_size IS NOT NULL) AS available_sizes,
    
    p.created_at,
    p.updated_at
    
FROM products p
JOIN categories cat ON p.id_category = cat.id_category
JOIN product_status ps ON p.id_status = ps.id_status
LEFT JOIN product_variants pv ON p.id_product = pv.id_product
    AND pv.id_status = (SELECT id_status FROM product_status WHERE description = 'active')
LEFT JOIN sizes s ON pv.id_size = s.id_size
GROUP BY p.id_product, cat.description, ps.description;

-- Función auxiliar para obtener una variante con todas sus imágenes
CREATE OR REPLACE FUNCTION get_variant_with_images(p_id_variant UUID)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_build_object(
        'id_variant', pv.id_variant,
        'id_product', pv.id_product,
        'product_name', p.name_product,
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
                  AND vi.id_status = (SELECT id_status FROM image_status WHERE description = 'active')
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

CREATE OR REPLACE VIEW v_product_variants_complete AS
SELECT 
    pv.id_variant,
    pv.id_product,
    p.name_product,
    p.description AS product_description,
    p.sku_prefix,
    pv.sku,
    pv.price,
    pv.stock,
    
    -- Color info
    col.id_color,
    col.name AS color_name,
    col.description AS color_description,
    col.hex_code,
    
    -- Size info
    sz.id_size,
    sz.size,
    sz.description AS size_description,
    sz.sort_order,
    
    -- Category
    cat.description AS category,
    
    -- Status
    ps.description AS status,
    
    -- Main image de la variante
    (
        SELECT image_url 
        FROM variant_images vi 
        WHERE vi.id_variant = pv.id_variant 
        AND vi.id_status = (SELECT id_status FROM image_status WHERE description = 'active')
        ORDER BY vi.order_position 
        LIMIT 1
    ) AS main_image,
    
    -- Cantidad de imágenes
    (
        SELECT COUNT(*)
        FROM variant_images vi 
        WHERE vi.id_variant = pv.id_variant 
        AND vi.id_status = (SELECT id_status FROM image_status WHERE description = 'active')
    ) AS image_count,
    
    pv.created_at,
    pv.updated_at
    
FROM product_variants pv
JOIN products p ON pv.id_product = p.id_product
JOIN colors col ON pv.id_color = col.id_color
JOIN sizes sz ON pv.id_size = sz.id_size
JOIN categories cat ON p.id_category = cat.id_category
JOIN product_status ps ON pv.id_status = ps.id_status;

-- Vista de variantes completas (Esta vista no es útil por ahora, la dejo igualmente pero será utilizada por los admins cuando los haya)
CREATE OR REPLACE VIEW v_product_variants_complete AS
SELECT 
    pv.id_variant,
    pv.id_product,
    p.name AS product_name,
    p.description AS product_desc,
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
    
    ps.description AS status,
    
    (
        SELECT image_url 
        FROM variant_images vi 
        WHERE vi.id_variant = pv.id_variant 
        AND vi.cod_status = 'A'
        ORDER BY vi.order_position 
        LIMIT 1
    ) AS variant_image,
    
    (
        SELECT image_url 
        FROM product_images pi 
        WHERE pi.id_product = p.id_product 
        AND pi.cod_status = 'A'
        ORDER BY pi.order_position 
        LIMIT 1
    ) AS product_main_image,
    
    pv.created_at,
    pv.updated_at
FROM product_variants pv
JOIN products p ON pv.id_product = p.id_product
JOIN colors col ON pv.id_color = col.id_color
JOIN sizes sz ON pv.id_size = sz.id_size
JOIN categories cat ON p.id_category = cat.id_category
JOIN product_status ps ON pv.cod_status = ps.cod_status;

-- Vista de colores disponibles por producto (Esta vista no es útil por ahora, la dejo igualmente pero será utilizada por los admins cuando los haya)
CREATE OR REPLACE VIEW v_product_available_colors AS
SELECT 
    p.id_product,
    p.name AS product_name,
    c.id_color,
    c.name AS color_name,
    c.description AS color_desc,
    c.hex_code,
    SUM(pv.stock) AS total_stock_in_color,
    COUNT(DISTINCT pv.id_size) AS available_sizes
FROM products p
JOIN product_variants pv ON p.id_product = pv.id_product
JOIN colors c ON pv.id_color = c.id_color
WHERE pv.cod_status = 'A'
GROUP BY p.id_product, p.name AS product_name, c.id_color, c.name AS color_name, c.description AS color_desc, c.hex_code
HAVING SUM(pv.stock) > 0;

-- Vista de talles disponibles por producto y color (Esta vista no es útil por ahora, la dejo igualmente pero será utilizada por los admins cuando los haya)
CREATE OR REPLACE VIEW v_product_available_sizes AS
SELECT 
    p.id_product,
    p.name AS product_name,
    c.id_color,
    c.description AS color_desc,
    s.id_size,
    s.size,
    s.sort_order,
    pv.id_variant,
    pv.stock,
    pv.price
FROM products p
JOIN product_variants pv ON p.id_product = pv.id_product
JOIN colors c ON pv.id_color = c.id_color
JOIN sizes s ON pv.id_size = s.id_size
WHERE pv.cod_status = 'A'
  AND pv.stock > 0
ORDER BY p.id_product, c.id_color, s.sort_order;

-- Vista de ventas con información completa
CREATE OR REPLACE VIEW v_sales_complete AS
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
-- FIN DEL SCRIPT
-- ----------------------------------------------------------------------------