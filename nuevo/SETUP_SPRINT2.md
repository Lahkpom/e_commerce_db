# 🚀 SETUP SPRINT 2 - RUTAS PROTEGIDAS Y UI CONDICIONAL
## Roles y Permisos

---

## 📋 ARCHIVOS GENERADOS

### **1. Componentes de Auth**
- `ProtectedRoute.jsx` → Protege rutas completas
- `RoleGate.jsx` → Muestra/oculta UI según rol
- `AdminPanel.jsx` → Ejemplo de página protegida

### **2. Componentes actualizados**
- `Navbar.jsx` → Navbar con UI condicional según auth/rol

---

## 📦 INSTALACIÓN

### **Paso 1: Crear carpeta `auth`**
```bash
mkdir src/components/auth
```

### **Paso 2: Copiar archivos**
```
src/
├── components/
│   └── auth/
│       ├── ProtectedRoute.jsx  ← NUEVO
│       └── RoleGate.jsx         ← NUEVO
└── pages/
    └── AdminPanel.jsx           ← NUEVO
```

### **Paso 3: Actualizar Navbar**
Reemplazá tu `Navbar.jsx` actual con el nuevo que te di (o copiá las partes relevantes)

---

## 🔒 USO DE `<ProtectedRoute>`

### **En Router.jsx:**

```jsx
import ProtectedRoute from '../components/auth/ProtectedRoute';
import AdminPanel from '../pages/AdminPanel';

// Dentro de tus rutas:

{/* Ruta pública - cualquiera puede acceder */}
<Route path="/productos" element={<ProductsContainer />} />

{/* Requiere estar logueado (cualquier rol) */}
<Route 
    path="/mi-cuenta" 
    element={
        <ProtectedRoute requiredRole="any">
            <MiCuenta />
        </ProtectedRoute>
    } 
/>

{/* Solo para customers */}
<Route 
    path="/mis-pedidos" 
    element={
        <ProtectedRoute requiredRole="customer">
            <MisPedidos />
        </ProtectedRoute>
    } 
/>

{/* Solo para admins y superadmins */}
<Route 
    path="/admin" 
    element={
        <ProtectedRoute requiredRole={['admin', 'superadmin']}>
            <AdminPanel />
        </ProtectedRoute>
    } 
/>

{/* Solo para superadmins */}
<Route 
    path="/admin/crear-admin" 
    element={
        <ProtectedRoute requiredRole="superadmin">
            <CrearAdmin />
        </ProtectedRoute>
    } 
/>
```

---

## 👁️ USO DE `<RoleGate>`

### **Para mostrar/ocultar UI dentro de componentes:**

```jsx
import RoleGate from '../components/auth/RoleGate';

const MiComponente = () => {
    return (
        <div>
            <h1>Productos</h1>

            {/* Solo admins ven este botón */}
            <RoleGate allowedRoles={['admin', 'superadmin']}>
                <button>Editar Producto</button>
            </RoleGate>

            {/* Solo superadmins ven esto */}
            <RoleGate allowedRoles="superadmin">
                <button>Eliminar Producto</button>
            </RoleGate>

            {/* Solo mayoristas ven precio especial */}
            <RoleGate allowedRoles="wholesaler">
                <p>Precio mayorista: $500</p>
            </RoleGate>

            {/* Con fallback (contenido alternativo) */}
            <RoleGate 
                allowedRoles={['admin', 'superadmin']}
                fallback={<p>No tenés permisos para ver esto</p>}
            >
                <div>Panel de administración</div>
            </RoleGate>
        </div>
    );
};
```

---

## 🎨 EJEMPLOS PRÁCTICOS

### **Ejemplo 1: Botones condicionales en ProductCard**

```jsx
import RoleGate from '../components/auth/RoleGate';
import useAuth from '../hooks/useAuth';

const ProductCard = ({ product }) => {
    const { isWholesaler } = useAuth();

    return (
        <div className="card">
            <img src={product.image} />
            <h3>{product.name}</h3>
            
            {/* Precio normal para customers */}
            <p>Precio: ${product.price}</p>

            {/* Precio especial para mayoristas */}
            <RoleGate allowedRoles="wholesaler">
                <p className="text-success">
                    Precio mayorista: ${product.wholesalePrice}
                </p>
            </RoleGate>

            {/* Botones de administración */}
            <RoleGate allowedRoles={['admin', 'superadmin']}>
                <div className="admin-actions">
                    <button>Editar</button>
                    <button>Cambiar Stock</button>
                </div>
            </RoleGate>
        </div>
    );
};
```

### **Ejemplo 2: Navegación condicional**

```jsx
import { Link } from 'react-router-dom';
import useAuth from '../hooks/useAuth';

const Sidebar = () => {
    const { isAdmin, isSuperAdmin, isWholesaler } = useAuth();

    return (
        <nav>
            <Link to="/">Inicio</Link>
            <Link to="/productos">Productos</Link>

            {isWholesaler && (
                <Link to="/descuentos-mayorista">
                    Descuentos Mayorista
                </Link>
            )}

            {isAdmin && (
                <>
                    <Link to="/admin/productos">Gestionar Productos</Link>
                    <Link to="/admin/ventas">Ver Ventas</Link>
                    <Link to="/admin/usuarios">Usuarios Mayoristas</Link>
                </>
            )}

            {isSuperAdmin && (
                <Link to="/admin/crear-admin">
                    Crear Administrador
                </Link>
            )}
        </nav>
    );
};
```

