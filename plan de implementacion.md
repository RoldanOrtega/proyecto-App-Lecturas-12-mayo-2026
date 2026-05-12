# 📖 Plan de Implementación: Aplicación "Lecturas"

> ⚠️ **Nota sobre IDEs:** `Antigravity` no es un entorno de desarrollo reconocido para Flutter. Se recomienda **VS Code** con las extensiones oficiales. El plan está optimizado para este ecosistema.

---

## 🛠️ 1. Herramientas y Entorno de Desarrollo
| Categoría | Herramienta | Propósito |
|-----------|-------------|-----------|
| **SDK/Lenguaje** | Flutter 3.x + Dart 3.x | Framework multiplataforma y lenguaje principal |
| **IDE** | VS Code | Edición, depuración y terminal integrada |
| **Extensiones VS Code** | Flutter, Dart, Firebase, Error Lens, Pubspec Assist, Todo Tree | Autocompletado, análisis de errores, gestión de dependencias |
| **Backend/Cloud** | Firebase Console + Firebase CLI | Auth, Firestore, Storage, Cloud Messaging, Crashlytics |
| **Diseño UI/UX** | Figma / Penpot | Wireframes, prototipos interactivos, guía de estilos |
| **Control de Versiones** | Git + GitHub/GitLab | Seguimiento de cambios, ramas, CI/CD futuro |
| **Emuladores/Dispositivos** | Android Studio (SDK Manager), Xcode (iOS), Firebase Emulator Suite | Pruebas locales, simulación de backend sin costos |

---

## 🎨 2. Principios UI/UX
1. **Enfoque en lectura:** Tipografía serif/sans-serif escalable, interlineado generoso, márgenes amplios, soporte nativo de modo claro/oscuro.
2. **Navegación intuitiva:** Barra inferior con 4 pestañas: `Inicio`, `Explorar/Buscar`, `Escribir`, `Mi Biblioteca`. Drawer o perfil lateral para `Configuración` y `Notificaciones`.
3. **Jerarquía visual:** Portadas destacadas, tarjetas con metadatos (autor, género, progreso), indicadores de lectura (porcentaje, último capítulo).
4. **Feedback inmediato:** Toasts/snackbars para acciones (guardar, comentar, publicar), animaciones suaves en transiciones, estados de carga skeleton.
5. **Accesibilidad:** Soporte para texto dinámico, contraste WCAG AA, navegación por teclado/lector de pantalla.

---

## 📦 3. Dependencias Requeridas (Referencia conceptual)
> 📝 *Se listan por categoría. No se incluye sintaxis YAML para cumplir con "sin código".*

