# HerEchoes — OPERATIONS.md
> Referencia rápida de operaciones frecuentes
> Última actualización: 2026-09-16

---

## 🔢 REGLA #1 — Siempre incrementar pubspec antes de subir build

```yaml
# pubspec.yaml
version: 1.0.5+20   ← versión_marketing+build_number
```

**Ambos números siempre suben juntos.**
Si la versión marketing no cambia, Apple rechaza con "train version is closed".

⚠️ Esta regla aplica **solo a builds de código** (cambios en Dart, UI, lógica). Desde build 1.0.5 (sesión 2026-08-17), el contenido (`her_echoes.json` e imágenes) **ya no requiere build** — ver sección CARDS más abajo.

---

## 🃏 WILDCARDS — Editar o cambiar

La wildcard NO requiere nuevo build. Cambios son inmediatos para todos los usuarios.

### Cambiar la wildcard activa

```bash
# 1. Editar el archivo
code ~/herechoes/assets/data/wildcard.json

# 2. Estructura del JSON (array con un único objeto)
[
  {
    "woman_id": "nombre_apellido",
    "full_name": "Nombre Completo",
    "event_date": "MM/DD",
    "is_free": "VERDADERO",
    "image_card_ID": "apellido_01",
    "pro-tag01_en": "Tag 1",
    "pro-tag02_en": "Tag 2",
    "pro-tag01_es": "Tag 1 ES",
    "pro-tag02_es": "Tag 2 ES",
    "_is_wildcard": true
  }
]

# 3. Commit y push
cd ~/herechoes
git add assets/data/wildcard.json
git commit -m "content: update wildcard → nombre"
git push origin main
```

⚠️ El campo `_is_wildcard: true` es obligatorio — sin él no aparece el badge especial.

⚠️ **Formato de fecha corregido:** `event_date` es **MM/DD**, no DD/MM (ver regla crítica en la sección CARDS más abajo — este documento tenía el formato invertido).

---

## 🖼️ IMÁGENES — Agregar nuevas cards a GitHub

Las imágenes se cargan en tiempo real desde GitHub. NO requieren nuevo build.

```bash
# 1. Copiar imágenes al repo local
cp ~/Downloads/nueva_01.webp ~/herechoes/images/cards/

# Naming convention: apellido_01.webp (todo minúsculas, sin espacios)
# Ejemplos: curie_01.webp, kahlo_01.webp, tubman_01.webp

# 2. Verificar que existe
ls ~/herechoes/images/cards/ | grep nueva

# 3. Commit y push
cd ~/herechoes
git add images/cards/
git commit -m "content: add images for [nombres]"
git push origin main
```

URL resultante automática:
`https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/apellido_01.webp`

⚠️ **Regla aprendida (repetida 3 veces: sesión 27, sesión 2026-08-17, sesión 2026-09-16):** las imágenes se acumulan en local sin subir. Correr `git status` con frecuencia, no solo cuando se nota una card rota.

---

## 📋 CARDS — Agregar nuevas mujeres al JSON

### 🟢 Desde build 1.0.5 (sesión 2026-08-17), el JSON YA NO requiere nuevo build

`her_echoes.json` se descarga desde GitHub en cada apertura de la app (con caché offline y el asset local como respaldo de emergencia). Confirmado funcionando en producción en sesión 2026-09-16: un push a GitHub actualizó una card en la app abierta, sin reiniciarla.

**Esto aplica solo a usuarios en build 1.0.5 (20) o superior.** Usuarios en versiones anteriores siguen viendo el JSON viejo empaquetado hasta que actualicen la app.

```bash
# Editar el JSON
code ~/herechoes/assets/data/her_echoes.json
```

### Estructura de cada entrada
```json
{
  "event_date": "MM/DD",
  "past_date": 1900,
  "woman_id": "nombre_apellido_01",
  "on_this_date_en": "...",
  "on_this_date_es": "...",
  "full_name": "Nombre Completo",
  "pro-tag01_en": "Profession",
  "pro-tag02_en": "Century",
  "pro-tag01_es": "Profesión",
  "pro-tag02_es": "Siglo",
  "quote_text_en": "Quote in English.",
  "quote_text_es": "Cita en español.",
  "birth_date": "...",
  "birth_place": "...",
  "death_date": "",
  "death_place": "",
  "bio_en": "Biography in English.",
  "bio_es": "Biografía en español.",
  "legacy_en": "Legacy in English.",
  "legacy_es": "Legado en español.",
  "image_card_url": "",
  "is_free": "VERDADERO",
  "source_01": "https://...",
  "source_02": "",
  "source_03": "",
  "source_04": "",
  "source_05": "",
  "image_card_ID": "apellido_01"
}
```

