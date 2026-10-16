CREATE TABLE cart_item (
    user_id     UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    variant_id  BIGINT      NOT NULL REFERENCES variant(variant_id) ON DELETE CASCADE,
    quantity    INTEGER     NOT NULL CHECK (quantity > 0 AND quantity <= 10000) DEFAULT 1,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NULL,
    
    PRIMARY KEY (user_id, variant_id)
);
-- ########################################################################################
CREATE INDEX idx_cart_item_variant ON cart_item(variant_id);
-- ########################################################################################
CREATE TRIGGER trg_cart_item_updated_at
    BEFORE UPDATE ON cart_item
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE cart_item               IS 'Items del carrito de compras para usuarios autenticados. Persistencia con borrado físico.';
COMMENT ON COLUMN cart_item.user_id      IS 'Usuario propietario del item del carrito.';
COMMENT ON COLUMN cart_item.variant_id   IS 'Variante del producto en el carrito'; 