CREATE TABLE cart (
    user_id     UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    variant_id  UUID        NOT NULL REFERENCES variant(variant_id) ON DELETE CASCADE,
    quantity    INTEGER     NOT NULL CHECK (quantity > 0) DEFAULT 1,
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NULL,
    
    PRIMARY KEY (user_id, variant_id)
);
-- ########################################################################################
CREATE INDEX idx_cart_user ON cart(user_id);
-- ########################################################################################
CREATE TRIGGER trg_cart_updated_at
    BEFORE UPDATE ON cart
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
-- ########################################################################################
COMMENT ON TABLE cart               IS 'Carrito de compras de usuarios registrados, persiste y se muestra al loggearse.';
COMMENT ON COLUMN cart.user_id      IS 'Usuario dueño del carrito';
COMMENT ON COLUMN cart.variant_id   IS 'Variante del producto en el carrito'; 