⚠️ Este es el esqueleto de campos. El formato real y completo (secciones `[S]`/`[P]` en bio/legacy, bilingüe, con fuentes verificadas) se define en el flujo de trabajo con IA — ver ejemplos ya cargados en el dataset.

### ⚠️ Reglas críticas del JSON

- **Formato de fecha:** `event_date` es **MM/DD** — NUNCA DD/MM.
  - ✅ `"05/15"` para 15 de mayo
  - ❌ `"15/05"` — las cards nunca aparecerán en su día
  - 🔴 **Esta regla estaba invertida en versiones anteriores de este documento** y causó el bug crítico de sesión 27 (contenido bloqueado para todos los usuarios FREE). El dataset completo está normalizado a MM/DD desde esa sesión — no revertir.
- **is_free:** `"VERDADERO"` o `"FALSO"` — en español, en mayúsculas.
- **image_card_ID:** debe coincidir EXACTAMENTE con el nombre del archivo sin extensión.
  - Si archivo es `noether_01.webp` → `"image_card_ID": "noether_01"`
  - ❌ NO usar nombre completo: `"emmy_noether_01"` si el archivo es `noether_01.webp`
- **Cada día debe tener mínimo 3 entradas**, con al menos 1 en `is_free: "VERDADERO"`. Antes de eliminar cualquier registro, verificar cuántas entradas quedan ese día — si queda menos de 3, reemplazar por una mujer nueva verificada en vez de solo borrar.
- **Comillas dentro de campos de texto:** cualquier comilla recta `"` dentro de `bio_en`, `bio_es`, `legacy_en`, `legacy_es`, `on_this_date_en/es` o `quote_text_en/es` (por nombres de obras, canciones, citas dentro de citas) **debe escaparse como `\"`**. Una comilla sin escapar rompe el JSON completo. (Caso real: sesión 2026-09-16, registro de Mamie Smith con `"Crazy Blues"` sin escapar.)

### Después de editar el JSON

```bash
cd ~/herechoes

# 1. VALIDAR SIEMPRE antes de commitear — paso obligatorio, no opcional
python3 -m json.tool assets/data/her_echoes.json > /dev/null && echo "JSON OK" || echo "JSON INVÁLIDO"

# 2. Si dice JSON INVÁLIDO, el mensaje de error indica línea y columna.
#    NO commitear hasta que diga "JSON OK" — un JSON roto tumba la app
#    para todos los usuarios en tiempo real, sin revisión de Apple de por medio.

# 3. Commit y push
git add assets/data/her_echoes.json
git commit -m "content: add cards for [fechas/nombres]"
git push origin main

# 4. Commit y push de las imágenes correspondientes (ver sección IMÁGENES)
git add images/cards/
git commit -m "content: add images for [nombres]"
git push origin main

# NO se sube build. Los usuarios en 1.0.5+ lo ven la próxima vez
# que abran la app con internet.
```

---

## 🔔 PUSH NOTIFICATIONS — Estado actual y plan

**Estado:** No implementado. Solo existen notificaciones locales diarias (recordatorio a las 9am).

### Lo que hay implementado
- `flutter_local_notifications` ✅
- Notificación local diaria a las 9am (opt-in en Settings → Notificaciones)
- Badge en ícono de Configuración cuando hay novedades

### Para implementar push notifications en el futuro
Requiere Firebase Cloud Messaging (FCM). Pasos cuando se decida implementar:

1. Activar FCM en Firebase Console
2. Agregar `firebase_messaging: ^15.0.0` a pubspec.yaml
3. Configurar APNs key en Firebase (requiere archivo .p8 de Apple Developer)
4. Registrar token FCM por usuario al iniciar la app
5. Para enviar a todos los usuarios: usar Firebase Console → Cloud Messaging → Nueva campaña
6. Para segmentar: guardar tokens en Firestore

**Nota:** Para notificar actualizaciones a usuarios existentes, actualmente se usa el `UpdateService` que muestra un dialog in-app al abrir la app.

---

## 📦 BUILD — Subir nuevo build a App Store

