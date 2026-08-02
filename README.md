# Move With Purpose

App de cliente (web) conectada a Supabase: login, home, entrenamientos, nutrición, perfil y check-in semanal.

## 1. Configurar la base de datos

1. Entra a tu proyecto en [supabase.com](https://supabase.com/dashboard/project/yaqiwakfoeaknmdgyzrl)
2. Ve a **SQL Editor** → **New query**
3. Copia todo el contenido de [`supabase/schema.sql`](supabase/schema.sql), pégalo, y haz clic en **Run**
4. Verifica en **Storage** que se creó un bucket llamado `photos`

Esto crea todas las tablas, seguridad (RLS), un programa de entrenamiento de ejemplo ("Lower Body", 8 ejercicios), y configura que cada usuario nuevo reciba automáticamente su perfil y metas de nutrición al registrarse.

## 2. (Opcional) Desactivar confirmación de email para pruebas rápidas

Por defecto Supabase pide confirmar el correo antes de poder iniciar sesión. Para probar más rápido:
**Authentication → Providers → Email → desactiva "Confirm email"**.
Puedes reactivarlo cuando la app esté lista para usuarios reales.

## 3. Abrir la app

No requiere instalación. Simplemente abre `index.html` en tu navegador (doble clic, o clic derecho → Abrir con → navegador).

Si prefieres servirla localmente (recomendado, evita cualquier restricción del navegador con archivos locales):

```bash
cd "/Users/adriananieto/Downloads/MOVE WITH PURPOSE APP"
python3 -m http.server 8000
```

Luego visita `http://localhost:8000`.

## Estructura

- `index.html` — login / registro
- `home.html` — resumen semanal
- `workout.html` — registrar series del entrenamiento del día
- `nutrition.html` / `log-meal.html` — macros del día y registrar comidas
- `profile.html` — peso corporal, fotos de progreso
- `checkin.html` — check-in semanal
- `js/` — cliente de Supabase, autenticación, navegación compartida
- `supabase/schema.sql` — esquema completo de base de datos
