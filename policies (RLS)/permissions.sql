-- ----------------------------------------------------------------------------
-- POLÍTICAS RLS (Row Level Security) - SEGURIDAD
-- ----------------------------------------------------------------------------

-- Habilitar RLS en todas las tablas principales
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;