⚠️ Esta sección aplica **solo cuando hay cambios de código** (Dart, UI, lógica, dependencias). Cambios de contenido (JSON, imágenes) van por la sección CARDS/IMÁGENES de arriba, sin build.

```bash
# 1. Editar pubspec.yaml — incrementar AMBOS números
# version: 1.0.4+19 → 1.0.5+20

# 2. Verificar que quedó bien editado (evita el error de sesión 2026-08-17:
#    subir el build number sin subir la versión marketing)
grep "^version:" pubspec.yaml

# 3. Limpiar y compilar
cd ~/herechoes
flutter clean
flutter pub get
flutter build ipa

# 4. Subir con Transporter
# Abrir Transporter → arrastrar build/ios/ipa/*.ipa → Deliver

# 5. App Store Connect
# appstoreconnect.apple.com → Her Echoes → Distribution
# Seleccionar nuevo build → completar "Novedades" → Enviar a revisión
```

### Texto de novedades (template)
```
Correcciones de errores y mejoras de rendimiento.

Bug fixes and performance improvements.
```

### Si aparece modal de encriptación
Seleccionar: **"Ninguno de los algoritmos mencionados anteriormente"** → Guardar

---

## 🔍 DIAGNÓSTICO — Card con imagen rota

```bash
# 1. Buscar el image_card_ID de la mujer en el JSON
grep -A 3 -i "nombre_mujer" ~/herechoes/assets/data/her_echoes.json | grep image_card_ID

# 2. Verificar que el archivo existe en el repo
ls ~/herechoes/images/cards/ | grep apellido

# 3. Si el archivo existe pero la imagen no carga:
# → El image_card_ID en el JSON NO coincide con el nombre del archivo
# → Corregir el JSON, validar con json.tool, y hacer commit
```

---

## 🔍 DIAGNÓSTICO — JSON roto / app sin cargar contenido

Como el JSON se lee en vivo desde GitHub, un archivo mal formado se refleja de inmediato en la app de todos los usuarios (cae al asset local de emergencia o queda vacío según el caso).

```bash
cd ~/herechoes
python3 -m json.tool assets/data/her_echoes.json > /dev/null && echo "JSON OK" || echo "JSON INVÁLIDO"
```

Si dice INVÁLIDO, el mensaje indica línea y columna del problema:

```
Expecting ',' delimiter: line XXXXX column YY (char ZZZZZZZ)
```

```bash
# Ver contexto alrededor de esa línea
sed -n 'XXXXX-10,XXXXX+10p' assets/data/her_echoes.json
```

Causas más comunes:
- Comilla recta `"` sin escapar dentro de un campo de texto (ver regla en sección CARDS)
- Coma faltante o coma de más entre objetos
- Llave `{`/`}` sin cerrar

**Nunca hacer push de un JSON que no pase la validación.**

---

## 🔀 GIT — Identidad antes de cada sesión

```bash
# Verificar
git config --global user.name   # debe ser: 01010app
git config --global user.email  # debe ser: 01010dev.app@gmail.com

# Si está mal (apunta a ValarDisghulis):
git config --global user.name "01010app"
git config --global user.email "01010dev.app@gmail.com"
```

---

## 📱 ANDROID — Conectar dispositivo por WiFi

```bash
~/Library/Android/sdk/platform-tools/adb pair IP:PUERTO CODIGO
~/Library/Android/sdk/platform-tools/adb connect IP:PUERTO
flutter run --device-id IP:PUERTO
```

---

## ✅ CHECKLIST — Antes de subir contenido (JSON/imágenes, sin build)

- [ ] git config apunta a 01010app
- [ ] JSON con fechas en formato **MM/DD**
- [ ] JSON validado con `python3 -m json.tool` → dice "JSON OK"
- [ ] Comillas internas en textos escapadas (`\"`)
- [ ] Cada día con mínimo 3 entradas y al menos 1 FREE
- [ ] `image_card_ID` coincide exactamente con el nombre del archivo
- [ ] Imágenes nuevas pusheadas a GitHub (`git status` revisado, sin backlog acumulado)

---

## ✅ CHECKLIST — Antes de cada build (solo cambios de código)

- [ ] pubspec.yaml: versión marketing Y build number incrementados (`grep "^version:" pubspec.yaml`)
- [ ] git config apunta a 01010app
- [ ] `flutter clean && flutter pub get` ejecutado
- [ ] Probado en dispositivo físico antes de subir
- [ ] Confirmar en el log de "App Settings Validation" que Version/Build Number coinciden con pubspec.yaml