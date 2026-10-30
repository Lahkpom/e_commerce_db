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

-- Índices
CREATE INDEX idx_sale_return_item_return    ON sale_return_item(return_id);
CREATE INDEX idx_sale_return_item_sale_item ON sale_return_item(sale_item_id);
CREATE INDEX idx_sale_return_item_variant   ON sale_return_item(variant_id);

-- Restricción para evitar registrar dos veces el mismo renglón de compra en una misma solicitud
CREATE UNIQUE INDEX uq_return_sale_item ON sale_return_item(return_id, sale_item_id);

-- Comentarios documentales
COMMENT ON TABLE sale_return_item                   IS 'Desglose renglón por renglón de las prendas físicas reclamadas para devolución o cambio.';
COMMENT ON COLUMN sale_return_item.sale_item_id     IS 'Renglón inmutable de la compra que se está retornando.';
COMMENT ON COLUMN sale_return_item.quantity         IS 'Unidades que el cliente devuelve de este renglón específico.';
COMMENT ON COLUMN sale_return_item.restock_approved IS 'Indica si la prenda reingresa al stock activo de la tienda tras el peritaje físico.';
COMMENT ON COLUMN sale_return_item.rejection_reason IS 'Fundamento explícito del rechazo de reingreso o descarte de la prenda.';