### **Ejemplo 3: Checkout con usuario logueado vs anónimo**

```jsx
import useAuth from '../hooks/useAuth';

const Checkout = () => {
    const { user, profile } = useAuth();

    return (
        <div>
            <h2>Checkout</h2>

            {user ? (
                // Usuario logueado - autocompletar datos
                <form>
                    <input 
                        type="text" 
                        value={profile?.full_name} 
                        readOnly 
                    />
                    <input 
                        type="email" 
                        value={user.email} 
                        readOnly 
                    />
                    <input 
                        type="tel" 
                        value={profile?.phone} 
                    />
                    {/* ... */}
                </form>
            ) : (
                // Usuario anónimo - pedir datos
                <div>
                    <p>Comprá como invitado o <Link to="/login">iniciá sesión</Link></p>
                    <form>
                        <input type="text" placeholder="Nombre completo" required />
                        <input type="email" placeholder="Email" required />
                        <input type="tel" placeholder="Teléfono" required />
                        {/* ... */}
                    </form>
                </div>
            )}
        </div>
    );
};
```

---

## ⚙️ CONFIGURACIÓN COMPLETA EN `Router.jsx`

```jsx
import { Routes, Route } from 'react-router-dom';
import ProtectedRoute from '../components/auth/ProtectedRoute';

// Pages
import Home from '../pages/Home';
import ProductsContainer from '../pages/ProductsContainer';
import ProductsDetails from '../pages/ProductsDetails';
import Login from '../pages/Login';
import Register from '../pages/Register';
import AdminPanel from '../pages/AdminPanel';
import MiCuenta from '../pages/MiCuenta';
import MisPedidos from '../pages/MisPedidos';

const Router = () => {
    return (
        <Routes>
            {/* Rutas públicas */}
            <Route path="/" element={<Home />} />
            <Route path="/productos" element={<ProductsContainer />} />
            <Route path="/productos/:id_product" element={<ProductsDetails />} />
            <Route path="/login" element={<Login />} />
            <Route path="/registrarse" element={<Register />} />

            {/* Rutas protegidas - requieren login */}
            <Route 
                path="/mi-cuenta" 
                element={
                    <ProtectedRoute requiredRole="any">
                        <MiCuenta />
                    </ProtectedRoute>
                } 
            />
            <Route 
                path="/mis-pedidos" 
                element={
                    <ProtectedRoute requiredRole="any">
                        <MisPedidos />
                    </ProtectedRoute>
                } 
            />

            {/* Rutas admin - solo admins y superadmins */}
            <Route 
                path="/admin" 
                element={
                    <ProtectedRoute requiredRole={['admin', 'superadmin']}>
                        <AdminPanel />
                    </ProtectedRoute>
                } 
            />

            {/* Ruta superadmin - solo superadmins */}
            <Route 
                path="/admin/crear-admin" 
                element={
                    <ProtectedRoute requiredRole="superadmin" redirectTo="/admin">
                        <CrearAdmin />
                    </ProtectedRoute>
                } 
            />
        </Routes>
    );
};

export default Router;
```

---

## 🧪 TESTING

### **Test 1: Acceso a rutas según rol**
1. Sin login → `/admin` → Redirige a `/login`
2. Login como customer → `/admin` → Redirige a `/`
3. Login como admin → `/admin` → ✅ Accede
4. Login como admin → `/admin/crear-admin` → Redirige a `/admin`
5. Login como superadmin → `/admin/crear-admin` → ✅ Accede

### **Test 2: UI condicional en Navbar**
1. Sin login → Ver "Iniciar Sesión" y "Registrarse"
2. Con login customer → Ver dropdown con nombre, NO ver "Panel Admin"
3. Con login admin → Ver dropdown + "Panel Admin"

### **Test 3: RoleGate en componentes**
1. Agregar `<RoleGate>` en ProductCard
2. Login como admin → Ver botones de edición
3. Login como customer → NO ver botones

---

## 📝 NOTAS IMPORTANTES

- **`requiredRole="any"`** → Cualquier usuario logueado (sin importar el rol)
- **`requiredRole="customer"`** → Solo customers
- **`requiredRole={['admin', 'superadmin']}`** → Admins O superadmins
- **`redirectTo="/ruta"`** → Dónde redirigir si no tiene acceso (default: `/`)

- **RoleGate NO redirige**, solo muestra/oculta UI
- **ProtectedRoute SÍ redirige** si no tiene acceso

---

## ✅ CHECKLIST

- [ ] Copiar `ProtectedRoute.jsx` y `RoleGate.jsx`
- [ ] Crear `AdminPanel.jsx` (o tu versión)
- [ ] Actualizar `Router.jsx` con rutas protegidas
- [ ] Actualizar `Navbar.jsx` con UI condicional
- [ ] Testear acceso a `/admin` con diferentes roles
- [ ] Testear `<RoleGate>` en algún componente
- [ ] Verificar redirects funcionan correctamente

---

¿Listo para implementar? Cualquier duda avisame!
