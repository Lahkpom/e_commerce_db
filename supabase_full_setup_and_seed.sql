-- =============================================================================
-- Calwillyfiorella: esquema completo y datos de prueba para Supabase
-- Fuente de DDL: SUPABASE_FULL_SETUP_AND_SEED_REPORT.md y archivos .pgsql del repositorio.
-- Destino: base Supabase limpia, esquema public. No ejecutar sobre un esquema ya poblado.
-- Seeds determinísticos; ejecutar el archivo completo en una única corrida.
-- =============================================================================
BEGIN;
SET LOCAL search_path TO public, extensions;


-- ============================================================================
-- FASE 1 - EXTENSIONES Y ENUMS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

CREATE TYPE enum_category AS ENUM (
    'CALZADO'
);

CREATE TYPE enum_numeric_size AS ENUM (
    'T_18',
    'T_19',
    'T_20',
    'T_21',
    'T_22',
    'T_23',
    'T_24',
    'T_25',
    'T_26',
    'T_35',
    'T_36',
    'T_37',
    'T_38',
    'T_39',
    'T_40',
    'T_41',
    'T_42',
    'T_35_36',
    'T_37_38',
    'T_39_40',
    'T_41_42',
    'T_43_44',
    'T_45_46'
);

CREATE TYPE enum_payment_method AS ENUM (
    'MERCADO_PAGO', 
    'TRANSFERENCIA', 
    'EFECTIVO'
);

CREATE TYPE enum_payment_status AS ENUM (
    'PENDIENTE',
    'APROBADO',
    'RECHAZADO',
    'REEMBOLSO_PENDIENTE',
    'REEMBOLSADO'
);

-- Motivo formal de la solicitud de posventa
CREATE TYPE enum_return_reason AS ENUM (
    'ARREPENTIMIENTO_LEGAL', -- Ejercicio del derecho dentro de los 10 días (Ley 24.240)
    'CAMBIO_TALLE',          -- Solicitud de cambio voluntario por calce/medidas
    'DEFECTO_FABRICACION'    -- Falla atribuible a costura, pegado o materiales
);

-- Tipo de resolución acordada para la posventa
CREATE TYPE enum_return_resolution AS ENUM (
    'REEMBOLSO_DINERO',     -- Devolución del dinero abonado
    'CAMBIO_PRODUCTO',      -- Reemplazo por otro talle/prenda
    'CREDITO_TIENDA'        -- Cupón/saldo a favor del cliente
);

-- Estados del ciclo operativo y logístico de la devolución (RMA)
CREATE TYPE enum_return_status AS ENUM (
    'SOLICITADA',
    'EN_TRANSITO',
    'RECIBIDO_EN_CONTROL',
    'APROBADA',
    'RECHAZADA',
    'CANCELADA'
);

CREATE TYPE enum_row_status AS ENUM (
    'ACTIVE', 
    'INACTIVE', 
    'DELETED'
);

CREATE TYPE enum_sale_status AS ENUM (
    'PENDIENTE',
    'PREPARACION',
    'ENVIADO',
    'ENTREGADO',
    'CANCELADO',
    'REEMBOLSADO',
    'AUDITORIA', -- Orden retenida por discrepancias de pago, fraude potencial o revisión manual
    'RECLAMO_ABIERTO',
    'CERRADO_CON_DEVOLUCION'
);

CREATE TYPE enum_shipping_method AS ENUM (
    'RETIRO_LLAVALLOL',
    'ENVIO_GBA_ZONA_SUR',
    'ENVIO_GBA_GENERAL',
    'ENVIO_CORREO_NACIONAL'
);

CREATE TYPE enum_target_gender AS ENUM (
    'NINIAS',
    'NINIOS',
    'HOMBRES',
    'MUJERES',
    'UNISEX'
);

CREATE TYPE enum_user_role AS ENUM (
    'ADMIN',
    'OPERATOR',
    'WHOLESALER',
    'CUSTOMER'
);

CREATE TYPE fiscal_receipt_type AS ENUM (
      'FACTURA_C', 
      'NOTA_DEBITO_C', 
      'NOTA_CREDITO_C'
);

CREATE TYPE tax_id_type AS ENUM (
    'DNI', 
    'CUIL', 
    'CUIT', 
    'PASAPORTE'
);


-- ============================================================================
-- FASE 2 - TABLAS PADRE, HIJAS Y JOURNALS
-- ============================================================================