| Categoría | Paquetes Clave | Función |
|-----------|----------------|---------|
| **Core Firebase** | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging` | Autenticación, base de datos, archivos, notificaciones push |
| **Estado** | `provider` | Gestión reactiva de estado global y local |
| **UI/UX** | `flutter_svg`, `cached_network_image`, `flutter_markdown`, `google_fonts`, `intl` | Imágenes optimizadas, renderizado de texto enriquecido, localización de fechas |
| **Utilidades** | `uuid`, `shared_preferences`, `flutter_localizations`, `image_picker` | IDs únicos, configuración local, selección de imágenes para perfiles/portadas |
| **Navegación** | `go_router` o `auto_route` (opcional) | Enrutamiento declarativo, parámetros, guardias de autenticación |
| **Testing** | `mocktail`, `firebase_auth_mocks`, `cloud_firestore_mocks` | Pruebas unitarias y de widget sin conectar a Firebase real |

---

## 🏗️ 4. Arquitectura y Gestión de Estado (Provider)
- **Patrón:** MVVM ligero (Model-View-ViewModel) adaptado a Flutter.
- **Capas:**
  - `presentation/`: Pantallas, widgets, temas.
  - `application/`: Servicios, controladores de estado (Provider), validaciones.
  - `domain/`: Entidades puras (User, Work, Chapter, Comment, List, Notification).
  - `infrastructure/`: Repositorios, mapeo Firestore ↔ Entidades, clientes Firebase.
- **Providers principales:**
  - `AuthProvider`: Estado de sesión, perfil, validación de permisos.
  - `LibraryProvider`: Lecturas guardadas, progreso, listas personalizadas.
  - `InteractionProvider`: Comentarios, corazones, actividad reciente.
  - `NotificationProvider`: Bandeja de entrada, preferencias de alerta.
- **Estrategia de actualización:** `ChangeNotifierProvider` para cambios globales, `ProxyProvider` para datos dependientes, `FutureProvider`/`StreamProvider` para datos asíncronos de Firestore.

---

## 🔐 5. Configuración de Firebase (Previa al desarrollo)
1. Crear proyecto en Firebase Console.
2. Registrar aplicaciones: Android, iOS, Web (y macOS/Windows si aplica).
3. Descargar archivos de configuración (`google-services.json`, `GoogleService-Info.plist`) y colocarlos en rutas correctas.
4. Habilitar **Authentication** → Método `Email/Password`. Configurar recuperación de contraseña.
5. Habilitar **Firestore Database** → Iniciar en `modo prueba` (luego endurecer reglas).
6. Habilitar **Storage** → Para portadas, imágenes de perfil, borradores.
7. Habilitar **Cloud Messaging** → Para notificaciones push de actualizaciones.
8. Instalar Firebase CLI y ejecutar `firebase login` + `firebase init` (solo si se usa Emulator Suite o Hosting).

---

## 📊 6. Modelo de Datos (Firestore) - Estructura Lógica
| Colección | Documentos Clave | Campos Representativos | Relaciones |
|-----------|------------------|------------------------|------------|
| `users` | `{uid}` | `email`, `displayName`, `avatarUrl`, `createdAt`, `preferences` | Padre de `user_library`, `user_lists` |
| `works` | `{workId}` | `title`, `authorId`, `genre`, `status`, `coverUrl`, `createdAt`, `updatedAt` | Relación 1:N con `chapters` |
| `chapters` | `{chapterId}` (subcolección de `works`) | `title`, `content`, `order`, `publishedAt` | Relación con `comments`, `likes` |
| `comments` | `{commentId}` | `userId`, `workId`, `chapterId`, `text`, `createdAt`, `updatedAt` | Query por obra/capítulo |
| `likes` | `{likeId}` | `userId`, `workId`, `chapterId`, `createdAt` | Única por usuario+capítulo (composite key) |
| `user_library` | `{entryId}` | `userId`, `workId`, `lastChapterRead`, `progress`, `addedAt` | Guardados y progreso |
| `user_lists` | `{listId}` | `userId`, `name`, `visibility`, `workIds[]`, `createdAt` | Listas personalizadas |
| `notifications` | `{notifId}` | `userId`, `type`, `sourceWorkId`, `message`, `isRead`, `createdAt` | Bandeja de actualizaciones |

> 🔒 **Reglas de seguridad (planificación):** Lectura pública para obras publicadas, escritura solo para autores autenticados, modificación de likes/comentarios solo por creador, notificaciones solo visibles por destinatario.

---

## 📅 7. Hoja de Ruta Paso a Paso (Procedimiento)

### ✅ Fase 1: Configuración y Estructura Base
1. Inicializar proyecto Flutter con `flutter create`.
2. Organizar carpetas según arquitectura definida (`presentation/`, `application/`, `domain/`, `infrastructure/`, `core/`).
3. Configurar tema global (tipografía, colores, modo oscuro/claro, bordes, sombras).
4. Integrar extensiones de VS Code y verificar linting/formateo (`dart format`, `flutter analyze`).

### ✅ Fase 2: Navegación y UI Esquelética
1. Implementar estructura de navegación principal (BottomNavigationBar, rutas protegidas).
2. Crear pantallas vacías con estados placeholder: Inicio, Explorar, Escribir, Biblioteca, Perfil, Notificaciones.
3. Diseñar componentes reutilizables: `WorkCard`, `ChapterTile`, `ActionButton`, `SkeletonLoader`, `EmptyState`.

### ✅ Fase 3: Autenticación y Gestión de Sesión
1. Conectar Firebase Auth (Email/Password).
2. Crear flujos: Registro, Inicio de sesión, Recuperación de contraseña, Cierre de sesión.
3. Implementar `AuthProvider` con Provider. Guardar estado de autenticación en memoria y validar al iniciar.
4. Proteger rutas que requieran sesión. Redirigir a login si no hay token válido.

### ✅ Fase 4: Integración Firestore y Modelos de Datos
1. Definir entidades Dart puras (`User`, `Work`, `Chapter`, etc.) con `json_serializable` o constructores manuales.
2. Crear repositorios abstractos y sus implementaciones con Firestore (`WorkRepository`, `AuthRepository`, etc.).
3. Implementar mapeo de documentos ↔ entidades. Manejar errores y estados de carga.
4. Probar con Firebase Emulator Suite antes de usar producción.

### ✅ Fase 5: Lectura y Publicación de Obras
1. **Lectura:** Implementar visor de capítulos con scroll optimizado, guardado de progreso, soporte markdown básico.
2. **Escritura:** Crear editor con guardado automático en borradores (Firestore o local), validación de campos, publicación controlada (cambio de estado `draft` → `published`).
3. **Listado:** Paginación/limitación en Firestore (`startAfterDocument`), ordenamiento por fecha/popularidad.

### ✅ Fase 6: Interacción Social (Comentarios y Corazones)
1. Implementar sección de comentarios por capítulo: crear, listar, limitar caracteres, moderación básica.
2. Sistema de likes: toggle en UI, transacción en Firestore para evitar conteos duplicados, indicador visual persistente.
3. Actualizar UI en tiempo real con `StreamProvider` para comentarios/likes.

### ✅ Fase 7: Guardar y Listas Personalizadas
1. **Biblioteca:** Botón "Guardar en lecturas" → añadir a `user_library`. Actualizar progreso al leer.
2. **Listas:** CRUD de listas (`user_lists`). Añadir/eliminar obras. Visualización en grid/lista. Drag & drop opcional para reordenar.
3. Sincronización offline básica (configurar Firestore persistence).

### ✅ Fase 8: Sistema de Notificaciones
1. Configurar `firebase_messaging`. Solicitar permisos, obtener token, registrar en Firestore bajo el perfil de usuario.
2. Crear triggers (Cloud Functions o lógica cliente) que generen documentos en `notifications` cuando:
   - Autor publica nuevo capítulo.
   - Alguien comenta en obra guardada.
   - Obra guardada se actualiza.
3. Implementar pantalla de notificaciones: marcar como leído, limpiar, enlaces profundos (deep links) a la obra/capítulo correspondiente.

### ✅ Fase 9: Pulido, Optimización y Pruebas
1. **Rendimiento:** Optimizar imágenes (`cached_network_image`), evitar rebuilds innecesarios (`Consumer` selectivos), usar `const` en widgets estáticos.
2. **UX:** Transiciones suaves, estados de error amigables, reintentos automáticos, manejo de desconexión.
3. **Pruebas:** Unit tests para repositorios y providers, widget tests para flujos críticos, integración con Emulator Suite.
4. **Accesibilidad y Localización:** Verificar contraste, soporte de texto dinámico, cadenas de texto centralizadas.

### ✅ Fase 10: Despliegue y Mantenimiento
1. Configurar `firebase_crashlytics` y `firebase_analytics`.
2. Generar builds: `flutter build apk/appbundle` (Android), `flutter build ios` (iOS), `flutter build web` (opcional).
3. Subir a tiendas o distribución interna (TestFlight, Play Console Internal Testing).
4. Establecer pipeline de releases: versionado semántico, changelog, rollback plan.
5. Monitoreo post-lanzamiento: métricas de retención, errores, rendimiento de queries Firestore.

---

## 🧭 Recomendaciones Finales de Planificación
- **Prioriza el MVP:** Auth + Lectura básica + Guardar + Comentarios. El resto se itera.
- **Seguridad primero:** Define reglas de Firestore antes de exponer endpoints. Nunca confíes en validación solo del cliente.
- **Gestión de estado:** No sobrecargues Provider. Divide por dominio y usa `MultiProvider` en `main.dart`.
- **Datos offline:** Firestore tiene caché nativo. Configúralo según necesidad de sincronización.
- **Documentación interna:** Mantén un `ARCHITECTURE.md` y `DECISIONS.md` en el repositorio para rastrear por qué se eligieron ciertas soluciones.

Cuando tengas este plan aprobado y estructurado en tu repositorio, podemos proceder a la **Fase 1** con la estructura de carpetas, configuración inicial y esqueleto de navegación. ¿Deseas que profundicemos en algún apartado específico antes de comenzar?
