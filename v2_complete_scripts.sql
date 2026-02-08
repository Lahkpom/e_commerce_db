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
    id_sale UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
    date_completed TIMESTAMP NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NULL,
    customer_phone VARCHAR(50) NOT NULL,
    shipping_address TEXT NOT NULL,
    order_notes TEXT NOT NULL DEFAULT '',
    id_sale_status INTEGER NOT NULL REFERENCES sale_status(id_status),
    id_payment_method INTEGER NOT NULL REFERENCES payment_methods(id_method),
    id_payment_status INTEGER NOT NULL REFERENCES payment_status(id_status),
    mp_payment_id VARCHAR(100) NULL,
    mp_preference_id VARCHAR(100) NULL,
    shipping_cost DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (shipping_cost >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NULL
);


-- HAY QUE REVISAR ESTE, ME QUEDÉ HASTA ACÁ EN EL PASO 6 DEL MENSAJE DE 19:45 DEL 06/02/2026
CREATE TABLE sale_items (
    id_sale_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sale UUID NOT NULL REFERENCES sales(id_sale) ON DELETE CASCADE,
    id_variant UUID NOT NULL REFERENCES product_variants(id_variant),
    
    -- Snapshot al momento de la venta
    product_name VARCHAR(255) NOT NULL,
    variant_description VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);



-- Tabla de items de venta
CREATE TABLE sale_items (
    id_sale_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sale UUID NOT NULL REFERENCES sales(id_sale) ON DELETE CASCADE,
    id_variant UUID NOT NULL REFERENCES product_variants(id_variant),
    product_name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 4. ÍNDICES PARA MEJORAR PERFORMANCE
-- ----------------------------------------------------------------------------

-- Índices en products
CREATE INDEX idx_products_category ON products(id_category);
CREATE INDEX idx_products_status ON products(id_status);
CREATE INDEX idx_products_sku ON products(sku);

-- Índices en product_variants
CREATE INDEX idx_variants_product ON product_variants(id_product);
CREATE INDEX idx_variants_color ON product_variants(id_color);
CREATE INDEX idx_variants_size ON product_variants(id_size);
CREATE INDEX idx_variants_status ON product_variants(id_status);
CREATE INDEX idx_variants_sku ON product_variants(sku);

-- Índices en variant_images
CREATE INDEX idx_variant_images_variant ON variant_images(id_variant);
CREATE INDEX idx_variant_images_status ON variant_images(id_status);

-- Índices en sales
CREATE INDEX idx_sales_status ON sales(id_sale_status);
CREATE INDEX idx_sales_payment_status ON sales(id_payment_status);
CREATE INDEX idx_sales_payment_method ON sales(id_payment_method);
CREATE INDEX idx_sales_created_at ON sales(created_at DESC);
CREATE INDEX idx_sales_customer_email ON sales(customer_email);
CREATE INDEX idx_sales_mp_payment_id ON sales(mp_payment_id);

-- Índices en sale_items
CREATE INDEX idx_sale_items_sale ON sale_items(id_sale);
CREATE INDEX idx_sale_items_product ON sale_items(id_product);

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
CREATE OR REPLACE FUNCTION check_product_stock()
RETURNS TRIGGER AS $$
DECLARE
    available_stock INTEGER;
BEGIN
    SELECT stock INTO available_stock
    FROM products
    WHERE id_product = NEW.id_product;
    
    IF available_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto. Disponible: %, Solicitado: %', 
            available_stock, NEW.quantity;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar stock
CREATE TRIGGER trg_check_stock
    BEFORE INSERT ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION check_product_stock();

-- Función para reducir stock automáticamente al confirmar venta
CREATE OR REPLACE FUNCTION reduce_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo reducir stock cuando el estado cambia a 'approved'
    IF NEW.id_payment_status = (SELECT id_status FROM payment_status WHERE description = 'approved')
       AND OLD.id_payment_status != NEW.id_payment_status THEN
        
        UPDATE products p
        SET stock = stock - si.quantity
        FROM sale_items si
        WHERE si.id_sale = NEW.id_sale
          AND si.id_product = p.id_product;
          
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para reducir stock cuando se aprueba el pago
CREATE TRIGGER trg_reduce_stock_on_payment
    AFTER UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION reduce_product_stock();

-- ----------------------------------------------------------------------------
-- 6. POLÍTICAS RLS (Row Level Security) - SEGURIDAD
-- ----------------------------------------------------------------------------

-- Habilitar RLS en todas las tablas principales
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE variant_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;

-- Política para products: lectura pública de productos activos
CREATE POLICY "Public read active products" ON products
    FOR SELECT
    USING (id_status = (SELECT id_status FROM product_status WHERE description = 'active'));

-- Política para variant_images: lectura pública de imágenes activas
CREATE POLICY "Public read active images" ON variant_images
    FOR SELECT
    USING (id_status = (SELECT id_status FROM image_status WHERE description = 'active'));

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

COMMENT ON TABLE products IS 'Catálogo de productos del ecommerce';
COMMENT ON COLUMN products.base_price IS 'Precio aproximado del costo de producción.';
COMMENT ON COLUMN products.sku IS 'Código único de producto (Stock Keeping Unit)';

COMMENT ON TABLE product_variants IS 'Variantes de productos: cada combinación de producto + talle + color';
COMMENT ON COLUMN product_variants.price IS 'Precio a mostrar al cliente';

COMMENT ON TABLE variant_images IS 'Imágenes específicas de cada variante (ej: foto del producto en color rojo)';
COMMENT ON COLUMN variant_images.order_position IS 'Orden de visualización (1 = imagen principal)';

COMMENT ON TABLE sales IS 'Registro de ventas/órdenes de compra';
COMMENT ON COLUMN sales.mp_payment_id IS 'ID de transacción de Mercado Pago';
COMMENT ON COLUMN sales.mp_preference_id IS 'ID de preferencia de Mercado Pago';

COMMENT ON TABLE sale_items IS 'Items individuales de cada venta (snapshot de productos al momento de venta)';
COMMENT ON COLUMN sale_items.product_name IS 'Nombre del producto al momento de la venta (snapshot)';
COMMENT ON COLUMN sale_items.unit_price IS 'Precio unitario al momento de la venta (snapshot)';

-- ----------------------------------------------------------------------------
-- 8. VISTAS ÚTILES
-- ----------------------------------------------------------------------------

-- Vista de productos con información completa
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