CREATE TABLE users (
    user_id                 UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_role               enum_user_role  NOT NULL DEFAULT 'CUSTOMER',
    user_password           VARCHAR(255)    NOT NULL,
    user_name               VARCHAR(255)    NOT NULL,
    user_email              VARCHAR(255)    NOT NULL CHECK (user_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$'),
    user_phone              VARCHAR(50)     NULL,
    company_name            VARCHAR(255)    NULL,
    tax_id_type             tax_id_type     NULL,
    tax_id_number           VARCHAR(20)     NULL,
    is_email_verified       BOOLEAN         NOT NULL DEFAULT FALSE,
    failed_login_attempts   INTEGER         NOT NULL DEFAULT 0 CHECK (failed_login_attempts >= 0),
    locked_until            TIMESTAMPTZ     NULL,
    last_login_at           TIMESTAMPTZ     NULL,
    password_expires_at     TIMESTAMPTZ     NOT NULL DEFAULT (NOW() + INTERVAL '180 days'),
    must_change_password    BOOLEAN         NOT NULL DEFAULT FALSE,
    row_status              enum_row_status NOT NULL DEFAULT 'ACTIVE',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NULL
);

CREATE TABLE product (
    product_id          UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    product_category    enum_category       NOT NULL,
    target_gender       enum_target_gender  NOT NULL,
    product_name        VARCHAR(255)        NOT NULL,
    product_short_desc  VARCHAR(255)        NOT NULL,
    product_long_desc   TEXT                NOT NULL,
    row_status          enum_row_status     NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NULL
);

CREATE TABLE color (
    color_id    BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    color_name  VARCHAR(50)     NOT NULL,
    color_desc  TEXT            NOT NULL,
    color_code  VARCHAR(7)      NOT NULL CHECK (color_code ~* '^#[A-Fa-f0-9]{6}$'),
    row_status  enum_row_status NOT NULL DEFAULT 'ACTIVE',
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NULL
);

CREATE TABLE user_login_log (
    log_id          BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         UUID            NULL REFERENCES users(user_id) ON DELETE SET NULL,
    attempted_email VARCHAR(255)    NOT NULL,
    is_success      BOOLEAN         NOT NULL,
    failure_reason  VARCHAR(100)    NULL,
    ip_address      INET            NULL,
    user_agent      TEXT            NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE user_security_tokens (
    token_id    UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID            NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token_hash  VARCHAR(255)    NOT NULL UNIQUE,
    token_type  VARCHAR(50)     NOT NULL, -- 'EMAIL_VERIFICATION', 'PASSWORD_RESET'
    expires_at  TIMESTAMPTZ     NOT NULL,
    consumed_at TIMESTAMPTZ     NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE user_session (
    session_id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID            NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token_hash      VARCHAR(255)    NOT NULL UNIQUE,
    device_info             VARCHAR(255)    NULL,
    ip_address              INET            NULL,
    is_revoked              BOOLEAN         NOT NULL DEFAULT FALSE,
    expires_at              TIMESTAMPTZ     NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    last_activity_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    replaced_by_session_id  UUID            NULL
);

CREATE TABLE variant (
    variant_id      BIGINT              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id      UUID                NOT NULL REFERENCES product(product_id),
    color_id        BIGINT              NOT NULL REFERENCES color(color_id),
    variant_size    enum_numeric_size   NOT NULL,
    variant_desc    VARCHAR(255)        NOT NULL,
    variant_sku     VARCHAR(100)        NOT NULL,
    variant_price   DECIMAL(10, 2)      NOT NULL CHECK (variant_price >= 0),
    variant_stock   INTEGER             NOT NULL DEFAULT 0 CHECK (variant_stock >= 0),
    row_status      enum_row_status     NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ         NULL
);

CREATE TABLE image (
    image_id        BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id      UUID        NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    color_id        BIGINT      NOT NULL REFERENCES color(color_id),
    image_url       TEXT        NOT NULL,
    is_primary      BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NULL
);

CREATE TABLE shipping_zone (
    shipping_zone_id    BIGINT                  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipping_method     enum_shipping_method    NOT NULL UNIQUE,
    zone_name           VARCHAR(120)            NOT NULL,
    description         TEXT                    NULL,
    postal_codes        JSONB                   NOT NULL DEFAULT '[]'::jsonb,
    base_cost           DECIMAL(12, 2)          NOT NULL DEFAULT 0.00 CHECK (base_cost >= 0),
    estimated_days      VARCHAR(80)             NOT NULL,
    row_status          enum_row_status         NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NULL,
    updated_by          UUID                    NULL REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE sale (
    sale_id                 UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID                NULL REFERENCES users(user_id) ON DELETE SET NULL,
    tracking_token          UUID                NOT NULL DEFAULT gen_random_uuid(),
    
    -- Snapshot de contacto y entrega (inmutables tras la compra)
    -- TODO - Sería conveniente hacer subtablas para customer_data y shipping_data?
    customer_name           VARCHAR(255)        NOT NULL,
    customer_email          VARCHAR(255)        NOT NULL,
    customer_phone          VARCHAR(50)         NOT NULL,
    customer_tax_id_type    tax_id_type         NULL,
    customer_tax_id_number  VARCHAR(20)         NULL,
    customer_notes          TEXT                NULL,
    shipping_method         enum_shipping_method NOT NULL,
    shipping_province       VARCHAR(100)        NULL,
    shipping_locality       VARCHAR(150)        NULL,
    shipping_postal_code    VARCHAR(10)         NULL,
    shipping_address        TEXT                NULL,
    
    -- Totales financieros (moneda congelada)
    sale_quantity           INTEGER             NOT NULL CHECK (sale_quantity > 0),
    sale_subtotal           DECIMAL(12, 2)      NOT NULL CHECK (sale_subtotal > 0),
    sale_discount_amount    DECIMAL(12, 2)      NOT NULL DEFAULT 0.00 CHECK (sale_discount_amount >= 0),
    shipping_cost           DECIMAL(12, 2)      NOT NULL DEFAULT 0.00 CHECK (shipping_cost >= 0),
    sale_total              DECIMAL(12, 2)      NOT NULL CHECK (sale_total = (sale_subtotal - sale_discount_amount + shipping_cost) AND sale_total > 0),
    
    -- Fechas de logística
    sale_shipped_at         TIMESTAMPTZ         NULL,
    sale_delivered_at       TIMESTAMPTZ         NULL,
    
    -- Máquina de estados
    sale_status             enum_sale_status    NOT NULL DEFAULT 'PENDIENTE',
    payment_method          enum_payment_method NOT NULL,
    payment_status          enum_payment_status NOT NULL DEFAULT 'PENDIENTE',
    fiscal_rejection        BOOLEAN             NOT NULL DEFAULT FALSE,
    internal_notes          TEXT                NULL,
    
    -- Trazabilidad de pasarela de pago (Mercado Pago / Gateway)
    mp_payment_id           VARCHAR(100)        NULL,
    mp_preference_id        VARCHAR(100)        NULL,
    mp_merchant_order_id    VARCHAR(100)        NULL,
    
    -- Auditoría técnica
    created_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NULL,
    updated_by              UUID                NULL REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE cart_item (
    user_id     UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    variant_id  BIGINT      NOT NULL REFERENCES variant(variant_id) ON DELETE CASCADE,
    quantity    INTEGER     NOT NULL CHECK (quantity > 0 AND quantity <= 10000) DEFAULT 1,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NULL,
    
    PRIMARY KEY (user_id, variant_id)
);

CREATE TABLE sale_item (
    sale_item_id    BIGINT              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id         UUID                NOT NULL REFERENCES sale(sale_id) ON DELETE CASCADE,
    variant_id      BIGINT              NULL REFERENCES variant(variant_id) ON DELETE SET NULL,
    
    -- Snapshot completo del producto vendido
    product_name    VARCHAR(255)        NOT NULL,
    product_desc    VARCHAR(255)        NOT NULL,
    variant_desc    VARCHAR(255)        NOT NULL,
    variant_sku     VARCHAR(100)        NOT NULL,
    variant_size    enum_numeric_size   NOT NULL,
    color_name      VARCHAR(100)        NOT NULL,
    image_url       TEXT                NOT NULL,
    
    -- Valores económicos
    unit_price      DECIMAL(12, 2)      NOT NULL CHECK (unit_price > 0),
    quantity        INTEGER             NOT NULL CHECK (quantity > 0),
    subtotal        DECIMAL(12, 2)      NOT NULL CHECK (subtotal = (unit_price * quantity) AND subtotal > 0),
    
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- TABLA: sale_return (Cabecera del expediente de devolución/cambio)
-- =============================================================================
CREATE TABLE sale_return (
    return_id                   UUID                    PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id                     UUID                    NOT NULL REFERENCES sale(sale_id) ON DELETE RESTRICT,
    tracking_token              UUID                    NOT NULL DEFAULT gen_random_uuid(),
    
    -- Clasificación y resolución
    return_reason               enum_return_reason      NOT NULL,
    return_resolution           enum_return_resolution  NOT NULL DEFAULT 'REEMBOLSO_DINERO',
    return_status               enum_return_status      NOT NULL DEFAULT 'SOLICITADA',
    
    -- Políticas de logística inversa
    shipping_covered_by_store   BOOLEAN                 NOT NULL DEFAULT TRUE,
    return_shipping_guide       VARCHAR(100)            NULL, -- Código de seguimiento de la etiqueta inversa de correo
    
    -- Liquidación financiera calculada
    refund_amount               DECIMAL(12, 2)          NOT NULL DEFAULT 0.00 CHECK (refund_amount >= 0),
    
    -- Declaración del cliente
    customer_notes              TEXT                    NOT NULL, -- Explicación del cliente al pedir la devolución
    
    -- Dictamen e inspección en depósito/taller
    inspection_notes            TEXT                    NULL, -- Detalle técnico tras abrir e inspeccionar las prendas
    inspection_evidence_path    TEXT                    NULL, -- URL/Bucket con fotografías del peritaje (clave ante rechazos)
    inspected_by                UUID                    NULL REFERENCES users(user_id) ON DELETE SET NULL,
    inspected_at                TIMESTAMPTZ             NULL,
    
    -- Trazabilidad temporal
    created_at                  TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ             NULL,
    closed_at                   TIMESTAMPTZ             NULL  -- Fecha efectiva de resolución final (aprobada/rechazada/liquidada)
);

-- =============================================================================
-- TABLA: sale_return_item (Detalle de prendas incluidas en el reclamo)
-- =============================================================================

CREATE TABLE sale_return_item (
    return_item_id      BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    return_id           UUID            NOT NULL REFERENCES sale_return(return_id) ON DELETE CASCADE,
    sale_item_id        BIGINT          NOT NULL REFERENCES sale_item(sale_item_id) ON DELETE RESTRICT,
    
    -- Cantidad devuelta
    quantity            INTEGER         NOT NULL CHECK (quantity > 0),
    
    -- Dictamen individual sobre el producto
    restock_approved    BOOLEAN         NULL, -- NULL: En espera de peritaje | TRUE: Apto reventa | FALSE: Destrucción/Falla
    rejection_reason    VARCHAR(255)    NULL, -- Ej: 'Suela con desgaste por uso', 'Manchas de maquillaje/perfume'
    
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE fiscal_receipt (
    fiscal_receipt_id   UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id             UUID                NOT NULL REFERENCES sale(sale_id),
    return_id           UUID                REFERENCES sale_return(return_id),
    receipt_type        fiscal_receipt_type NOT NULL,
    afip_cbte_tipo      INT                 NOT NULL, -- 11: Factura C, 12: Nota de Débito C, 13: Nota de Crédito C
    point_of_sale       INT                 NOT NULL,
    receipt_number      BIGINT              NOT NULL,
    cae                 VARCHAR(14)         NOT NULL,
    cae_due_date        DATE                NOT NULL,
    issue_date          DATE                NOT NULL,
    
    -- Snapshot del receptor al momento de la emisión
    doc_type INT NOT NULL, -- 80: CUIT, 96: DNI, 99: Sin identificar
    doc_number VARCHAR(20) NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    
    -- Snapshot dinerario (Monotributo: total = neto)
    total_amount NUMERIC(12, 2) NOT NULL,
    net_amount NUMERIC(12, 2) NOT NULL,
    
    -- Código para renderizar QR de ARCA (según RG 4291/2018)
    qr_payload TEXT NOT NULL,
    
    -- Auditoría legal y de auditor
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES users(user_id),

    -- Restricción legal: No pueden existir dos comprobantes con el mismo tipo, punto de venta y número
    CONSTRAINT uq_receipt_number UNIQUE (receipt_type, point_of_sale, receipt_number)
);

-- 1. Crear la tabla de Journal
CREATE TABLE users_jn (
    jn_id                   BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jn_operation            VARCHAR(10)     NOT NULL CHECK (jn_operation IN ('UPDATE', 'DELETE')),
    jn_timestamp            TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    jn_changed_by           VARCHAR(255)    NULL, -- usuario o service que ejecutó el cambio
    
    -- Snapshot del registro tal como estaba
    user_id                 UUID            NOT NULL,
    user_role               enum_user_role  NOT NULL,
    user_password           VARCHAR(255)    NOT NULL,
    user_name               VARCHAR(255)    NOT NULL,
    user_email              VARCHAR(255)    NOT NULL,
    user_phone              VARCHAR(50)     NULL,
    company_name            VARCHAR(255)    NULL,
    tax_id_type             tax_id_type     NULL,
    tax_id_number           VARCHAR(20)     NULL,
    is_email_verified       BOOLEAN         NOT NULL,
    failed_login_attempts   INTEGER         NOT NULL,
    locked_until            TIMESTAMPTZ     NULL,
    last_login_at           TIMESTAMPTZ     NULL,
    password_expires_at     TIMESTAMPTZ     NOT NULL,
    must_change_password    BOOLEAN         NOT NULL,
    row_status              enum_row_status NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL,
    updated_at              TIMESTAMPTZ     NULL
);

CREATE TABLE sale_jn (
    jn_id                   BIGINT              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jn_operation            VARCHAR(10)         NOT NULL CHECK (jn_operation IN ('UPDATE', 'DELETE')),
    jn_timestamp            TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    jn_changed_by           VARCHAR(255)        NULL, -- Usuario o contexto que ejecutó la modificación
    
    -- Snapshot idéntico del registro sale tal como estaba antes del cambio (OLD)
    sale_id                 UUID                NOT NULL,
    user_id                 UUID                NULL,
    tracking_token          UUID                NOT NULL,
    customer_name           VARCHAR(255)        NOT NULL,
    customer_email          VARCHAR(255)        NOT NULL,
    customer_phone          VARCHAR(50)         NOT NULL,
    customer_tax_id_type    tax_id_type         NULL,
    customer_tax_id_number  VARCHAR(20)         NULL,
    customer_notes          TEXT                NULL,
    shipping_method         enum_shipping_method NOT NULL,
    shipping_province       VARCHAR(100)        NULL,
    shipping_locality       VARCHAR(150)        NULL,
    shipping_postal_code    VARCHAR(10)         NULL,
    shipping_address        TEXT                NULL,
    internal_notes          TEXT                NULL,
    sale_quantity           INTEGER             NOT NULL,
    sale_subtotal           DECIMAL(12, 2)      NOT NULL,
    sale_discount_amount    DECIMAL(12, 2)      NOT NULL,
    shipping_cost           DECIMAL(12, 2)      NOT NULL,
    sale_total              DECIMAL(12, 2)      NOT NULL,
    sale_shipped_at         TIMESTAMPTZ         NULL,
    sale_delivered_at       TIMESTAMPTZ         NULL,
    sale_status             enum_sale_status    NOT NULL,
    payment_method          enum_payment_method NOT NULL,
    payment_status          enum_payment_status NOT NULL,
    fiscal_rejection        BOOLEAN             NOT NULL,
    mp_payment_id           VARCHAR(100)        NULL,
    mp_preference_id        VARCHAR(100)        NULL,
    mp_merchant_order_id    VARCHAR(100)        NULL,
    created_at              TIMESTAMPTZ         NOT NULL,
    updated_at              TIMESTAMPTZ         NULL,
    updated_by              UUID                NULL
);

-- =============================================================================
-- 1. TABLA JOURNAL: sale_return_jn
-- =============================================================================

CREATE TABLE sale_return_jn (
    jn_id                       BIGINT                  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jn_operation                VARCHAR(10)             NOT NULL CHECK (jn_operation IN ('UPDATE', 'DELETE')),
    jn_timestamp                TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    jn_changed_by               VARCHAR(255)            NULL, -- Usuario de aplicación o sesión DB

    -- Snapshot idéntico del registro sale_return tal como estaba antes del cambio (OLD)
    return_id                   UUID                    NOT NULL,
    sale_id                     UUID                    NOT NULL,
    tracking_token              UUID                    NOT NULL,
    return_reason               enum_return_reason      NOT NULL,
    return_resolution           enum_return_resolution  NOT NULL,
    return_status               enum_return_status      NOT NULL,
    shipping_covered_by_store   BOOLEAN                 NOT NULL,
    return_shipping_guide       VARCHAR(100)            NULL,
    refund_amount               DECIMAL(12, 2)          NOT NULL,
    customer_notes              TEXT                    NOT NULL,
    inspection_notes            TEXT                    NULL,
    inspection_evidence_path    TEXT                    NULL,
    inspected_by                UUID                    NULL,
    inspected_at                TIMESTAMPTZ             NULL,
    created_at                  TIMESTAMPTZ             NOT NULL,
    updated_at                  TIMESTAMPTZ             NULL,
    closed_at                   TIMESTAMPTZ             NULL
);


-- ============================================================================
-- FASE 3 - FUNCIONES
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER 
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ########################################################################################
CREATE OR REPLACE FUNCTION trg_fn_update_user_last_login()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
    IF 
        NEW.is_success  = TRUE 
        AND NEW.user_id IS NOT NULL 
    THEN
        UPDATE 
            users
        SET 
            last_login_at           = NEW.created_at,
            failed_login_attempts   = 0,
            locked_until            = NULL
        WHERE 
            user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 2. Función del trigger para capturar el snapshot previo
CREATE OR REPLACE FUNCTION trg_fn_audit_users()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_changed_by VARCHAR(255);
BEGIN
    v_changed_by := NULLIF(current_setting('app.current_user', true), '');
    IF v_changed_by IS NULL THEN
        v_changed_by := SESSION_USER;
    END IF;

    INSERT INTO users_jn (
        jn_operation, 
        jn_timestamp,
        jn_changed_by,
        user_id, 
        user_role, 
        user_password, 
        user_name, 
        user_email,
        user_phone, 
        company_name,
        tax_id_type,
        tax_id_number,
        is_email_verified, 
        failed_login_attempts,
        locked_until, 
        last_login_at, 
        password_expires_at,
        must_change_password,
        row_status,
        created_at, 
        updated_at
    ) VALUES (
        TG_OP, 
        NOW(),
        v_changed_by,
        OLD.user_id, 
        OLD.user_role, 
        OLD.user_password, 
        OLD.user_name, 
        OLD.user_email,
        OLD.user_phone, 
        OLD.company_name, 
        OLD.tax_id_type,
        OLD.tax_id_number,
        OLD.is_email_verified, 
        OLD.failed_login_attempts,
        OLD.locked_until, 
        OLD.last_login_at, 
        OLD.password_expires_at,
        OLD.must_change_password,
        OLD.row_status,
        OLD.created_at, 
        OLD.updated_at
    );

    IF      TG_OP = 'UPDATE' THEN RETURN NEW;
    ELSIF   TG_OP = 'DELETE' THEN RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- ########################################################################################
-- 2. Función del trigger para capturar el snapshot previo
CREATE OR REPLACE FUNCTION trg_fn_audit_sale()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_changed_by VARCHAR(255);
BEGIN
    v_changed_by := NULLIF(current_setting('app.current_user', true), '');
    IF v_changed_by IS NULL THEN
        v_changed_by := SESSION_USER;
    END IF;

    INSERT INTO sale_jn (
        jn_operation,
        jn_timestamp,
        jn_changed_by,
        sale_id,
        user_id,
        tracking_token,
        customer_name,
        customer_email,
        customer_phone,
        customer_tax_id_type,
        customer_tax_id_number,
        customer_notes,
        shipping_method,
        shipping_province,
        shipping_locality,
        shipping_postal_code,
        shipping_address,
        internal_notes,
        sale_quantity,
        sale_subtotal,
        sale_discount_amount,
        shipping_cost,
        sale_total,
        sale_shipped_at,
        sale_delivered_at,
        sale_status,
        payment_method,
        payment_status,
        fiscal_rejection,
        mp_payment_id,
        mp_preference_id,
        mp_merchant_order_id,
        created_at,
        updated_at,
        updated_by
    ) VALUES (
        TG_OP,
        NOW(),
        v_changed_by,
        OLD.sale_id,
        OLD.user_id,
        OLD.tracking_token,
        OLD.customer_name,
        OLD.customer_email,
        OLD.customer_phone,
        OLD.customer_tax_id_type,
        OLD.customer_tax_id_number,
        OLD.customer_notes,
        OLD.shipping_method,
        OLD.shipping_province,
        OLD.shipping_locality,
        OLD.shipping_postal_code,
        OLD.shipping_address,
        OLD.internal_notes,
        OLD.sale_quantity,
        OLD.sale_subtotal,
        OLD.sale_discount_amount,
        OLD.shipping_cost,
        OLD.sale_total,
        OLD.sale_shipped_at,
        OLD.sale_delivered_at,
        OLD.sale_status,
        OLD.payment_method,
        OLD.payment_status,
        OLD.fiscal_rejection,
        OLD.mp_payment_id,
        OLD.mp_preference_id,
        OLD.mp_merchant_order_id,
        OLD.created_at,
        OLD.updated_at,
        OLD.updated_by
    );

    IF      TG_OP = 'UPDATE' THEN RETURN NEW;
    ELSIF   TG_OP = 'DELETE' THEN RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- FUNCIÓN DISPARADORA DEL TRIGGER: trg_fn_audit_sale_return()
CREATE OR REPLACE FUNCTION trg_fn_audit_sale_return()
RETURNS TRIGGER 
SET search_path = public
LANGUAGE plpgsql AS $$
DECLARE
    v_changed_by VARCHAR(255);
BEGIN
    -- Intenta capturar el usuario de la aplicación inyectado en el contexto transaccional
    v_changed_by := NULLIF(current_setting('app.current_user', true), '');
    IF v_changed_by IS NULL THEN
        v_changed_by := SESSION_USER;
    END IF;

    INSERT INTO sale_return_jn (
        jn_operation,
        jn_timestamp,
        jn_changed_by,
        return_id,
        sale_id,
        tracking_token,
        return_reason,
        return_resolution,
        return_status,
        shipping_covered_by_store,
        return_shipping_guide,
        refund_amount,
        customer_notes,
        inspection_notes,
        inspection_evidence_path,
        inspected_by,
        inspected_at,
        created_at,
        updated_at,
        closed_at
    ) VALUES (
        TG_OP,
        NOW(),
        v_changed_by,
        OLD.return_id,
        OLD.sale_id,
        OLD.tracking_token,
        OLD.return_reason,
        OLD.return_resolution,
        OLD.return_status,
        OLD.shipping_covered_by_store,
        OLD.return_shipping_guide,
        OLD.refund_amount,
        OLD.customer_notes,
        OLD.inspection_notes,
        OLD.inspection_evidence_path,
        OLD.inspected_by,
        OLD.inspected_at,
        OLD.created_at,
        OLD.updated_at,
        OLD.closed_at
    );

    IF TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION purge_expired_sessions_and_logs(
    p_session_days INTEGER DEFAULT 30,
    p_log_days INTEGER DEFAULT 90
)
RETURNS VOID 
SET search_path = public
LANGUAGE plpgsql AS $$
BEGIN
    -- Borrar sesiones revocadas o vencidas hace más de X días
    DELETE FROM user_session
    WHERE (is_revoked = TRUE OR expires_at < NOW())
        AND created_at < NOW() - (p_session_days || ' days')::INTERVAL;

    -- Borrar logs de inicio de sesión antiguos
    DELETE FROM user_login_log
    WHERE created_at < NOW() - (p_log_days || ' days')::INTERVAL;
END;
$$;


-- ============================================================================
-- FASE 3 - TRIGGERS
-- ============================================================================

-- ########################################################################################
CREATE TRIGGER trg_color_update
    BEFORE UPDATE ON color
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ########################################################################################
CREATE TRIGGER trg_image_updated_at
    BEFORE UPDATE ON image
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ########################################################################################
CREATE TRIGGER trg_product_update
    BEFORE UPDATE ON product
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ########################################################################################
CREATE TRIGGER trg_variant_update
    BEFORE UPDATE ON variant
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ########################################################################################
CREATE TRIGGER trg_cart_item_updated_at
    BEFORE UPDATE ON cart_item
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ########################################################################################
CREATE TRIGGER trg_sale_update
    BEFORE UPDATE ON sale
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ########################################################################################
CREATE TRIGGER trg_sale_audit
    AFTER UPDATE OR DELETE ON sale
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_audit_sale();

-- Trigger de actualización automática de timestamp
CREATE TRIGGER trg_sale_return_update
    BEFORE UPDATE ON sale_return
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_sale_return_audit
    AFTER UPDATE OR DELETE ON sale_return
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_audit_sale_return();

-- ########################################################################################
CREATE TRIGGER trg_shipping_zone_update
    BEFORE UPDATE ON shipping_zone
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ----------------------------------------------------------------------------------------
CREATE TRIGGER trg_user_login_success
    AFTER INSERT ON user_login_log
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_update_user_last_login();

-- ########################################################################################
CREATE TRIGGER trg_user_update
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 3. Vincular el trigger a la tabla users
CREATE TRIGGER trg_users_audit
    AFTER UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_audit_users();


-- ============================================================================
-- FASE 3 - VISTAS PUBLICAS VIGENTES
-- ============================================================================

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

CREATE OR REPLACE VIEW v_public_product_variants AS
SELECT
    p.product_id,
    p.product_name,
    p.product_long_desc,
    pv.variant_id,
    pv.variant_size,
    pv.variant_price,
    pv.variant_stock,
    c.color_id,
    c.color_name,
    c.color_code,
    COALESCE(
        (
            SELECT JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'image_url', i.image_url,
                    'is_primary', i.is_primary
                )
                ORDER BY i.is_primary DESC, i.created_at ASC, i.image_id ASC
            )
            FROM image i
            WHERE i.product_id = pv.product_id
                AND i.color_id = pv.color_id
        ),
        '[]'::jsonb
    ) AS images
FROM product p
JOIN variant pv
    ON pv.product_id = p.product_id
    AND pv.row_status = 'ACTIVE'
JOIN color c
    ON c.color_id = pv.color_id
    AND c.row_status = 'ACTIVE'
WHERE p.row_status = 'ACTIVE';


-- ============================================================================
-- FASE 3 - INDICES
-- ============================================================================

-- ########################################################################################
-- Índices únicos parciales (excluyen los borrados lógicos)
CREATE UNIQUE INDEX uk_color_name_not_deleted 
    ON color (LOWER(color_name)) 
    WHERE row_status <> 'DELETED';

CREATE UNIQUE INDEX uk_color_code_not_deleted 
    ON color (UPPER(color_code)) 
    WHERE row_status <> 'DELETED';

-- ########################################################################################
-- Búsqueda rápida de galería por producto y color
CREATE INDEX idx_image_product_color 
    ON image (product_id, color_id, is_primary DESC, created_at ASC);

-- ########################################################################################
-- Solo UNA imagen principal (is_primary = TRUE) por cada combinación Producto + Color
CREATE UNIQUE INDEX uq_image_product_color_primary 
    ON image (product_id, color_id) 
    WHERE is_primary = TRUE;

-- ########################################################################################
CREATE UNIQUE INDEX uk_product_name_not_deleted 
    ON product (LOWER(product_name)) 
    WHERE row_status IN ('ACTIVE', 'INACTIVE');

-- ########################################################################################
CREATE INDEX idx_product_gender_status 
    ON product (target_gender, row_status)
    WHERE row_status IN ('ACTIVE', 'INACTIVE');

-- ########################################################################################
CREATE UNIQUE INDEX uk_product_color_size_not_deleted 
    ON variant (product_id, color_id, variant_size) 
    WHERE row_status IN ('ACTIVE', 'INACTIVE');

-- ########################################################################################
CREATE UNIQUE INDEX uk_variant_sku_not_deleted 
    ON variant (LOWER(variant_sku)) 
    WHERE row_status IN ('ACTIVE', 'INACTIVE');

-- ########################################################################################
CREATE INDEX idx_variant_product ON variant(product_id) WHERE row_status IN ('ACTIVE', 'INACTIVE');

CREATE INDEX idx_variant_color   ON variant(color_id)   WHERE row_status IN ('ACTIVE', 'INACTIVE');

-- ########################################################################################
CREATE INDEX idx_cart_item_variant ON cart_item(variant_id);

-- Índices de búsqueda frecuente
CREATE INDEX idx_fiscal_receipt_sale    ON fiscal_receipt(sale_id);

CREATE INDEX idx_fiscal_receipt_return  ON fiscal_receipt(return_id);

CREATE INDEX idx_fiscal_receipt_cae     ON fiscal_receipt(cae);

CREATE INDEX idx_fiscal_receipt_dates   ON fiscal_receipt(issue_date);

-- ########################################################################################
CREATE INDEX idx_sale_user              ON sale(user_id);

CREATE INDEX idx_sale_customer_email    ON sale(LOWER(customer_email));

CREATE INDEX idx_sale_customer_tax_id   ON sale (customer_tax_id_number);

CREATE INDEX idx_sale_status            ON sale(sale_status);

CREATE INDEX idx_sale_payment_status    ON sale(payment_status);

CREATE INDEX idx_sale_created_at        ON sale(created_at DESC);

CREATE INDEX idx_sale_mp_payment        ON sale(mp_payment_id)      WHERE mp_payment_id IS NOT NULL;

CREATE INDEX idx_sale_fiscal_rejection  ON sale(fiscal_rejection)   WHERE fiscal_rejection = TRUE;

CREATE UNIQUE INDEX uq_sale_tracking_token ON sale(tracking_token);

-- ########################################################################################
CREATE INDEX idx_sale_item_sale        ON sale_item(sale_id);

CREATE INDEX idx_sale_item_variant     ON sale_item(variant_id);

-- ########################################################################################
-- Índice de optimización para consultar la cronología de una venta específica
CREATE INDEX idx_sale_jn_sale_id ON sale_jn(sale_id, jn_timestamp DESC);

-- Índices de consulta operativa
CREATE INDEX idx_sale_return_sale           ON sale_return(sale_id);

CREATE INDEX idx_sale_return_status         ON sale_return(return_status);

CREATE INDEX idx_sale_return_created_at     ON sale_return(created_at DESC);

CREATE UNIQUE INDEX uq_sale_return_tracking ON sale_return(tracking_token);

-- Índices
CREATE INDEX idx_sale_return_item_return    ON sale_return_item(return_id);

CREATE INDEX idx_sale_return_item_sale_item ON sale_return_item(sale_item_id);

-- Restricción para evitar registrar dos veces el mismo renglón de compra en una misma solicitud
CREATE UNIQUE INDEX uq_return_sale_item ON sale_return_item(return_id, sale_item_id);

-- Índice optimizado para consultar el historial de auditoría de una devolución puntual
CREATE INDEX idx_sale_return_jn_return_id ON sale_return_jn(return_id, jn_timestamp DESC);

-- ########################################################################################
CREATE INDEX idx_shipping_zone_postal_codes ON shipping_zone USING GIN (postal_codes);

CREATE INDEX idx_shipping_zone_status      ON shipping_zone(row_status);

-- ########################################################################################
CREATE INDEX idx_login_log_user         ON user_login_log(user_id, created_at DESC);

CREATE INDEX idx_login_log_ip           ON user_login_log(ip_address, created_at DESC);

CREATE INDEX idx_login_log_email_recent ON user_login_log(LOWER(attempted_email), created_at DESC) WHERE is_success = FALSE;

CREATE INDEX idx_sec_tokens_lookup ON user_security_tokens(token_hash) WHERE consumed_at IS NULL;

-- ########################################################################################
CREATE INDEX idx_user_session_lookup        ON user_session(user_id)            WHERE is_revoked = FALSE;

CREATE INDEX idx_user_session_token_active  ON user_session(refresh_token_hash) WHERE is_revoked = FALSE;

-- ########################################################################################
CREATE UNIQUE INDEX uk_user_email_not_deleted 
    ON users (LOWER(user_email)) 
    WHERE row_status <> 'DELETED';

-- ########################################################################################
CREATE INDEX idx_users_role_status  ON users(user_role, row_status);

CREATE INDEX idx_users_tax_id       ON users (tax_id_number);

CREATE INDEX idx_users_jn_user_id ON users_jn(user_id, jn_timestamp DESC);


-- ============================================================================
-- FASE 3 - COMENTARIOS
-- ============================================================================

COMMENT ON TYPE enum_user_role IS 
'Roles de usuario para control de acceso al sistema:
- ADMIN: Administrador con acceso total al sistema. Puede gestionar todos los aspectos del ecommerce y crear operadores.
- OPERATOR: Operador que puede gestionar productos, ventas y crear usuarios mayoristas. Solo puede ser creado por administradores.
- WHOLESALER: Cliente mayorista con descuentos especiales. Solo puede ser creado por operadores.
- CUSTOMER: Cliente regular que puede comprar productos y ver su historial de compras.';

-- ########################################################################################
COMMENT ON TABLE color               IS 'Tabla para almacenar los colores en código HEX';

COMMENT ON COLUMN color.color_name   IS 'Nombre del color';

COMMENT ON COLUMN color.color_desc   IS 'Si quiere agregar alguna descripción llamativa';

COMMENT ON COLUMN color.color_code   IS 'El color_code se debe guardar en hexadecimal y en mayúsculas. Solo puede ser en su versión de 6 caracteres';

-- ########################################################################################
COMMENT ON TABLE    image               IS 'Imágenes compartidas por todos los talles de un mismo producto y color.';

COMMENT ON COLUMN   image.product_id    IS 'Producto al que pertenece la galería.';

COMMENT ON COLUMN   image.color_id      IS 'Color específico del producto al que corresponden las fotografías.';

COMMENT ON COLUMN   image.is_primary    IS 'Portada principal del color en el catálogo. Máximo una por producto y color.';

-- ########################################################################################
COMMENT ON TABLE    product                     IS 'Catálogo de productos del ecommerce por categoría y género objetivo.';

COMMENT ON COLUMN   product.target_gender       IS 'Género al que apunta el producto (NINIAS, NINIOS, HOMBRES, MUJERES, UNISEX).';

COMMENT ON COLUMN   product.product_short_desc  IS 'Descripción breve para tarjetas del catálogo.';

COMMENT ON COLUMN   product.product_long_desc   IS 'Descripción completa para la vista de detalle del producto.';

-- ########################################################################################
COMMENT ON TABLE  variant IS 'Combinaciones vendibles de producto + color + talle con su precio y stock.';

COMMENT ON COLUMN variant.variant_desc IS 'Breve descripción particular de la variante.';

COMMENT ON COLUMN variant.variant_price IS 'Precio al por menor para venta al público general.';

-- ########################################################################################
COMMENT ON TABLE cart_item               IS 'Items del carrito de compras para usuarios autenticados. Persistencia con borrado físico.';

COMMENT ON COLUMN cart_item.user_id      IS 'Usuario propietario del item del carrito.';

COMMENT ON COLUMN cart_item.variant_id   IS 'Variante del producto en el carrito';

-- ########################################################################################
COMMENT ON TABLE sale                       IS 'Cabecera consolidada de órdenes de compra con snapshot financiero y logístico.';

COMMENT ON COLUMN sale.user_id              IS 'Usuario registrado propietario de la orden. Queda en NULL si la compra fue como invitado.';

COMMENT ON COLUMN sale.tracking_token       IS 'Token criptográfico único utilizado para el acceso público seguro (magic link) al estado del pedido sin autenticación.';

COMMENT ON COLUMN sale.shipping_method      IS 'Método de envío o retiro seleccionado para la compra.';

COMMENT ON COLUMN sale.shipping_province    IS 'Provincia de destino del envío.';

COMMENT ON COLUMN sale.shipping_locality    IS 'Localidad de destino del envío.';

COMMENT ON COLUMN sale.shipping_postal_code IS 'Código postal de destino del envío.';

COMMENT ON COLUMN sale.shipping_address     IS 'Dirección completa y normalizada de entrega (calle, número, piso, localidad, CP). NULL cuando se retira en Llavallol.';

COMMENT ON COLUMN sale.customer_notes       IS 'Observaciones o aclaraciones cargadas directamente por el cliente durante el checkout.';

COMMENT ON COLUMN sale.internal_notes       IS 'Anotaciones operativas y de seguimiento exclusivas para uso administrativo del personal de la tienda.';

COMMENT ON COLUMN sale.sale_quantity        IS 'Cantidad total acumulada de unidades de producto que contiene la compra.';

COMMENT ON COLUMN sale.sale_subtotal        IS 'Monto acumulado bruto en moneda local (suma de los subtotales de sale_item).';

COMMENT ON COLUMN sale.sale_discount_amount IS 'Descuento total deducido a la compra expresado en valor monetario fijo (no en porcentaje).';

COMMENT ON COLUMN sale.shipping_cost        IS 'Costo de envío cotizado y aplicado a la transacción.';

COMMENT ON COLUMN sale.sale_total           IS 'Monto final a cobrar tras aplicar descuentos fijos y cargos de envío. Validado por restricción CHECK.';

COMMENT ON COLUMN sale.sale_shipped_at      IS 'Marca de tiempo UTC en que la orden fue despachada y entregada al servicio de correo/logística.';

COMMENT ON COLUMN sale.sale_delivered_at    IS 'Marca de tiempo UTC en que la orden fue confirmada como recibida por el cliente.';

COMMENT ON COLUMN sale.sale_status          IS 'Estado del ciclo de vida operativo del pedido (PENDIENTE, PREPARACION, ENVIADO, ENTREGADO, CANCELADO, REEMBOLSADO).';

COMMENT ON COLUMN sale.payment_method       IS 'Medio seleccionado por el cliente para el abono (MERCADO_PAGO, TRANSFERENCIA, EFECTIVO).';

COMMENT ON COLUMN sale.payment_status       IS 'Estado de la liquidación del cobro (PENDIENTE, APROBADO, RECHAZADO, REEMBOLSADO).';

COMMENT ON COLUMN sale.fiscal_rejection     IS 'Tiene la finalidad de indicar cuando un intento de emisión de fatura fue rechazado por ARCA debido a inconsistencias en los datos..';

COMMENT ON COLUMN sale.mp_payment_id        IS 'Identificador de la transacción de pago retornado por la API de Mercado Pago.';

COMMENT ON COLUMN sale.mp_preference_id     IS 'Identificador del checkout preference creado para el cobro en Mercado Pago.';

COMMENT ON COLUMN sale.mp_merchant_order_id IS 'Identificador de orden comercial retornado por las notificaciones Webhook de Mercado Pago.';

COMMENT ON COLUMN sale.updated_by           IS 'Identificador del usuario o administrador que aplicó la última modificación manual.';

-- ########################################################################################
COMMENT ON TABLE sale_item                  IS 'Detalle de renglones de la compra con copia histórica inmutable del catálogo.';

COMMENT ON COLUMN sale_item.sale_id         IS 'Referencia a la cabecera de la venta. Si la cabecera se borra, sus ítems caen en cascada.';

COMMENT ON COLUMN sale_item.variant_id      IS 'Referencia a la variante viva del catálogo. Pasa a NULL si la variante es eliminada para preservar el renglón.';

COMMENT ON COLUMN sale_item.unit_price      IS 'Precio unitario final de venta acordado para esta variante.';

COMMENT ON COLUMN sale_item.quantity        IS 'Cantidad de unidades adquiridas de este ítem (mínimo 1).';

COMMENT ON COLUMN sale_item.subtotal        IS 'Monto resultante de multiplicar unit_price por quantity. Validado por restricción CHECK.';

-- ########################################################################################
COMMENT ON TABLE sale_jn                        IS 'Tabla journal histórica para auditoría total de modificaciones y bajas en órdenes de compra.';

COMMENT ON COLUMN sale_jn.jn_id                 IS 'Identificador único secuencial del registro histórico de auditoría.';

COMMENT ON COLUMN sale_jn.jn_operation          IS 'Operación que disparó el registro histórico (UPDATE o DELETE).';

COMMENT ON COLUMN sale_jn.jn_timestamp          IS 'Marca de tiempo UTC exacta en que se ejecutó la operación.';

COMMENT ON COLUMN sale_jn.jn_changed_by         IS 'Identificador del actor o sesión de base de datos que ejecutó la sentencia.';

-- Comentarios documentales
COMMENT ON TABLE sale_return                            IS 'Expediente de posventa, reclamos de arrepentimiento legal y cambios de producto.';

COMMENT ON COLUMN sale_return.sale_id                   IS 'Orden de compra original vinculada. ON DELETE RESTRICT impide borrar ventas con reclamos históricos.';

COMMENT ON COLUMN sale_return.tracking_token            IS 'Token de consulta pública para que el cliente siga el peritaje de su devolución sin loguearse.';

COMMENT ON COLUMN sale_return.return_reason             IS 'Motivo tipificado de la solicitud (Arrepentimiento 10 días, cambio de talle o defecto).';

COMMENT ON COLUMN sale_return.return_resolution         IS 'Mecanismo de compensación: devolución monetaria, envío de reemplazo o saldo a favor.';

COMMENT ON COLUMN sale_return.shipping_covered_by_store IS 'Define si el flete inverso corre por cuenta del comercio (obligatorio por ley en arrepentimiento).';

COMMENT ON COLUMN sale_return.return_shipping_guide     IS 'Número de tracking de la etiqueta provista al cliente para enviar el paquete de regreso.';

COMMENT ON COLUMN sale_return.refund_amount             IS 'Monto monetario exacto a devolver al comprador una vez superado el peritaje.';

COMMENT ON COLUMN sale_return.customer_notes            IS 'Manifestación del cliente describiendo el motivo o falla declarada.';

COMMENT ON COLUMN sale_return.inspection_notes          IS 'Dictamen pericial del operador de control de calidad tras recibir y examinar la prenda.';

COMMENT ON COLUMN sale_return.inspection_evidence_path  IS 'Enlace al repositorio de imágenes que respaldan el dictamen (fundamental en rechazos por uso).';

COMMENT ON COLUMN sale_return.inspected_by              IS 'Identificador del operador/auditor que revisó físicamente la mercadería en taller.';

COMMENT ON COLUMN sale_return.inspected_at              IS 'Marca temporal exacta en que se concluyó la inspección de calidad.';

COMMENT ON COLUMN sale_return.closed_at                 IS 'Marca temporal UTC en que concluyó formalmente el expediente de devolución.';

-- Comentarios documentales
COMMENT ON TABLE sale_return_item                   IS 'Desglose renglón por renglón de las prendas físicas reclamadas para devolución o cambio.';

COMMENT ON COLUMN sale_return_item.sale_item_id     IS 'Renglón inmutable de la compra que se está retornando.';

COMMENT ON COLUMN sale_return_item.quantity         IS 'Unidades que el cliente devuelve de este renglón específico.';

COMMENT ON COLUMN sale_return_item.restock_approved IS 'Indica si la prenda reingresa al stock activo de la tienda tras el peritaje físico.';

COMMENT ON COLUMN sale_return_item.rejection_reason IS 'Fundamento explícito del rechazo de reingreso o descarte de la prenda.';

-- Comentarios documentales
COMMENT ON TABLE sale_return_jn                         IS 'Tabla journal histórica para auditoría total de modificaciones y bajas en solicitudes de devolución/RMA.';

COMMENT ON COLUMN sale_return_jn.jn_id                  IS 'Identificador único secuencial del registro histórico de auditoría.';

COMMENT ON COLUMN sale_return_jn.jn_operation           IS 'Operación que disparó el registro histórico (UPDATE o DELETE).';

COMMENT ON COLUMN sale_return_jn.jn_timestamp           IS 'Marca de tiempo UTC exacta en que se ejecutó la operación de auditoría.';

COMMENT ON COLUMN sale_return_jn.jn_changed_by          IS 'Identificador del actor o sesión que ejecutó la sentencia en base de datos.';

-- ########################################################################################
COMMENT ON TABLE shipping_zone                       IS 'Zonas de envío, tarifas, plazos y códigos postales habilitados.';

COMMENT ON COLUMN shipping_zone.shipping_zone_id     IS 'Identificador único de la zona de envío.';

COMMENT ON COLUMN shipping_zone.shipping_method      IS 'Método de envío asociado a la zona.';

COMMENT ON COLUMN shipping_zone.zone_name            IS 'Nombre visible de la zona de envío.';

COMMENT ON COLUMN shipping_zone.description          IS 'Descripción adicional de las condiciones de envío de la zona.';

COMMENT ON COLUMN shipping_zone.postal_codes         IS 'Códigos postales argentinos de cuatro dígitos habilitados para la zona. Un arreglo vacío indica retiro o cobertura nacional por defecto.';

COMMENT ON COLUMN shipping_zone.base_cost            IS 'Costo base del envío en moneda local.';

COMMENT ON COLUMN shipping_zone.estimated_days       IS 'Plazo estimado de entrega o coordinación.';

COMMENT ON COLUMN shipping_zone.row_status           IS 'Estado lógico de la zona de envío.';

COMMENT ON COLUMN shipping_zone.created_at            IS 'Marca de tiempo UTC de creación del registro.';

COMMENT ON COLUMN shipping_zone.updated_at            IS 'Marca de tiempo UTC de la última modificación.';

COMMENT ON COLUMN shipping_zone.updated_by            IS 'Identificador del usuario o administrador que aplicó la última modificación.';

-- ########################################################################################
COMMENT ON TABLE user_login_log                     IS 'Registro histórico e inmutable de todos los intentos de inicio de sesión (éxitos y fallos).';

COMMENT ON COLUMN user_login_log.log_id             IS 'Identificador autoincremental de 64 bits para soportar alto volumen de registros.';

COMMENT ON COLUMN user_login_log.user_id            IS 'ID del usuario autenticado. NULL si el usuario no existe en la base o fue eliminado.';

COMMENT ON COLUMN user_login_log.attempted_email    IS 'Email ingresado en el formulario de login. Se guarda por si el user_id no existe';

COMMENT ON COLUMN user_login_log.is_success         IS 'Indica si la autenticación fue exitosa (true) o rechazada (false).';

COMMENT ON COLUMN user_login_log.failure_reason     IS 'Código o motivo del fallo (ej: INVALID_CREDENTIALS, ACCOUNT_LOCKED, USER_NOT_FOUND).';

COMMENT ON COLUMN user_login_log.ip_address         IS 'Dirección IP del cliente en formato nativo IPv4 o IPv6.';

COMMENT ON COLUMN user_login_log.user_agent         IS 'Cadena User-Agent del navegador o cliente HTTP para análisis de huella digital.';

COMMENT ON COLUMN user_login_log.created_at         IS 'Fecha y hora exacta en la que se procesó el intento de autenticación.';

-- ########################################################################################
COMMENT ON TABLE user_session                       IS 'Sesiones activas y almacén de Refresh Tokens para rotación y revocación de JWT.';

COMMENT ON COLUMN user_session.session_id           IS 'Identificador único de la sesión activa del dispositivo.';

COMMENT ON COLUMN user_session.user_id              IS 'Usuario propietario de la sesión. Si el usuario se elimina, sus sesiones se borran en cascada.';

COMMENT ON COLUMN user_session.refresh_token_hash   IS 'Hash criptográfico (SHA-256) del Refresh Token entregado al cliente.';

COMMENT ON COLUMN user_session.device_info          IS 'Resumen legible del dispositivo o navegador (ej: Chrome 120 en Windows 10).';

COMMENT ON COLUMN user_session.ip_address           IS 'Última dirección IP registrada desde donde operó la sesión.';

COMMENT ON COLUMN user_session.is_revoked           IS 'Indica si la sesión fue cerrada explícitamente por logout o invalidación de seguridad.';

COMMENT ON COLUMN user_session.expires_at           IS 'Fecha límite de validez del Refresh Token.';

COMMENT ON COLUMN user_session.created_at           IS 'Fecha de inicio de la sesión.';

COMMENT ON COLUMN user_session.last_activity_at     IS 'Última vez que este Refresh Token fue utilizado para emitir un Access Token.';

COMMENT ON COLUMN user_session.last_activity_at     IS 'Cuando un usuario renueva su token, la sesión vieja se marca como revocada y apunta a la nueva. Si alguien intenta usar de nuevo un refresh token revocado (detección de robo de token), tu backend detecta el rehúso gracias a esta cadena y anula todas las sesiones del usuario.';

-- ########################################################################################
COMMENT ON TABLE users                          IS 'Tabla principal de usuarios y credenciales administrada por Spring Boot.';

COMMENT ON COLUMN users.user_id                 IS 'Identificador único UUID.';

COMMENT ON COLUMN users.user_role               IS 'Rol del usuario (ADMIN, OPERATOR, WHOLESALER, CUSTOMER). Por defecto es CUSTOMER';

COMMENT ON COLUMN users.user_password           IS 'Hash criptográfico (BCrypt) generado por el backend.';

COMMENT ON COLUMN users.user_name               IS 'Nombre completo o razón social de contacto.';

COMMENT ON COLUMN users.user_email              IS 'Correo electrónico único validado.';

COMMENT ON COLUMN users.user_phone              IS 'Teléfono o WhatsApp.';

COMMENT ON COLUMN users.company_name            IS 'Razón social (para cuentas WHOLESALER).';

COMMENT ON COLUMN users.is_email_verified       IS 'Indica si validó el correo.';

COMMENT ON COLUMN users.failed_login_attempts   IS 'Contador de intentos fallidos para protección de fuerza bruta.';

COMMENT ON COLUMN users.locked_until            IS 'Bloqueo temporal por exceso de intentos fallidos.';

COMMENT ON COLUMN users.last_login_at           IS 'Último acceso con éxito.';

COMMENT ON COLUMN users.must_change_password    IS 'Indica si el usuario debe cambiar su contraseña antes de continuar.';

COMMENT ON VIEW v_public_product_catalog IS 
'Catálogo público de productos activos con al menos una variante y un color activos, filtrable por target_gender. Agrupa el precio mínimo, conteo de talles y colores activos, y una imagen primaria por cada color disponible.';

COMMENT ON VIEW v_public_product_variants IS
'Detalle público de variantes activas de productos activos. Incluye talle, color, precio, stock (también cero) e imágenes del producto y color, ordenadas con la principal primero.';


-- =============================================================================
-- FASE 4 - SEEDS DETERMINISTICOS Y VARIADOS
-- =============================================================================

-- Usuarios: 5 ACTIVE y 5 INACTIVE por rol. Todos verificados, sin cambio forzado de clave.
DO $seed_users$
DECLARE
    v_role enum_user_role;
    v_status enum_row_status;
    v_roles enum_user_role[] := ARRAY['ADMIN'::enum_user_role, 'OPERATOR'::enum_user_role, 'WHOLESALER'::enum_user_role, 'CUSTOMER'::enum_user_role];
    v_statuses enum_row_status[] := ARRAY['ACTIVE'::enum_row_status, 'INACTIVE'::enum_row_status];
    v_i integer;
    v_seq integer := 0;
    v_email text;
    v_password text;
    v_name text;
    v_phone text;
    v_tax_type tax_id_type;
    v_tax_number text;
    v_company text;
BEGIN
    FOREACH v_role IN ARRAY v_roles LOOP
        FOREACH v_status IN ARRAY v_statuses LOOP
            FOR v_i IN 1..5 LOOP
                v_seq := v_seq + 1;
                IF v_status = 'ACTIVE' THEN
                    v_email := format('%s_%s@gmail.com', lower(v_role::text), v_i);
                ELSE
                    v_email := format('%s_inactive_%s@gmail.com', lower(v_role::text), v_i);
                END IF;
                v_password := split_part(v_email, '@', 1);
                v_name := format('%s %s Seed %s', initcap(lower(v_role::text)), v_status::text, lpad(v_i::text, 2, '0'));
                v_phone := '11' || lpad(v_seq::text, 8, '0');
                v_tax_type := CASE WHEN v_role = 'WHOLESALER' THEN 'CUIT'::tax_id_type ELSE 'DNI'::tax_id_type END;
                IF v_role = 'WHOLESALER' THEN
                    v_tax_number := '20' || lpad((30000000 + v_seq)::text, 8, '0') || '7';
                    v_company := format('Calzado Mayorista %s Seed %s', v_status::text, lpad(v_i::text, 2, '0'));
                ELSE
                    v_tax_number := lpad((20000000 + v_seq)::text, 8, '0');
                    v_company := NULL;
                END IF;

                INSERT INTO users (
                    user_id, user_role, user_password, user_name, user_email, user_phone,
                    company_name, tax_id_type, tax_id_number, is_email_verified,
                    failed_login_attempts, must_change_password, row_status
                ) VALUES (
                    md5('seed:user:' || v_email)::uuid,
                    v_role,
                    extensions.crypt(v_password, extensions.gen_salt('bf', 10)),
                    v_name,
                    v_email,
                    v_phone,
                    v_company,
                    v_tax_type,
                    v_tax_number,
                    TRUE,
                    0,
                    FALSE,
                    v_status
                );
            END LOOP;
        END LOOP;
    END LOOP;

    PERFORM set_config('app.current_user', 'seed-users', TRUE);
    UPDATE users
    SET user_name = user_name || ' (auditoria)'
    WHERE user_email IN ('admin_1@gmail.com', 'operator_1@gmail.com', 'wholesaler_1@gmail.com', 'customer_1@gmail.com');
END;
$seed_users$;

-- Colores: siete activos y tres inactivos; nombres y HEX únicos.
DO $seed_colors$
BEGIN
    INSERT INTO color (color_name, color_desc, color_code, row_status) VALUES
        ('Negro Seed', 'Negro grafito para calzado urbano', '#101010', 'ACTIVE'),
        ('Rosa Seed', 'Rosa suave para modelos infantiles', '#F4A7B9', 'ACTIVE'),
        ('Beige Seed', 'Beige neutro de uso diario', '#D8C3A5', 'ACTIVE'),
        ('Blanco Seed', 'Blanco clásico de temporada', '#FFFFFF', 'ACTIVE'),
        ('Azul Seed', 'Azul intenso para línea deportiva', '#1E5AA8', 'ACTIVE'),
        ('Suela Seed', 'Marrón suela de acabado natural', '#8B4513', 'ACTIVE'),
        ('Verde Seed', 'Verde bosque de edición urbana', '#287A48', 'ACTIVE'),
        ('Violeta Seed', 'Violeta de colección anterior', '#8A2BE2', 'INACTIVE'),
        ('Gris Seed', 'Gris piedra discontinuado', '#707070', 'INACTIVE'),
        ('Naranja Seed', 'Naranja de edición limitada discontinuada', '#FF8C00', 'INACTIVE');
END;
$seed_colors$;

-- Productos, variantes e imágenes: 35 productos x 15 variantes y 3 imágenes por galería.
DO $seed_catalog$
DECLARE
    v_genders enum_target_gender[] := ARRAY['NINIAS'::enum_target_gender, 'NINIOS'::enum_target_gender, 'HOMBRES'::enum_target_gender, 'MUJERES'::enum_target_gender, 'UNISEX'::enum_target_gender];
    v_gender enum_target_gender;
    v_status enum_row_status;
    v_sizes enum_numeric_size[];
    v_active_colors bigint[];
    v_inactive_colors bigint[];
    v_product_id uuid;
    v_color_id bigint;
    v_product_index integer;
    v_gender_index integer;
    v_color_index integer;
    v_size_index integer;
    v_image_index integer;
    v_product_name text;
    v_sku text;
    v_variant_id bigint;
    v_variant_count integer := 0;
    v_image_count integer := 0;
BEGIN
    SELECT array_agg(color_id ORDER BY color_id) INTO v_active_colors FROM color WHERE row_status = 'ACTIVE';
    SELECT array_agg(color_id ORDER BY color_id) INTO v_inactive_colors FROM color WHERE row_status = 'INACTIVE';

    FOR v_product_index IN 1..35 LOOP
        v_gender_index := ((v_product_index - 1) % 5) + 1;
        v_gender := v_genders[v_gender_index];
        v_status := CASE WHEN v_product_index <= 25 THEN 'ACTIVE'::enum_row_status ELSE 'INACTIVE'::enum_row_status END;
        v_product_name := format('Calzado Seed %s Modelo %s', v_gender::text, lpad(v_product_index::text, 2, '0'));
        v_product_id := md5('seed:product:' || lpad(v_product_index::text, 2, '0'))::uuid;

        INSERT INTO product (
            product_id, product_category, target_gender, product_name,
            product_short_desc, product_long_desc, row_status
        ) VALUES (
            v_product_id,
            'CALZADO',
            v_gender,
            v_product_name,
            format('Descripción breve única %s para %s', lpad(v_product_index::text, 2, '0'), v_gender::text),
            format('Modelo de calzado de prueba %s, género %s, con diseño, materiales y terminación diferenciados para el catálogo de demostración.', lpad(v_product_index::text, 2, '0'), v_gender::text),
            v_status
        );

        v_sizes := CASE v_gender
            WHEN 'NINIAS' THEN ARRAY['T_18'::enum_numeric_size, 'T_19'::enum_numeric_size, 'T_20'::enum_numeric_size, 'T_21'::enum_numeric_size, 'T_22'::enum_numeric_size]
            WHEN 'NINIOS' THEN ARRAY['T_22'::enum_numeric_size, 'T_23'::enum_numeric_size, 'T_24'::enum_numeric_size, 'T_25'::enum_numeric_size, 'T_26'::enum_numeric_size]
            WHEN 'HOMBRES' THEN ARRAY['T_39'::enum_numeric_size, 'T_40'::enum_numeric_size, 'T_41'::enum_numeric_size, 'T_42'::enum_numeric_size, 'T_43_44'::enum_numeric_size]
            WHEN 'MUJERES' THEN ARRAY['T_35'::enum_numeric_size, 'T_36'::enum_numeric_size, 'T_37'::enum_numeric_size, 'T_38'::enum_numeric_size, 'T_39'::enum_numeric_size]
            ELSE ARRAY['T_35_36'::enum_numeric_size, 'T_37_38'::enum_numeric_size, 'T_39_40'::enum_numeric_size, 'T_41_42'::enum_numeric_size, 'T_43_44'::enum_numeric_size]
        END;

        FOR v_color_index IN 1..3 LOOP
            IF v_product_index <= 25 THEN
                v_color_id := v_active_colors[((v_product_index + v_color_index - 2) % array_length(v_active_colors, 1)) + 1];
            ELSIF v_color_index <= 2 THEN
                v_color_id := v_active_colors[((v_product_index + v_color_index - 2) % array_length(v_active_colors, 1)) + 1];
            ELSE
                v_color_id := v_inactive_colors[((v_product_index - 26) % array_length(v_inactive_colors, 1)) + 1];
            END IF;

            FOR v_size_index IN 1..5 LOOP
                v_sku := format('CF-SEED-%s-C%s-T%s', lpad(v_product_index::text, 2, '0'), v_color_index, v_size_index);
                INSERT INTO variant (
                    product_id, color_id, variant_size, variant_desc, variant_sku,
                    variant_price, variant_stock, row_status
                ) VALUES (
                    v_product_id,
                    v_color_id,
                    v_sizes[v_size_index],
                    format('Variante %s, color %s, talle %s', v_product_name, v_color_index, v_sizes[v_size_index]::text),
                    v_sku,
                    (18000 + v_product_index * 137 + v_color_index * 91 + v_size_index * 73)::numeric(10,2),
                    5 + ((v_product_index * 7 + v_color_index * 3 + v_size_index * 5) % 56),
                    v_status
                ) RETURNING variant_id INTO v_variant_id;
                v_variant_count := v_variant_count + 1;
            END LOOP;

            FOR v_image_index IN 1..3 LOOP
                INSERT INTO image (product_id, color_id, image_url, is_primary)
                VALUES (
                    v_product_id,
                    v_color_id,
                    format('https://picsum.photos/seed/cf%s_c%s_img%s/800/1000', lpad(v_product_index::text, 2, '0'), v_color_index, v_image_index),
                    v_image_index = 1
                );
                v_image_count := v_image_count + 1;
            END LOOP;
        END LOOP;
    END LOOP;

    IF v_variant_count <> 525 OR v_image_count <> 315 THEN
        RAISE EXCEPTION 'Conteos de catálogo inesperados: variantes %, imágenes %', v_variant_count, v_image_count;
    END IF;
END;
$seed_catalog$;

-- Zonas oficiales; lista de CP y costos tomada de tables/sale/shipping_zone.pgsql.
DO $seed_shipping_zones$
BEGIN
    INSERT INTO shipping_zone (
        shipping_method, zone_name, description, postal_codes, base_cost, estimated_days
    ) VALUES
    (
        'RETIRO_LLAVALLOL',
        'Retiro en Estación Llavallol',
        NULL,
        '[]'::jsonb,
        0.00,
        'En el día (a coordinar por WhatsApp)'
    ),
    (
        'ENVIO_GBA_ZONA_SUR',
        'Envío a domicilio - GBA Zona Sur',
        NULL,
        '["1836", "1832", "1834", "1828", "1839", "1846", "1852", "1845", "1847", "1849", "1854", "1856", "1842", "1838", "1841", "1804", "1806", "1824", "1826", "1822", "1870", "1872", "1875", "1876", "1878", "1882", "1884", "1888"]'::jsonb,
        3000.00,
        '1 a 2 días hábiles'
    ),
    (
        'ENVIO_GBA_GENERAL',
        'Envío a domicilio - CABA y GBA Norte/Oeste',
        NULL,
        (
            SELECT jsonb_agg(to_char(postal_code, 'FM0000') ORDER BY postal_code)
            FROM generate_series(1000, 1499) AS codes(postal_code)
        ) || '["1704", "1706", "1708", "1712", "1714", "1722", "1744", "1754", "1702", "1678", "1686", "1638", "1636", "1640", "1642", "1609", "1646", "1648", "1650", "1653", "1613", "1615", "1667", "1629", "1625"]'::jsonb,
        6000.00,
        '2 a 4 días hábiles'
    ),
    (
        'ENVIO_CORREO_NACIONAL',
        'Envío Nacional por Correo',
        NULL,
        '[]'::jsonb,
        10000.00,
        '3 a 7 días hábiles'
    );
END;
$seed_shipping_zones$;

-- Carritos: tres variantes activas por cada usuario ACTIVE; mayoristas suman diez unidades.
DO $seed_carts$
DECLARE
    v_user record;
    v_variant_id bigint;
    v_user_index integer := 0;
    v_item_index integer;
    v_variant_count integer;
    v_quantity integer;
BEGIN
    SELECT count(*) INTO v_variant_count FROM variant WHERE row_status = 'ACTIVE';
    FOR v_user IN SELECT user_id, user_role FROM users WHERE row_status = 'ACTIVE' ORDER BY user_email LOOP
        v_user_index := v_user_index + 1;
        FOR v_item_index IN 1..3 LOOP
            SELECT variant_id INTO v_variant_id
            FROM variant
            WHERE row_status = 'ACTIVE'
            ORDER BY variant_id
            OFFSET ((v_user_index * 3 + v_item_index - 4) % v_variant_count)
            LIMIT 1;
            v_quantity := CASE
                WHEN v_user.user_role = 'WHOLESALER' THEN CASE v_item_index WHEN 1 THEN 4 WHEN 2 THEN 3 ELSE 3 END
                ELSE 1 + ((v_user_index + v_item_index) % 4)
            END;
            INSERT INTO cart_item (user_id, variant_id, quantity)
            VALUES (v_user.user_id, v_variant_id, v_quantity);
        END LOOP;
    END LOOP;
END;
$seed_carts$;

-- Ventas: 65 históricas (3 por usuario activo más 5 invitado) y 10 activas/en auditoría.
DO $seed_sales$
DECLARE
    v_payment_methods enum_payment_method[] := ARRAY['MERCADO_PAGO'::enum_payment_method, 'TRANSFERENCIA'::enum_payment_method, 'EFECTIVO'::enum_payment_method];
    v_shipping_methods enum_shipping_method[] := ARRAY['RETIRO_LLAVALLOL'::enum_shipping_method, 'ENVIO_GBA_ZONA_SUR'::enum_shipping_method, 'ENVIO_GBA_GENERAL'::enum_shipping_method, 'ENVIO_CORREO_NACIONAL'::enum_shipping_method];
    v_i integer;
    v_item integer;
    v_user_index integer;
    v_variant_count integer;
    v_offset integer;
    v_quantity integer;
    v_total_quantity integer;
    v_subtotal numeric(12,2);
    v_discount numeric(12,2);
    v_discount_pct numeric(5,2);
    v_shipping_cost numeric(12,2);
    v_total numeric(12,2);
    v_days_ago integer;
    v_sale_id uuid;
    v_user_id uuid;
    v_user users%ROWTYPE;
    v_variant variant%ROWTYPE;
    v_role enum_user_role;
    v_method enum_payment_method;
    v_shipping enum_shipping_method;
    v_sale_status enum_sale_status;
    v_payment_status enum_payment_status;
    v_fiscal_rejection boolean;
    v_variant_ids bigint[];
    v_quantities integer[];
BEGIN
    SELECT count(*) INTO v_variant_count FROM variant WHERE row_status = 'ACTIVE';

    FOR v_i IN 1..75 LOOP
        v_user_id := NULL;
        v_role := 'CUSTOMER';
        v_method := v_payment_methods[((v_i - 1) % 3) + 1];
        v_shipping := v_shipping_methods[((v_i - 1) % 4) + 1];
        v_fiscal_rejection := FALSE;

        IF v_i <= 60 THEN
            v_user_index := ((v_i - 1) / 3);
            SELECT * INTO v_user FROM users WHERE row_status = 'ACTIVE' ORDER BY user_email OFFSET v_user_index LIMIT 1;
            v_user_id := v_user.user_id;
            v_role := v_user.user_role;
        ELSIF v_i > 65 THEN
            v_user_index := ((v_i - 66) % 20);
            SELECT * INTO v_user FROM users WHERE row_status = 'ACTIVE' ORDER BY user_email OFFSET v_user_index LIMIT 1;
            v_user_id := v_user.user_id;
            v_role := v_user.user_role;
        END IF;

        IF v_method = 'EFECTIVO' AND v_shipping = 'ENVIO_CORREO_NACIONAL' THEN
            v_shipping := 'RETIRO_LLAVALLOL';
        END IF;

        IF v_i <= 25 THEN
            v_sale_status := CASE WHEN v_method = 'EFECTIVO' THEN 'PREPARACION'::enum_sale_status ELSE 'PENDIENTE'::enum_sale_status END;
            v_payment_status := 'PENDIENTE';
        ELSIF v_i <= 35 THEN
            v_sale_status := 'PENDIENTE';
            v_payment_status := CASE v_i
                WHEN 26 THEN 'PENDIENTE'::enum_payment_status
                WHEN 27 THEN 'RECHAZADO'::enum_payment_status
                WHEN 28 THEN 'APROBADO'::enum_payment_status
                WHEN 29 THEN 'PENDIENTE'::enum_payment_status
                WHEN 30 THEN 'APROBADO'::enum_payment_status
                WHEN 31 THEN 'RECHAZADO'::enum_payment_status
                WHEN 32 THEN 'APROBADO'::enum_payment_status
                WHEN 33 THEN 'PENDIENTE'::enum_payment_status
                WHEN 34 THEN 'PENDIENTE'::enum_payment_status
                ELSE 'RECHAZADO'::enum_payment_status
            END;
        ELSIF v_i <= 65 THEN
            v_sale_status := 'ENTREGADO';
            v_payment_status := 'APROBADO';
        ELSE
            CASE v_i
                WHEN 66 THEN v_sale_status := 'PENDIENTE'; v_payment_status := 'PENDIENTE'; v_method := 'MERCADO_PAGO'; v_shipping := 'RETIRO_LLAVALLOL';
                WHEN 67 THEN v_sale_status := 'PREPARACION'; v_payment_status := 'PENDIENTE'; v_method := 'EFECTIVO'; v_shipping := 'RETIRO_LLAVALLOL';
                WHEN 68 THEN v_sale_status := 'ENVIADO'; v_payment_status := 'APROBADO'; v_method := 'TRANSFERENCIA'; v_shipping := 'ENVIO_GBA_ZONA_SUR';
                WHEN 69 THEN v_sale_status := 'AUDITORIA'; v_payment_status := 'APROBADO'; v_method := 'MERCADO_PAGO'; v_shipping := 'ENVIO_GBA_GENERAL'; v_fiscal_rejection := TRUE;
                WHEN 70 THEN v_sale_status := 'AUDITORIA'; v_payment_status := 'APROBADO'; v_method := 'TRANSFERENCIA'; v_shipping := 'ENVIO_CORREO_NACIONAL'; v_fiscal_rejection := TRUE;
                WHEN 71 THEN v_sale_status := 'AUDITORIA'; v_payment_status := 'RECHAZADO'; v_method := 'MERCADO_PAGO'; v_shipping := 'RETIRO_LLAVALLOL'; v_fiscal_rejection := TRUE;
                WHEN 72 THEN v_sale_status := 'RECLAMO_ABIERTO'; v_payment_status := 'APROBADO'; v_method := 'MERCADO_PAGO'; v_shipping := 'ENVIO_GBA_ZONA_SUR';
                WHEN 73 THEN v_sale_status := 'RECLAMO_ABIERTO'; v_payment_status := 'APROBADO'; v_method := 'TRANSFERENCIA'; v_shipping := 'ENVIO_GBA_GENERAL';
                WHEN 74 THEN v_sale_status := 'RECLAMO_ABIERTO'; v_payment_status := 'APROBADO'; v_method := 'EFECTIVO'; v_shipping := 'ENVIO_GBA_ZONA_SUR';
                ELSE v_sale_status := 'RECLAMO_ABIERTO'; v_payment_status := 'REEMBOLSO_PENDIENTE'; v_method := 'MERCADO_PAGO'; v_shipping := 'RETIRO_LLAVALLOL';
            END CASE;
        END IF;

        SELECT base_cost INTO v_shipping_cost FROM shipping_zone WHERE shipping_method = v_shipping;
        v_subtotal := 0;
        v_total_quantity := 0;
        v_variant_ids := ARRAY[]::bigint[];
        v_quantities := ARRAY[]::integer[];

        FOR v_item IN 1..3 LOOP
            v_offset := ((v_i * 3 + v_item - 4) % v_variant_count);
            SELECT * INTO v_variant FROM variant WHERE row_status = 'ACTIVE' ORDER BY variant_id OFFSET v_offset LIMIT 1;
            v_quantity := CASE
                WHEN v_role = 'WHOLESALER' THEN CASE v_item WHEN 1 THEN 4 WHEN 2 THEN 3 ELSE 3 END
                ELSE 1 + ((v_i + v_item) % 4)
            END;
            v_variant_ids := array_append(v_variant_ids, v_variant.variant_id);
            v_quantities := array_append(v_quantities, v_quantity);
            v_total_quantity := v_total_quantity + v_quantity;
            v_subtotal := v_subtotal + v_variant.variant_price * v_quantity;
        END LOOP;

        v_discount_pct := CASE v_role
            WHEN 'ADMIN' THEN 15.00
            WHEN 'OPERATOR' THEN 10.00
            WHEN 'WHOLESALER' THEN 10.00
            WHEN 'CUSTOMER' THEN CASE WHEN v_total_quantity >= 3 THEN 5.00 ELSE 0.00 END
        END;
        v_discount := round(v_subtotal * v_discount_pct / 100, 2);
        v_total := v_subtotal - v_discount + v_shipping_cost;
        v_sale_id := md5('seed:sale:' || lpad(v_i::text, 3, '0'))::uuid;

        v_days_ago := CASE
            WHEN v_i BETWEEN 1 AND 8 THEN v_i
            WHEN v_i BETWEEN 9 AND 25 THEN 15 + v_i
            WHEN v_i BETWEEN 36 AND 50 THEN 20 + v_i
            WHEN v_i BETWEEN 51 AND 65 THEN 1 + ((v_i - 51) % 8)
            WHEN v_i BETWEEN 72 AND 75 THEN v_i - 71
            ELSE 30 + v_i
        END;

        INSERT INTO sale (
            sale_id, user_id, tracking_token, customer_name, customer_email, customer_phone,
            customer_tax_id_type, customer_tax_id_number, customer_notes,
            shipping_method, shipping_province, shipping_locality, shipping_postal_code, shipping_address,
            sale_quantity, sale_subtotal, sale_discount_amount, shipping_cost, sale_total,
            sale_shipped_at, sale_delivered_at, sale_status, payment_method, payment_status,
            fiscal_rejection, internal_notes, mp_payment_id, mp_preference_id, mp_merchant_order_id,
            created_at
        ) VALUES (
            v_sale_id,
            v_user_id,
            md5('seed:sale-tracking:' || lpad(v_i::text, 3, '0'))::uuid,
            CASE WHEN v_user_id IS NULL THEN format('Comprador Invitado Seed %s', lpad((v_i - 60)::text, 2, '0')) ELSE v_user.user_name END,
            CASE WHEN v_user_id IS NULL THEN format('invitado_seed_%s@example.com', lpad((v_i - 60)::text, 2, '0')) ELSE v_user.user_email END,
            CASE WHEN v_user_id IS NULL THEN '119900' || lpad((v_i - 60)::text, 4, '0') ELSE v_user.user_phone END,
            CASE WHEN v_user_id IS NULL THEN NULL ELSE v_user.tax_id_type END,
            CASE WHEN v_user_id IS NULL THEN NULL ELSE v_user.tax_id_number END,
            format('Compra de demostración %s', lpad(v_i::text, 3, '0')),
            v_shipping,
            CASE WHEN v_shipping = 'RETIRO_LLAVALLOL' THEN NULL ELSE 'Buenos Aires' END,
            CASE WHEN v_shipping = 'RETIRO_LLAVALLOL' THEN NULL WHEN v_shipping = 'ENVIO_GBA_ZONA_SUR' THEN 'Llavallol' WHEN v_shipping = 'ENVIO_GBA_GENERAL' THEN 'Ciudad Autónoma de Buenos Aires' ELSE 'Mar del Plata' END,
            CASE WHEN v_shipping = 'RETIRO_LLAVALLOL' THEN NULL WHEN v_shipping = 'ENVIO_GBA_ZONA_SUR' THEN '1836' WHEN v_shipping = 'ENVIO_GBA_GENERAL' THEN '1000' ELSE '2000' END,
            CASE WHEN v_shipping = 'RETIRO_LLAVALLOL' THEN 'Retiro en Estación Llavallol' ELSE format('Calle Seed %s 123, piso 1', lpad(v_i::text, 3, '0')) END,
            v_total_quantity,
            v_subtotal,
            v_discount,
            v_shipping_cost,
            v_total,
            CASE WHEN v_i BETWEEN 36 AND 65 OR v_i BETWEEN 68 AND 75 THEN now() - make_interval(days => v_days_ago + 1) ELSE NULL END,
            CASE WHEN v_i BETWEEN 36 AND 65 OR v_i BETWEEN 72 AND 75 THEN now() - make_interval(days => v_days_ago) ELSE NULL END,
            v_sale_status,
            v_method,
            v_payment_status,
            v_fiscal_rejection,
            CASE WHEN v_i BETWEEN 69 AND 71 THEN 'Revisión de datos fiscales seed' ELSE NULL END,
            CASE WHEN v_method = 'MERCADO_PAGO' THEN format('SEED-MP-PAY-%s', lpad(v_i::text, 3, '0')) ELSE NULL END,
            CASE WHEN v_method = 'MERCADO_PAGO' THEN format('SEED-MP-PREF-%s', lpad(v_i::text, 3, '0')) ELSE NULL END,
            CASE WHEN v_method = 'MERCADO_PAGO' THEN format('SEED-MP-ORDER-%s', lpad(v_i::text, 3, '0')) ELSE NULL END,
            now() - make_interval(days => v_days_ago + 2)
        );

        FOR v_item IN 1..3 LOOP
            INSERT INTO sale_item (
                sale_id, variant_id, product_name, product_desc, variant_desc, variant_sku,
                variant_size, color_name, image_url, unit_price, quantity, subtotal
            )
            SELECT
                v_sale_id,
                v.variant_id,
                p.product_name,
                p.product_short_desc,
                v.variant_desc,
                v.variant_sku,
                v.variant_size,
                c.color_name,
                COALESCE((SELECT im.image_url FROM image im WHERE im.product_id = v.product_id AND im.color_id = v.color_id AND im.is_primary ORDER BY im.image_id LIMIT 1), 'https://picsum.photos/seed/catalogo/800/1000'),
                v.variant_price,
                v_quantities[v_item],
                v.variant_price * v_quantities[v_item]
            FROM variant v
            JOIN product p ON p.product_id = v.product_id
            JOIN color c ON c.color_id = v.color_id
            WHERE v.variant_id = v_variant_ids[v_item];
        END LOOP;
    END LOOP;
END;
$seed_sales$;

-- Transiciones logísticas y de pago reales para alimentar sale_jn mediante el trigger AFTER UPDATE.
DO $seed_sale_transitions$
DECLARE
    v_i integer;
    v_sale_id uuid;
BEGIN
    PERFORM set_config('app.current_user', 'seed-sales', TRUE);

    FOR v_i IN 1..25 LOOP
        v_sale_id := md5('seed:sale:' || lpad(v_i::text, 3, '0'))::uuid;
        UPDATE sale SET payment_status = 'APROBADO' WHERE sale_id = v_sale_id AND payment_method <> 'EFECTIVO';
        UPDATE sale SET sale_status = 'PREPARACION' WHERE sale_id = v_sale_id AND sale_status = 'PENDIENTE';
        UPDATE sale SET sale_status = 'ENVIADO', sale_shipped_at = now() - make_interval(days => v_i + 1) WHERE sale_id = v_sale_id AND sale_status = 'PREPARACION';
        UPDATE sale SET sale_status = 'ENTREGADO', sale_delivered_at = now() - make_interval(days => v_i), payment_status = 'APROBADO' WHERE sale_id = v_sale_id AND sale_status = 'ENVIADO';
    END LOOP;

    FOR v_i IN 26..35 LOOP
        v_sale_id := md5('seed:sale:' || lpad(v_i::text, 3, '0'))::uuid;
        UPDATE sale
        SET sale_status = 'CANCELADO',
            payment_status = CASE WHEN payment_status = 'APROBADO' THEN 'REEMBOLSADO'::enum_payment_status ELSE payment_status END
        WHERE sale_id = v_sale_id;
    END LOOP;

    FOR v_i IN 36..50 LOOP
        v_sale_id := md5('seed:sale:' || lpad(v_i::text, 3, '0'))::uuid;
        UPDATE sale SET sale_status = 'REEMBOLSADO' WHERE sale_id = v_sale_id;
        UPDATE sale SET payment_status = 'REEMBOLSADO' WHERE sale_id = v_sale_id;
    END LOOP;
END;
$seed_sale_transitions$;

-- Accesos de ejemplo; los logins exitosos también actualizan users y disparan su journal.
DO $seed_login_logs$
DECLARE
    v_user record;
    v_n integer := 0;
BEGIN
    FOR v_user IN
        SELECT user_id, user_email FROM users WHERE row_status = 'ACTIVE' ORDER BY user_email LIMIT 8
    LOOP
        v_n := v_n + 1;
        INSERT INTO user_login_log (user_id, attempted_email, is_success, ip_address, user_agent, created_at)
        VALUES (v_user.user_id, v_user.user_email, TRUE, format('192.0.2.%s', v_n)::inet, 'Supabase seed / integration test', now() - make_interval(hours => v_n));
    END LOOP;

    INSERT INTO user_login_log (user_id, attempted_email, is_success, failure_reason, ip_address, user_agent)
    SELECT user_id, user_email, FALSE, 'INVALID_CREDENTIALS', '198.51.100.10'::inet, 'Supabase seed / failed login'
    FROM users WHERE row_status = 'ACTIVE' ORDER BY user_email LIMIT 4;

    INSERT INTO user_login_log (user_id, attempted_email, is_success, failure_reason, ip_address, user_agent)
    VALUES (NULL, 'no_existe_seed@example.com', FALSE, 'USER_NOT_FOUND', '203.0.113.10'::inet, 'Supabase seed / unknown user');
END;
$seed_login_logs$;

-- Devoluciones: 15 reintegros cerrados, 2 expedientes terminales y 4 en trámite/aprobación.
DO $seed_returns$
DECLARE
    v_i integer;
    v_return_id uuid;
    v_sale_id uuid;
    v_sale sale%ROWTYPE;
    v_sale_item sale_item%ROWTYPE;
    v_admin_id uuid := md5('seed:user:admin_1@gmail.com')::uuid;
    v_reason enum_return_reason;
    v_resolution enum_return_resolution;
    v_refund numeric(12,2);
BEGIN
    PERFORM set_config('app.current_user', 'seed-returns', TRUE);

    -- Devoluciones aprobadas, inspeccionadas y liquidadas de las ventas 51-65.
    FOR v_i IN 1..15 LOOP
        v_sale_id := md5('seed:sale:' || lpad((50 + v_i)::text, 3, '0'))::uuid;
        v_return_id := md5('seed:return:' || lpad(v_i::text, 3, '0'))::uuid;
        SELECT * INTO v_sale FROM sale WHERE sale_id = v_sale_id;
        v_reason := CASE ((v_i - 1) % 3)
            WHEN 0 THEN 'ARREPENTIMIENTO_LEGAL'::enum_return_reason
            WHEN 1 THEN 'CAMBIO_TALLE'::enum_return_reason
            ELSE 'DEFECTO_FABRICACION'::enum_return_reason
        END;
        v_refund := CASE WHEN v_reason = 'ARREPENTIMIENTO_LEGAL' THEN v_sale.sale_total ELSE v_sale.sale_subtotal - v_sale.sale_discount_amount END;

        INSERT INTO sale_return (
            return_id, sale_id, tracking_token, return_reason, return_resolution, return_status,
            shipping_covered_by_store, return_shipping_guide, refund_amount, customer_notes,
            created_at
        ) VALUES (
            v_return_id, v_sale_id, md5('seed:return-tracking:' || lpad(v_i::text, 3, '0'))::uuid,
            v_reason, 'REEMBOLSO_DINERO', 'SOLICITADA',
            v_reason IN ('ARREPENTIMIENTO_LEGAL', 'DEFECTO_FABRICACION'),
            format('SEED-DEV-%s', lpad(v_i::text, 3, '0')),
            v_refund,
            format('Solicitud de devolución de prueba %s con reintegro total de los renglones.', lpad(v_i::text, 2, '0')),
            now() - interval '1 day'
        );

        INSERT INTO sale_return_item (return_id, sale_item_id, quantity, restock_approved, rejection_reason)
        SELECT v_return_id, si.sale_item_id, si.quantity, NULL, NULL
        FROM sale_item si WHERE si.sale_id = v_sale_id ORDER BY si.sale_item_id;

        UPDATE sale_return SET return_status = 'EN_TRANSITO' WHERE return_id = v_return_id;
        UPDATE sale_return SET return_status = 'RECIBIDO_EN_CONTROL' WHERE return_id = v_return_id;
        UPDATE sale_return
        SET return_status = 'APROBADA',
            inspection_notes = 'Inspección seed aprobada; prendas en condiciones de reintegro.',
            inspection_evidence_path = format('https://storage.example.test/returns/seed-%s.jpg', lpad(v_i::text, 3, '0')),
            inspected_by = v_admin_id,
            inspected_at = now() - interval '2 hours',
            closed_at = now() - interval '1 hour'
        WHERE return_id = v_return_id;
        UPDATE sale_return_item SET restock_approved = TRUE WHERE return_id = v_return_id;

        UPDATE sale SET payment_status = 'REEMBOLSO_PENDIENTE' WHERE sale_id = v_sale_id;
        UPDATE sale SET payment_status = 'REEMBOLSADO', sale_status = 'CERRADO_CON_DEVOLUCION' WHERE sale_id = v_sale_id;
    END LOOP;

    -- Devolución rechazada en inspección (venta 1).
    v_sale_id := md5('seed:sale:001')::uuid;
    v_return_id := md5('seed:return:016')::uuid;
    SELECT * INTO v_sale_item FROM sale_item WHERE sale_id = v_sale_id ORDER BY sale_item_id LIMIT 1;
    INSERT INTO sale_return (return_id, sale_id, tracking_token, return_reason, return_resolution, return_status, shipping_covered_by_store, refund_amount, customer_notes)
    VALUES (v_return_id, v_sale_id, md5('seed:return-tracking:016')::uuid, 'DEFECTO_FABRICACION', 'CREDITO_TIENDA', 'SOLICITADA', TRUE, 0.00, 'Solicitud de prueba rechazada tras inspección física.');
    INSERT INTO sale_return_item (return_id, sale_item_id, quantity, restock_approved, rejection_reason)
    VALUES (v_return_id, v_sale_item.sale_item_id, 1, NULL, NULL);
    UPDATE sale_return SET return_status = 'EN_TRANSITO' WHERE return_id = v_return_id;
    UPDATE sale_return SET return_status = 'RECIBIDO_EN_CONTROL' WHERE return_id = v_return_id;
    UPDATE sale_return SET return_status = 'RECHAZADA', inspection_notes = 'Se observa desgaste no atribuible a defecto de fabricación.', inspected_by = v_admin_id, inspected_at = now(), closed_at = now()
    WHERE return_id = v_return_id;
    UPDATE sale_return_item SET restock_approved = FALSE, rejection_reason = 'Desgaste visible de la suela.' WHERE return_id = v_return_id;

    -- Devolución cancelada por el cliente (venta 2).
    v_sale_id := md5('seed:sale:002')::uuid;
    v_return_id := md5('seed:return:017')::uuid;
    SELECT * INTO v_sale_item FROM sale_item WHERE sale_id = v_sale_id ORDER BY sale_item_id LIMIT 1;
    INSERT INTO sale_return (return_id, sale_id, tracking_token, return_reason, return_resolution, return_status, shipping_covered_by_store, refund_amount, customer_notes)
    VALUES (v_return_id, v_sale_id, md5('seed:return-tracking:017')::uuid, 'ARREPENTIMIENTO_LEGAL', 'CAMBIO_PRODUCTO', 'SOLICITADA', TRUE, 0.00, 'Solicitud de prueba cancelada antes del despacho inverso.');
    INSERT INTO sale_return_item (return_id, sale_item_id, quantity, restock_approved)
    VALUES (v_return_id, v_sale_item.sale_item_id, 1, NULL);
    UPDATE sale_return SET return_status = 'CANCELADA', closed_at = now() WHERE return_id = v_return_id;

    -- Solicitudes recientes de usuarios: SOLICITADA, EN_TRANSITO y RECIBIDO_EN_CONTROL.
    FOR v_i IN 18..20 LOOP
        v_sale_id := md5('seed:sale:' || lpad((54 + v_i)::text, 3, '0'))::uuid;
        v_return_id := md5('seed:return:' || lpad(v_i::text, 3, '0'))::uuid;
        SELECT * INTO v_sale_item FROM sale_item WHERE sale_id = v_sale_id ORDER BY sale_item_id LIMIT 1;
        v_reason := CASE v_i WHEN 18 THEN 'ARREPENTIMIENTO_LEGAL'::enum_return_reason WHEN 19 THEN 'CAMBIO_TALLE'::enum_return_reason ELSE 'DEFECTO_FABRICACION'::enum_return_reason END;
        v_resolution := CASE v_i WHEN 18 THEN 'REEMBOLSO_DINERO'::enum_return_resolution WHEN 19 THEN 'CAMBIO_PRODUCTO'::enum_return_resolution ELSE 'CREDITO_TIENDA'::enum_return_resolution END;
        INSERT INTO sale_return (
            return_id, sale_id, tracking_token, return_reason, return_resolution, return_status,
            shipping_covered_by_store, return_shipping_guide, refund_amount, customer_notes
        ) VALUES (
            v_return_id, v_sale_id, md5('seed:return-tracking:' || lpad(v_i::text, 3, '0'))::uuid,
            v_reason, v_resolution, 'SOLICITADA',
            v_reason IN ('ARREPENTIMIENTO_LEGAL', 'DEFECTO_FABRICACION'),
            CASE WHEN v_i >= 19 THEN format('SEED-DEV-%s', lpad(v_i::text, 3, '0')) ELSE NULL END,
            CASE WHEN v_resolution = 'REEMBOLSO_DINERO' THEN v_sale_item.unit_price ELSE 0.00 END,
            format('Solicitud reciente seed %s para probar estado %s.', v_i, CASE v_i WHEN 18 THEN 'SOLICITADA' WHEN 19 THEN 'EN_TRANSITO' ELSE 'RECIBIDO_EN_CONTROL' END)
        );
        INSERT INTO sale_return_item (return_id, sale_item_id, quantity, restock_approved)
        VALUES (v_return_id, v_sale_item.sale_item_id, 1, NULL);
        IF v_i >= 19 THEN
            UPDATE sale_return SET return_status = 'EN_TRANSITO' WHERE return_id = v_return_id;
        END IF;
        IF v_i = 20 THEN
            UPDATE sale_return SET return_status = 'RECIBIDO_EN_CONTROL', inspection_notes = 'Paquete recibido; inspección pendiente.' WHERE return_id = v_return_id;
        END IF;
    END LOOP;

    -- Devolución aprobada con reembolso autorizado pero aún no liquidado (venta 75).
    v_sale_id := md5('seed:sale:075')::uuid;
    v_return_id := md5('seed:return:021')::uuid;
    SELECT * INTO v_sale FROM sale WHERE sale_id = v_sale_id;
    INSERT INTO sale_return (
        return_id, sale_id, tracking_token, return_reason, return_resolution, return_status,
        shipping_covered_by_store, refund_amount, customer_notes,
        inspection_notes, inspection_evidence_path, inspected_by, inspected_at, closed_at
    ) VALUES (
        v_return_id, v_sale_id, md5('seed:return-tracking:021')::uuid,
        'ARREPENTIMIENTO_LEGAL', 'REEMBOLSO_DINERO', 'SOLICITADA', TRUE,
        v_sale.sale_total, 'Devolución total de prueba aprobada, pendiente de liquidación.',
        'Inspección física aprobada para todos los renglones.', 'https://storage.example.test/returns/seed-021.jpg',
        v_admin_id, now(), now()
    );
    INSERT INTO sale_return_item (return_id, sale_item_id, quantity, restock_approved)
    SELECT v_return_id, si.sale_item_id, si.quantity, TRUE FROM sale_item si WHERE si.sale_id = v_sale_id ORDER BY si.sale_item_id;
    UPDATE sale_return SET return_status = 'EN_TRANSITO' WHERE return_id = v_return_id;
    UPDATE sale_return SET return_status = 'RECIBIDO_EN_CONTROL' WHERE return_id = v_return_id;
    UPDATE sale_return SET return_status = 'APROBADA' WHERE return_id = v_return_id;
END;
$seed_returns$;

-- Comprobantes: Factura C para cada pago calificado no rechazado y Nota de Crédito C para reintegros cerrados.
DO $seed_fiscal_receipts$
DECLARE
    v_cuit bigint := 20000000001;
BEGIN
    WITH eligible AS (
        SELECT s.*, row_number() OVER (ORDER BY s.created_at, s.sale_id)::bigint AS rn
        FROM sale s
        WHERE s.payment_status IN ('APROBADO', 'REEMBOLSO_PENDIENTE', 'REEMBOLSADO')
          AND s.fiscal_rejection = FALSE
          AND NOT EXISTS (
              SELECT 1 FROM fiscal_receipt fr
              WHERE fr.sale_id = s.sale_id AND fr.receipt_type = 'FACTURA_C'
          )
    )
    INSERT INTO fiscal_receipt (
        fiscal_receipt_id, sale_id, return_id, receipt_type, afip_cbte_tipo,
        point_of_sale, receipt_number, cae, cae_due_date, issue_date,
        doc_type, doc_number, customer_name, total_amount, net_amount, qr_payload, created_by
    )
    SELECT
        md5('seed:invoice:' || e.sale_id::text)::uuid,
        e.sale_id,
        NULL,
        'FACTURA_C',
        11,
        1,
        e.rn,
        '1' || lpad(e.rn::text, 13, '0'),
        current_date + 10,
        current_date,
        CASE e.customer_tax_id_type WHEN 'CUIT' THEN 80 WHEN 'DNI' THEN 96 WHEN 'CUIL' THEN 86 WHEN 'PASAPORTE' THEN 94 ELSE 99 END,
        CASE WHEN e.customer_tax_id_number IS NULL OR btrim(e.customer_tax_id_number) = '' THEN '0' ELSE e.customer_tax_id_number END,
        e.customer_name,
        e.sale_total,
        e.sale_total,
        'https://www.afip.gob.ar/fe/qr/?p=' || encode(convert_to(jsonb_build_object(
            'ver', 1,
            'fecha', to_char(current_date, 'YYYY-MM-DD'),
            'cuit', v_cuit,
            'ptoVta', 1,
            'tipoCmp', 11,
            'nroCmp', e.rn,
            'importe', e.sale_total,
            'moneda', 'PES',
            'ctz', 1,
            'tipoDocRec', CASE e.customer_tax_id_type WHEN 'CUIT' THEN 80 WHEN 'DNI' THEN 96 WHEN 'CUIL' THEN 86 WHEN 'PASAPORTE' THEN 94 ELSE 99 END,
            'nroDocRec', CASE WHEN e.customer_tax_id_number IS NULL OR btrim(e.customer_tax_id_number) = '' THEN 0 ELSE regexp_replace(e.customer_tax_id_number, '[^0-9]', '', 'g')::bigint END,
            'tipoCodAut', 'E',
            'codAut', ('1' || lpad(e.rn::text, 13, '0'))::bigint
        )::text, 'UTF8'), 'base64'),
        md5('seed:user:admin_1@gmail.com')::uuid
    FROM eligible e;

    WITH eligible AS (
        SELECT sr.*, s.customer_name, fr.doc_type, fr.doc_number,
               row_number() OVER (ORDER BY sr.created_at, sr.return_id)::bigint AS rn
        FROM sale_return sr
        JOIN sale s ON s.sale_id = sr.sale_id
        JOIN fiscal_receipt fr ON fr.sale_id = s.sale_id AND fr.receipt_type = 'FACTURA_C'
        WHERE sr.return_status = 'APROBADA'
          AND sr.return_resolution = 'REEMBOLSO_DINERO'
          AND s.sale_status = 'CERRADO_CON_DEVOLUCION'
          AND NOT EXISTS (
              SELECT 1 FROM fiscal_receipt existing
              WHERE existing.return_id = sr.return_id AND existing.receipt_type = 'NOTA_CREDITO_C'
          )
    )
    INSERT INTO fiscal_receipt (
        fiscal_receipt_id, sale_id, return_id, receipt_type, afip_cbte_tipo,
        point_of_sale, receipt_number, cae, cae_due_date, issue_date,
        doc_type, doc_number, customer_name, total_amount, net_amount, qr_payload, created_by
    )
    SELECT
        md5('seed:credit-note:' || e.return_id::text)::uuid,
        e.sale_id,
        e.return_id,
        'NOTA_CREDITO_C',
        13,
        1,
        e.rn,
        '2' || lpad(e.rn::text, 13, '0'),
        current_date + 10,
        current_date,
        e.doc_type,
        e.doc_number,
        e.customer_name,
        e.refund_amount,
        e.refund_amount,
        'https://www.afip.gob.ar/fe/qr/?p=' || encode(convert_to(jsonb_build_object(
            'ver', 1,
            'fecha', to_char(current_date, 'YYYY-MM-DD'),
            'cuit', v_cuit,
            'ptoVta', 1,
            'tipoCmp', 13,
            'nroCmp', e.rn,
            'importe', e.refund_amount,
            'moneda', 'PES',
            'ctz', 1,
            'tipoDocRec', e.doc_type,
            'nroDocRec', CASE WHEN e.doc_number = '0' THEN 0 ELSE regexp_replace(e.doc_number, '[^0-9]', '', 'g')::bigint END,
            'tipoCodAut', 'E',
            'codAut', ('2' || lpad(e.rn::text, 13, '0'))::bigint
        )::text, 'UTF8'), 'base64'),
        md5('seed:user:admin_1@gmail.com')::uuid
    FROM eligible e;
END;
$seed_fiscal_receipts$;

-- Verificación final: ante cualquier desviación, se revierte la corrida completa.
DO $seed_assertions$
DECLARE
    v_count bigint;
BEGIN
    SELECT count(*) INTO v_count FROM users;
    IF v_count <> 40 THEN RAISE EXCEPTION 'Se esperaban 40 usuarios; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM color;
    IF v_count <> 10 THEN RAISE EXCEPTION 'Se esperaban 10 colores; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM product;
    IF v_count <> 35 THEN RAISE EXCEPTION 'Se esperaban 35 productos; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM variant;
    IF v_count <> 525 THEN RAISE EXCEPTION 'Se esperaban 525 variantes; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM image;
    IF v_count <> 315 THEN RAISE EXCEPTION 'Se esperaban 315 imágenes; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM shipping_zone;
    IF v_count <> 4 THEN RAISE EXCEPTION 'Se esperaban 4 zonas; encontradas %', v_count; END IF;
    SELECT count(*) INTO v_count FROM cart_item;
    IF v_count <> 60 THEN RAISE EXCEPTION 'Se esperaban 60 ítems de carrito; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM sale;
    IF v_count <> 75 THEN RAISE EXCEPTION 'Se esperaban 75 ventas; encontradas %', v_count; END IF;
    SELECT count(*) INTO v_count FROM sale_item;
    IF v_count <> 225 THEN RAISE EXCEPTION 'Se esperaban 225 renglones de venta; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM sale_return;
    IF v_count <> 21 THEN RAISE EXCEPTION 'Se esperaban 21 expedientes de devolución; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM sale_return_item;
    IF v_count <> 53 THEN RAISE EXCEPTION 'Se esperaban 53 renglones de devolución; encontrados %', v_count; END IF;
    SELECT count(*) INTO v_count FROM users_jn;
    IF v_count = 0 THEN RAISE EXCEPTION 'No se generó historial users_jn'; END IF;
    SELECT count(*) INTO v_count FROM sale_jn;
    IF v_count = 0 THEN RAISE EXCEPTION 'No se generó historial sale_jn'; END IF;
    SELECT count(*) INTO v_count FROM sale_return_jn;
    IF v_count = 0 THEN RAISE EXCEPTION 'No se generó historial sale_return_jn'; END IF;
    IF EXISTS (
        SELECT 1 FROM sale s
        WHERE s.payment_status IN ('APROBADO', 'REEMBOLSO_PENDIENTE', 'REEMBOLSADO')
          AND s.fiscal_rejection = FALSE
          AND NOT EXISTS (SELECT 1 FROM fiscal_receipt fr WHERE fr.sale_id = s.sale_id AND fr.receipt_type = 'FACTURA_C')
    ) THEN RAISE EXCEPTION 'Falta Factura C para una venta con pago calificado'; END IF;
    IF EXISTS (
        SELECT 1 FROM sale_return sr JOIN sale s ON s.sale_id = sr.sale_id
        WHERE sr.return_status = 'APROBADA' AND sr.return_resolution = 'REEMBOLSO_DINERO'
          AND s.sale_status = 'CERRADO_CON_DEVOLUCION'
          AND NOT EXISTS (SELECT 1 FROM fiscal_receipt fr WHERE fr.return_id = sr.return_id AND fr.receipt_type = 'NOTA_CREDITO_C')
    ) THEN RAISE EXCEPTION 'Falta Nota de Crédito C para una devolución liquidada'; END IF;
    IF EXISTS (SELECT 1 FROM sale WHERE payment_method = 'EFECTIVO' AND shipping_method = 'ENVIO_CORREO_NACIONAL') THEN
        RAISE EXCEPTION 'Se encontró EFECTIVO combinado con ENVIO_CORREO_NACIONAL';
    END IF;
END;
$seed_assertions$;

COMMIT;
