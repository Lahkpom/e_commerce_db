CREATE TABLE cart_item (
    user_id     UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    variant_id  BIGINT      NOT NULL REFERENCES variant(variant_id) ON DELETE CASCADE,
    quantity    INTEGER     NOT NULL CHECK (quantity > 0) DEFAULT 1,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NULL,
    
    PRIMARY KEY (user_id, variant_id)
);
-- ########################################################################################
CREATE INDEX idx_cart_item_user      ON cart_item(user_id);
CREATE INDEX idx_cart_item_variant   ON cart_item(variant_id);
-- Deberían ser un idx compuesto? Ya búsquedas van a hacerse por user_id seguramente
-- ########################################################################################
CREATE TRIGGER trg_cart_item_updated_at
    BEFORE UPDATE ON cart_item
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE cart_item               IS 'Carrito de compras de usuarios registrados, persiste y se muestra al loggearse.';
COMMENT ON COLUMN cart_item.user_id      IS 'Usuario dueño del carrito';
COMMENT ON COLUMN cart_item.variant_id   IS 'Variante del producto en el carrito'; 