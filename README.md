# MOVA

App de cliente (web) conectada a Supabase: login, home, entrenamientos, nutrición, perfil y check-in semanal. Marca paraguas: "Move With Purpose".

## 1. Configurar la base de datos

1. Entra a tu proyecto en [supabase.com](https://supabase.com/dashboard/project/yaqiwakfoeaknmdgyzrl)
2. Ve a **SQL Editor** → **New query**
3. Copia todo el contenido de [`supabase/schema.sql`](supabase/schema.sql), pégalo, y haz clic en **Run**
4. Verifica en **Storage** que se creó un bucket llamado `photos`

Esto crea todas las tablas, seguridad (RLS), un split de ejemplo de 3 días (Lower Body / Upper Body / Conditioning), y configura que cada usuario nuevo reciba automáticamente su perfil y metas de nutrición al registrarse.

**Nota:** volver a correr este script borra todos los datos de entrenamientos/nutrición/check-ins (no las cuentas de usuario). Cuando tengas tu programa real, edita la sección "SEED" del archivo con tus propios días/ejercicios.

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

## 4. (Opcional) Tu propia clave de USDA para búsqueda de alimentos

La búsqueda de alimentos en `log-meal.html` usa la API gratuita de USDA FoodData Central con la clave pública `DEMO_KEY`, que tiene un límite bajo de solicitudes por hora. Para uso real, consigue tu propia clave gratuita (sin costo, sin tarjeta) en https://fdc.nal.usda.gov/api-key-signup y reemplázala en [`js/nutritionApi.js`](js/nutritionApi.js) (variable `USDA_API_KEY`).

## Estructura

- `index.html` — login / registro
- `home.html` — resumen semanal
- `workout.html` — split semanal (lista de días)
- `workout-day.html` — secciones y ejercicios de un día
- `workout-exercise.html` — registrar series/peso/notas de un ejercicio, con avance automático
- `nutrition.html` / `log-meal.html` — macros del día y registrar comidas (con auto-cálculo vía USDA)
- `profile.html` — peso corporal, % grasa/músculo, fotos de progreso
- `checkin.html` — check-in semanal
- `js/` — cliente de Supabase, autenticación, navegación compartida, búsqueda de alimentos
- `supabase/schema.sql` — esquema completo de base de datos
