# 🚀 SETUP AUTH - SPRINT 1
## Guía completa de implementación

---

## 📋 ORDEN DE EJECUCIÓN

### **PASO 1: Configurar Auth en Supabase Dashboard**
1. Ve a tu proyecto en Supabase → **Authentication** → **Providers**
2. Habilitar **Email** (ya está habilitado por defecto)
3. Habilitar **Google OAuth**:
   - Click en "Google"
   - Activa "Enable Sign in with Google"
   - Guarda (usa las credenciales default de Supabase por ahora)
4. En **Authentication** → **URL Configuration**:
   - Site URL: `http://localhost:5173` (desarrollo)
   - Redirect URLs: Agregar `http://localhost:5173/**`

---

### **PASO 2: Ejecutar Script SQL**
1. Abre **SQL Editor** en Supabase
2. Copia y pega el contenido de `sprint1_auth_tables.sql`
3. Click en **Run** (ejecutará todo de una vez)
4. Verificá que se crearon:
   - Tabla `roles` con 4 registros
   - Tabla `user_profiles`
   - Trigger `trg_create_user_profile`
   - Vista `v_users_with_roles`
   - Campo `id_user` en tabla `sales`

---

### **PASO 3: Instalar archivos React**

#### **3.1 - Crear carpeta contexts**
```bash
mkdir src/contexts
```

#### **3.2 - Copiar archivos**
```
src/
├── contexts/
│   └── AuthContext.jsx    ← NUEVO
├── hooks/
│   └── useAuth.js         ← NUEVO
└── pages/
    ├── Login.jsx          ← NUEVO
    └── Register.jsx       ← NUEVO
```

---

### **PASO 4: Actualizar main.jsx**

Envolver toda la app con `AuthProvider`:

```jsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import './index.scss';
import Router from './router/Router.jsx';
import { DataContextProvider } from './contexts/Data.jsx';
import { AuthProvider } from './contexts/AuthContext.jsx';  // ← NUEVO

createRoot(document.getElementById('root')).render(
    <StrictMode>
        <AuthProvider>  {/* ← NUEVO */}
            <DataContextProvider>
                <BrowserRouter>
                    <Router />
                </BrowserRouter>
            </DataContextProvider>
        </AuthProvider>  {/* ← NUEVO */}
    </StrictMode>
);
```

---

### **PASO 5: Agregar rutas en Router.jsx**

Abre `src/router/Router.jsx` y agrega:

```jsx
import Login from '../pages/Login';
import Register from '../pages/Register';

// Dentro de tus rutas:
<Route path="/login" element={<Login />} />
<Route path="/register" element={<Register />} />
```

---

## 🧪 TESTEO

### **Test 1: Registro con Email**
1. Ir a `http://localhost:5173/register`
2. Completar form con email/password
3. Click en "Crear cuenta"
4. Revisar email (Supabase envía confirmación)
5. Verificar en Supabase:
   - **Authentication** → **Users** → debería aparecer el nuevo user
   - **Table Editor** → `user_profiles` → debería tener un registro con `id_role = 1` (customer)

### **Test 2: Login con Email**
1. Ir a `http://localhost:5173/login`
2. Ingresar email/password del registro anterior
3. Click en "Iniciar sesión"
4. Abrir DevTools → Console → deberías ver el `user` y `profile` logueados

### **Test 3: Google OAuth**
1. Click en "Continuar con Google"
2. Seleccionar cuenta de Google
3. Autorizar
4. Redirect automático a `/`
5. Verificar en `user_profiles` que se creó el registro

---

## 📦 USO DEL HOOK `useAuth()`

Ahora podés usar auth en cualquier componente:

```jsx
import { useAuth } from '../hooks/useAuth';

const MiComponente = () => {
    const { user, profile, role, isAdmin, signOut } = useAuth();

    if (!user) return <p>No logueado</p>;

    return (
        <div>
            <h2>Hola, {profile?.full_name || user.email}</h2>
            <p>Rol: {role}</p>
            {isAdmin && <button>Panel Admin</button>}
            <button onClick={signOut}>Cerrar sesión</button>
        </div>
    );
};
```

---

## 🔒 PRÓXIMOS PASOS (Sprint 2)

Una vez que esto funcione, en el siguiente sprint haremos:
1. **Rutas protegidas** (`<ProtectedRoute>`)
2. **Mostrar/ocultar UI** según rol
3. **Conectar `sales` con `id_user`** en el checkout

---

## ⚠️ TROUBLESHOOTING

### Error: "Invalid login credentials"
→ Asegurate de confirmar el email desde el link que Supabase envió

### Error: "User already registered"
→ El email ya existe, usá otro o intentá login

### Google OAuth no funciona
→ Verificá redirect URLs en Supabase Dashboard

### `user_profiles` no se crea automáticamente
→ Revisá que el trigger `trg_create_user_profile` esté activo en SQL Editor

---

## 📝 NOTAS

- Por defecto, Supabase requiere **confirmación de email**. Podés desactivarlo en:
  **Authentication** → **Email Auth** → Desactivar "Enable email confirmations"
  
- Los usuarios creados desde Google OAuth **no necesitan confirmación**

- El campo `id_user` en `sales` quedará `NULL` para compras anónimas (esto es correcto)
