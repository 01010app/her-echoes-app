# HerEchoes — OPERATIONS.md
> Referencia rápida de operaciones frecuentes
> Última actualización: 2026-05-19

---

## 🔢 REGLA #1 — Siempre incrementar pubspec antes de subir build

```yaml
# pubspec.yaml
version: 1.0.2+16   ← versión_marketing+build_number
```

**Ambos números siempre suben juntos.**
Si la versión marketing no cambia, Apple rechaza con "train version is closed".

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
    "event_date": "DD/MM",
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

---

## 📋 CARDS — Agregar nuevas mujeres al JSON

El JSON **sí requiere nuevo build** para que los usuarios lo vean actualizado.

```bash
# Editar el JSON
code ~/herechoes/assets/data/her_echoes.json
```

### Estructura de cada entrada
```json
{
  "woman_id": "nombre_apellido",
  "full_name": "Nombre Completo",
  "event_date": "DD/MM",
  "is_free": "VERDADERO",
  "image_card_ID": "apellido_01",
  "pro-tag01_en": "Profession",
  "pro-tag02_en": "Century",
  "pro-tag01_es": "Profesión",
  "pro-tag02_es": "Siglo",
  "quote_text_en": "Quote in English.",
  "quote_text_es": "Cita en español.",
  "bio_en": "Biography in English.",
  "bio_es": "Biografía en español.",
  "legacy_en": "Legacy in English.",
  "legacy_es": "Legado en español.",
  "source_01": "https://...",
  "source_02": ""
}
```

### ⚠️ Reglas críticas del JSON
- **Formato de fecha:** `DD/MM` — NUNCA `MM/DD`
    - ✅ `"15/05"` para 15 de mayo
    - ❌ `"05/15"` — las cards nunca aparecerán
- **is_free:** `"VERDADERO"` o `"FALSO"` — en español, en mayúsculas
- **image_card_ID:** debe coincidir EXACTAMENTE con el nombre del archivo sin extensión
    - Si archivo es `noether_01.webp` → `"image_card_ID": "noether_01"`
    - ❌ NO usar nombre completo: `"emmy_noether_01"` si el archivo es `noether_01.webp`

### Después de editar el JSON
```bash
cd ~/herechoes
git add assets/data/her_echoes.json
git commit -m "content: add cards for [fechas/nombres]"
git push origin main
# Luego subir nuevo build (ver sección BUILD)
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

```bash
# 1. Editar pubspec.yaml — incrementar AMBOS números
# version: 1.0.1+15 → 1.0.2+16

# 2. Limpiar y compilar
cd ~/herechoes
flutter clean
flutter pub get
flutter build ipa

# 3. Subir con Transporter
# Abrir Transporter → arrastrar build/ios/ipa/*.ipa → Deliver

# 4. App Store Connect
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
# → Corregir el JSON y hacer commit
```

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

## ✅ CHECKLIST — Antes de cada build

- [ ] pubspec.yaml: versión marketing Y build number incrementados
- [ ] git config apunta a 01010app
- [ ] JSON con fechas en formato DD/MM
- [ ] Imágenes nuevas pusheadas a GitHub
- [ ] `flutter clean && flutter pub get` ejecutado
- [ ] Probado en dispositivo físico antes de subir