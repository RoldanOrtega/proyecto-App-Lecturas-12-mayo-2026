# 📖 Plan de Implementación Maestro: Lecturas App (Markdown)

**Versión:** 2.0 (Expandida, Completa y Ejecutable + Código Esencial)  
**Arquitectura:** MVVM + Provider (Feature-First)  
**Estética:** Neon Night (Fondo Negro / Rosa Fuerte / Rosa Claro)  
**Plataformas:** Android, iOS, Web (Progresiva)  
**Backend:** Firebase (Auth, Firestore, Storage, Cloud Messaging, Crashlytics)  

---

## 📊 1. Modelo de Datos Lógico (Fuente de Verdad)

> 📌 *Nota técnica: Aunque Firestore es NoSQL, esta estructura relacional sirve como mapa lógico exacto para definir documentos, subcolecciones y arrays de referencia en la base de datos.*

### 👤 USUARIO
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `nombre` | VARCHAR(100) | ● | Nombre visible del usuario |
| `IDX email` | VARCHAR(255) | ● | Correo único para autenticación |
| `password_hash` | VARCHAR(255) | ● | Hash bcrypt de la contraseña |
| `avatar_url` | TEXT | ○ | URL imagen de perfil |
| `bio` | TEXT | ○ | Descripción del perfil |
| `rol` | ENUM | ● | `lector` · `autor` · `admin` |
| `activo` | BOOLEAN | ● | Cuenta habilitada (default true) |
| `fecha_registro` | TIMESTAMP | ● | Fecha y hora de creación |
| `ultimo_acceso` | TIMESTAMP | ○ | Última sesión iniciada |

### 📚 OBRA
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK autor_id` | UUID | ● | Referencia a USUARIO |
| `titulo` | VARCHAR(200) | ● | Título de la obra |
| `sinopsis` | TEXT | ○ | Descripción / resumen |
| `portada_url` | TEXT | ○ | URL imagen de portada |
| `tipo` | ENUM | ● | `novela` · `cuento` · `poema` · `ensayo` |
| `estado` | ENUM | ● | `borrador` · `en_progreso` · `completa` · `pausada` |
| `es_original` | BOOLEAN | ● | Obra original o derivada/fanfic |
| `idioma` | VARCHAR(10) | ● | Código ISO (`es`, `en`, `fr`…) |
| `visitas` | INTEGER | ● | Contador acumulado de lecturas (default 0) |
| `publicado_en` | TIMESTAMP | ○ | Fecha de primera publicación |
| `actualizado_en` | TIMESTAMP | ● | Última modificación |

### 📖 CAPITULO
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK obra_id` | UUID | ● | Referencia a OBRA |
| `numero` | INTEGER | ● | Posición en la obra (1, 2, 3…) |
| `titulo` | VARCHAR(200) | ○ | Título del capítulo |
| `contenido` | TEXT | ● | Cuerpo del capítulo (markdown/html) |
| `palabras` | INTEGER | ● | Conteo de palabras (calculado) |
| `publicado` | BOOLEAN | ● | Visible para lectores (default false) |
| `creado_en` | TIMESTAMP | ● | Fecha de creación |
| `publicado_en` | TIMESTAMP | ○ | Fecha en que se hizo público |

### 🏷️ GENERO
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `nombre` | VARCHAR(80) | ● | Nombre del género (Romance, Suspenso…) |
| `descripcion` | TEXT | ○ | Descripción breve del género |
| `icono_url` | TEXT | ○ | Ícono o imagen representativa |

### 🔗 OBRA_GENERO
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK FK obra_id` | UUID | ● | Referencia a OBRA |
| `PK FK genero_id` | UUID | ● | Referencia a GENERO |

### 🏷️ ETIQUETA
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `nombre` | VARCHAR(60) | ● | Texto del tag (ej. magia-suave) |

### 🔗 OBRA_ETIQUETA
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK FK obra_id` | UUID | ● | Referencia a OBRA |
| `PK FK etiqueta_id` | UUID | ● | Referencia a ETIQUETA |

### 📖 BIBLIOTECA
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK usuario_id` | UUID | ● | Referencia a USUARIO |
| `FK obra_id` | UUID | ● | Referencia a OBRA |
| `estado` | ENUM | ● | `quiero_leer` · `leyendo` · `completada` · `abandonada` |
| `agregado_en` | TIMESTAMP | ● | Fecha en que se añadió a la biblioteca |

### 📍 PROGRESO_LECTURA
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK usuario_id` | UUID | ● | Referencia a USUARIO |
| `FK obra_id` | UUID | ● | Referencia a OBRA |
| `FK capitulo_id` | UUID | ● | Último capítulo leído |
| `posicion` | INTEGER | ● | Posición de scroll dentro del capítulo (px) |
| `porcentaje` | DECIMAL(5,2) | ● | % leído de la obra completa |
| `actualizado_en` | TIMESTAMP | ● | Última actualización del progreso |

### ⭐ RESENA
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK usuario_id` | UUID | ● | Referencia a USUARIO |
| `FK obra_id` | UUID | ● | Referencia a OBRA |
| `puntuacion` | INTEGER | ● | Calificación del 1 al 5 |
| `comentario` | TEXT | ○ | Texto de la reseña |
| `creado_en` | TIMESTAMP | ● | Fecha de publicación |
| `editado_en` | TIMESTAMP | ○ | Última edición |

### 💬 COMENTARIO
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK usuario_id` | UUID | ● | Referencia a USUARIO |
| `FK capitulo_id` | UUID | ● | Referencia a CAPITULO |
| `FK parent_id` | UUID | ○ | Referencia a COMENTARIO (respuesta) |
| `contenido` | TEXT | ● | Texto del comentario |
| `eliminado` | BOOLEAN | ● | Soft delete (default false) |
| `creado_en` | TIMESTAMP | ● | Fecha de publicación |

### ❤️ LIKE_OBRA
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK FK usuario_id` | UUID | ● | Referencia a USUARIO |
| `PK FK obra_id` | UUID | ● | Referencia a OBRA |
| `creado_en` | TIMESTAMP | ● | Momento en que se dio el like |

### ❤️ LIKE_COMENTARIO
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK FK usuario_id` | UUID | ● | Referencia a USUARIO |
| `PK FK comentario_id` | UUID | ● | Referencia a COMENTARIO |
| `creado_en` | TIMESTAMP | ● | Momento en que se dio el like |

### 🔄 SEGUIMIENTO
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK FK seguidor_id` | UUID | ● | Usuario que sigue (ref. USUARIO) |
| `PK FK seguido_id` | UUID | ● | Usuario seguido (ref. USUARIO) |
| `creado_en` | TIMESTAMP | ● | Fecha en que se inició el seguimiento |

### 🔔 NOTIFICACION
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK usuario_id` | UUID | ● | Destinatario (ref. USUARIO) |
| `tipo` | ENUM | ● | `nuevo_cap` · `nuevo_seguidor` · `comentario` · `like` |
| `datos` | JSONB | ○ | Payload variable según el tipo |
| `leida` | BOOLEAN | ● | Estado de lectura (default false) |
| `creado_en` | TIMESTAMP | ● | Fecha de generación |

### 📥 SUSCRIPCION
| Atributo | Tipo | Req. | Descripción |
|----------|------|------|-------------|
| `PK id` | UUID | ● | Identificador único |
| `FK usuario_id` | UUID | ● | Referencia a USUARIO |
| `FK obra_id` | UUID | ● | Referencia a OBRA |
| `creado_en` | TIMESTAMP | ● | Fecha de suscripción |

---

## 📁 2. Estructura Completa de `lib/` (Sin Abreviaturas)

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_routes.dart
│   │   └── firebase_cols.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── date_helpers.dart
│   └── router/
│       └── app_router.dart
├── domain/
│   ├── entities/
│   │   ├── usuario.dart
│   │   ├── obra.dart
│   │   ├── capitulo.dart
│   │   ├── genero.dart
│   │   ├── etiqueta.dart
│   │   ├── biblioteca_item.dart
│   │   ├── progreso_lectura.dart
│   │   ├── resena.dart
│   │   ├── comentario.dart
│   │   ├── like.dart
│   │   ├── seguimiento.dart
│   │   ├── notificacion.dart
│   │   └── suscripcion.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── obra_repository.dart
│       ├── capitulo_repository.dart
│       ├── biblioteca_repository.dart
│       ├── interaccion_repository.dart
│       ├── notificacion_repository.dart
│       └── seguimiento_repository.dart
├── infrastructure/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   ├── firestore_datasource.dart
│   │   └── storage_remote_datasource.dart
│   ├── models/
│   │   ├── usuario_model.dart
│   │   ├── obra_model.dart
│   │   ├── capitulo_model.dart
│   │   ├── genero_model.dart
│   │   ├── etiqueta_model.dart
│   │   ├── biblioteca_item_model.dart
│   │   ├── progreso_lectura_model.dart
│   │   ├── resena_model.dart
│   │   ├── comentario_model.dart
│   │   ├── like_model.dart
│   │   ├── notificacion_model.dart
│   │   └── suscripcion_model.dart
│   └── repositories_impl/
│       ├── auth_repository_impl.dart
│       ├── obra_repository_impl.dart
│       ├── capitulo_repository_impl.dart
│       ├── biblioteca_repository_impl.dart
│       ├── interaccion_repository_impl.dart
│       ├── notificacion_repository_impl.dart
│       └── seguimiento_repository_impl.dart
├── application/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── story_provider.dart
│   │   ├── library_provider.dart
│   │   ├── writer_provider.dart
│   │   ├── interaction_provider.dart
│   │   └── notification_provider.dart
│   ├── validators/
│   │   └── form_validators.dart
│   └── usecases/
│       ├── get_user_profile_usecase.dart
│       ├── create_story_usecase.dart
│       └── update_reading_progress_usecase.dart
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   └── widgets/
│   │   │       ├── auth_form_field.dart
│   │   │       └── neon_auth_button.dart
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── home_shell_screen.dart
│   │   │   │   ├── feed_screen.dart
│   │   │   │   └── explore_screen.dart
│   │   │   └── widgets/
│   │   │       ├── story_card.dart
│   │   │       ├── genre_filter_chip.dart
│   │   │       └── skeleton_feed_loader.dart
│   ├── reader/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── story_detail_screen.dart
│   │   │   │   ├── chapter_list_screen.dart
│   │   │   │   └── reader_screen.dart
│   │   │   └── widgets/
│   │   │       ├── chapter_tile.dart
│   │   │       ├── reader_toolbar.dart
│   │   │       └── comment_thread_widget.dart
│   ├── writer/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── writer_dashboard_screen.dart
│   │   │   │   ├── create_story_screen.dart
│   │   │   │   ├── edit_story_screen.dart
│   │   │   │   ├── chapter_editor_screen.dart
│   │   │   │   └── cover_upload_screen.dart
│   │   │   └── widgets/
│   │   │       ├── chapter_manager_list.dart
│   │   │       └── markdown_preview_widget.dart
│   └── library/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── library_screen.dart
│       │   │   ├── my_lists_screen.dart
│       │   │   ├── notifications_screen.dart
│       │   │   └── profile_screen.dart
│       │   └── widgets/
│       │       ├── library_status_chip.dart
│       │       ├── list_manager_card.dart
│       │       └── notification_item_tile.dart
└── shared/
    ├── widgets/
    │   ├── pink_button.dart
    │   ├── neon_loader.dart
    │   ├── empty_state_widget.dart
    │   ├── custom_text_field.dart
    │   └── error_snackbar.dart
    └── helpers/
        ├── network_helper.dart
        └── firebase_helper.dart
```

---

## 🔧 3. Herramientas y Entorno de Desarrollo
| Categoría | Herramienta / Configuración | Propósito Detallado |
|-----------|-----------------------------|---------------------|
| **SDK/Lenguaje** | Flutter 3.x + Dart 3.x | Compilación nativa, null-safety, patrones modernos |
| **IDE Principal** | VS Code | Entorno ligero, terminal integrada, debugging visual |
| **Extensiones VS Code** | Flutter, Dart, Firebase, Error Lens, Pubspec Assist, GitLens, Better Comments, Todo Tree | Linting en tiempo real, resolución de errores, gestión de dependencias, trazabilidad de cambios |
| **CLI & Herramientas** | Flutter CLI, Firebase CLI, Dart DevTools | Creación de proyecto, despliegue, inspección de memoria/rendimiento, emulación local |
| **Diseño UI/UX** | Figma + Plugin Auto Layout + Design Tokens | Prototipos interactivos, exportación de assets, guía de estilos sincronizada |
| **Control de Versiones** | Git + GitHub/GitLab + Conventional Commits | Ramas protegidas, PR reviews, historial semántico |
| **Emulación Local** | Firebase Emulator Suite + Android/iOS Simuladores | Desarrollo sin consumo de cuota, pruebas de reglas de seguridad offline |
| **Gestión de Tareas** | GitHub Projects / Jira / Linear | Sprints, backlog, seguimiento de bugs, hitos de entrega |

---

## 🎨 4. Principios UI/UX & Tema "Neon Night"
1. **Paleta Base:** Negro puro (`#000000`) como lienzo, Rosa Neón (`#FF1493`) para acentos primarios, Rosa Pastel (`#FFB6C1`) para superficies secundarias, Blanco Nieve (`#FFFFFF`) para texto de lectura.
2. **Tipografía:** Serif elegante para cuerpo de lectura (legibilidad prolongada), Sans-Serif geométrica para UI/navegación. Escalas tipográficas definidas por ratio `1.25` para mantener jerarquía clara.
3. **Efectos Neón:** Uso de sombras difuminadas (`BoxShadow` con opacidad baja y desenfoque alto), bordes luminosos en estados `hover`/`focus`, transiciones de opacidad para feedback táctil.
4. **Modo de Lectura:** Márgenes laterales adaptativos, interlineado `1.6`, alto contraste controlado, soporte para ajuste dinámico de tamaño de fuente sin romper layout.
5. **Accesibilidad:** Cumplimiento WCAG AA, etiquetas semánticas, navegación por teclado/gestos, soporte para TalkBack/VoiceOver, indicadores visuales + auditivos para acciones críticas.
6. **Navegación:** `BottomNavigationBar` con 4 pestañas (`Cartelera`, `Explorar`, `Escritura`, `Biblioteca`). Rutas protegidas por estado de autenticación. Deep links para notificaciones.

---

## 🏗️ 5. Arquitectura y Gestión de Estado (Provider)
- **Patrón:** MVVM ligero (Model-View-ViewModel) adaptado a Flutter + Feature-First.
- **Capas:**
  - `presentation/`: Pantallas, widgets visuales, animaciones, temas.
  - `application/`: ViewModels/Providers, validaciones, formateo, orquestación.
  - `domain/`: Entidades puras, interfaces de repositorio, casos de uso.
  - `infrastructure/`: Implementaciones de repositorios, mapeo Firestore, clientes Firebase.
- **Providers principales:**
  - `AuthProvider`: Estado de sesión, perfil cacheado, validación de permisos.
  - `StoryProvider`: Lista obras, detalles, capítulos, carga progresiva.
  - `LibraryProvider`: Progreso de lectura, obras guardadas, listas personalizadas.
  - `InteractionProvider`: Comentarios, likes, actividad reciente, reseñas.
  - `NotificationProvider`: Bandeja de entrada, marca como leído, preferencias de alerta.
- **Estrategia de actualización:** `ChangeNotifierProvider` para cambios globales, `ProxyProvider` para datos dependientes, `StreamProvider` para tiempo real, `FutureProvider` para carga inicial. Uso de `Consumer` selectivo para evitar rebuilds innecesarios.

---

## 🗄️ 6. Backend Firestore & Seguridad (Adaptación Lógica)
### 6.1. Mapeo Firestore del Modelo
- **Colecciones Raíz:** `usuarios`, `obras`, `generos`, `etiquetas`, `notificaciones`, `seguimientos`.
- **Subcolecciones:** `capitulos` (dentro de `obras`), `comentarios` (dentro de `capitulos`), `biblioteca`, `progreso`, `suscripciones` (dentro de `usuarios`).
- **Relaciones M:N:** `obra_generos` y `obra_etiquetas` se implementan como arrays de IDs dentro del documento `obras` para optimizar lecturas. Las tablas cruzadas se mantienen como referencia lógica para queries complejas.
- **Contadores Agregados:** Campos como `visitas`, `likesCount`, `commentsCount` se actualizan mediante transacciones o Cloud Functions para evitar lecturas costosas.

### 6.2. Reglas de Seguridad (Conceptual)
- **Lectura:** `obras` y `capitulos` públicos si `estado == 'completa' || estado == 'en_progreso'`. Datos personales solo visibles por `request.auth.uid`.
- **Escritura:** Solo creador puede modificar su obra/capítulo. `likes` y `comentarios` requieren autenticación, limitación de longitud, bloqueo de edición tras X minutos.
- **Validación:** Tipos estrictos, `exists()` para referencias cruzadas, `request.time` para fechas, `size` para arrays, prevención de inyección y spam.
- **Moderación:** Reportes de usuario marcados como `reporte_pendiente`, revisión administrativa, auto-baneo por spam detectado.

---

## 📅 7. Hoja de Ruta Paso a Paso (Procedimiento)

### ✅ Fase 1: Configuración Inicial y Validación de Entorno
1. Instalar Flutter SDK, verificar con `flutter doctor`.
2. Configurar VS Code con extensiones, activar formateo automático, linting estricto.
3. Crear repositorio Git, configurar `.gitignore` oficial, rama `main` protegida.
4. Ejecutar `flutter create`, eliminar código boilerplate, validar compilación en emuladores.
5. Configurar Firebase Console, descargar archivos de configuración, inicializar `firebase_core`.

### ✅ Fase 2: Tema Global y Componentes Base
1. Definir `ThemeData` con paleta Neon Night, fuentes, sombras, elevaciones.
2. Crear `AppColors`, `AppTypography`, `AppSpacings` como constantes centralizadas.
3. Construir componentes base: `NeonButton`, `StoryCard`, `EmptyState`, `SkeletonLoader`, `CustomTextField`.
4. Probar contraste, escalado de texto, comportamiento en modo oscuro/claro.
5. Validar renderizado en pantallas pequeñas y tablets.

### ✅ Fase 3: Autenticación y Flujo de Sesión
1. Configurar Firebase Auth (Email/Password), habilitar recuperación por correo.
2. Implementar flujos de UI: Login, Registro, Forgot Password, Validación de email.
3. Crear `AuthProvider` con `ChangeNotifier`, escuchar `authStateChanges`.
4. Proteger rutas: middleware de navegación que redirige a login si `user == null`.
5. Guardar preferencias básicas (tema, idioma, sesión persistente) de forma segura.

### ✅ Fase 4: Conexión a Firestore y Modelo de Datos
1. Inicializar `FirebaseFirestore` con configuración de proyecto.
2. Definir entidades Dart puras según el modelo lógico (USUARIO, OBRA, CAPITULO, etc.).
3. Implementar interfaces de repositorio y su capa de infraestructura.
4. Mapear documentos ↔ entidades, manejar `null`, `FormatException`, `FirebaseException`.
5. Configurar Emulator Suite, validar reglas de seguridad antes de producción.

### ✅ Fase 5: Navegación, Feed y Exploración
1. Implementar `BottomNavigationBar` con estados activos/inactivos en rosa neón.
2. Construir `HomeScreen` con paginación infinita (`limit + startAfter`).
3. Añadir filtros por género, estado, orden (reciente/más leídas/más likes).
4. Implementar `StoryDetailScreen`: sinopsis, portada, lista de capítulos, botón "Empezar a leer".
5. Optimizar reconstrucciones: `ListView.builder`, `RepaintBoundary`, `const` en widgets estáticos.

### ✅ Fase 6: Visor de Lectura y Progreso
1. Crear `ReaderScreen` con scroll optimizado, márgenes de lectura, ajuste de fuente.
2. Implementar guardado de progreso: `lastChapter`, `scrollPosition`, porcentaje leído.
3. Sincronizar progreso local y remoto, manejo de desconexión con caché local.
4. Añadir botón de "Corazón" por obra/capítulo, contador visible, estado persistente.
5. Validar rendimiento con listas largas de texto, evitar jank en scroll.

### ✅ Fase 7: Comentarios, Reseñas e Interacción Social
1. Implementar hilo de comentarios por capítulo: crear, listar, responder, editar/borrar.
2. Limitar caracteres, validar contenido vacío o repetitivo, soft delete.
3. Usar `StreamProvider` para actualización en tiempo real.
4. Añadir reseñas por obra (1-5 estrellas + comentario), visible en detalle.
5. Notificar al autor cuando un comentario o reseña menciona su obra.

### ✅ Fase 8: Panel de Escritor y Publicación
1. Crear `WriterDashboard`: lista de obras propias, estado, estadísticas básicas.
2. Implementar `CreateStoryScreen`: título, sinopsis, género, etiquetas, portada, validación.
3. Editor de capítulos: guardado automático local, sincronización diferida, vista previa markdown.
4. Flujo de publicación: cambio de estado `borrador → publicado`, validación de contenido mínimo.
5. Subida de portadas a Storage, compresión, generación de URL pública segura.

### ✅ Fase 9: Biblioteca y Listas Personalizadas
1. Implementar `LibraryScreen`: obras guardadas, progreso, filtro por estado (`quiero_leer`, `leyendo`, etc.).
2. CRUD de listas: crear, renombrar, eliminar, añadir/quitar obras, visibilidad pública/privada.
3. Visualización en grid/lista, ordenamiento personalizado, drag & drop (v2).
4. Sincronización offline: caché local, resolución de conflictos al reconectar.
5. Compartir listas mediante enlaces profundos o códigos compartidos.

### ✅ Fase 10: Sistema de Notificaciones y Seguimiento
1. Configurar `Cloud Messaging`, solicitar permisos, obtener token.
2. Registrar token en perfil de usuario, manejar rotación automática.
3. Disparar notificaciones cuando: nuevo capítulo, nuevo seguidor, comentario, like, reseña.
4. Pantalla de notificaciones: marcar como leído, limpiar, enlaces profundos a obra/capítulo.
5. Preferencias de usuario: activar/desactivar tipos de alerta, modo no molestar.
6. Implementar red de seguimiento: `follow/unfollow`, feed de actividad de autores seguidos.

### ✅ Fase 11: Pruebas, Optimización y Accesibilidad
1. **Unit Tests:** Repositorios, validadores, lógica de negocio, mapeo de datos.
2. **Widget Tests:** Flujos de autenticación, navegación, estados de carga/error, interacción con providers.
3. **Integration Tests:** Emuladores, reglas de seguridad, sincronización offline/online.
4. **Rendimiento:** `flutter devtools`, inspección de memoria, evitar rebuilds innecesarios, optimizar imágenes.
5. **Accesibilidad:** Verificación con screen readers, contraste, navegación por teclado, etiquetas semánticas.

### ✅ Fase 12: Despliegue, Monitoreo y Mantenimiento
1. Configurar `Crashlytics` y `Analytics`, definir eventos clave (`story_opened`, `chapter_read`, `story_published`).
2. Generar builds firmados: Android (`appbundle`), iOS (`ipa`), Web (`flutter build web`).
3. Publicar en tiendas: metadatos, capturas, política de privacidad, cumplimiento de normas.
4. Establecer pipeline CI/CD: ejecución de tests, lint, builds automáticos en PR merge.
5. Monitoreo post-lanzamiento: métricas de retención, tasas de error, rendimiento de queries, plan de rollback.

---

## 🧪 8. Estrategia de Pruebas y Calidad
| Tipo | Alcance | Herramientas | Criterio de Aceptación |
|------|---------|--------------|------------------------|
| **Unit** | Lógica pura, validadores, mapeo, casos de uso | `test`, `mocktail` | Cobertura > 70%, 0 fallos en CI |
| **Widget** | Pantallas, navegación, estados, interacción con Provider | `flutter_test`, `integration_test` | Renderizado correcto, sin jank, accesible |
| **Integration** | Flujos completos, Auth + Firestore + Storage | `firebase_auth_mocks`, `cloud_firestore_mocks`, Emuladores | Sincronización estable, reglas aplicadas |
| **Performance** | Scroll, memoria, inicio en frío, red | `flutter devtools`, `timeline`, `leaks` | FPS > 55, memoria estable, inicio < 2s |
| **Accesibilidad** | Lectura de pantalla, contraste, navegación | `accessibility_scanner`, prueba manual | Cumplimiento WCAG AA, sin barreras |

---

## 🚀 9. Despliegue, CI/CD y Monitoreo
- **Versionado:** Semántico (`MAJOR.MINOR.PATCH`), changelog automatizado, tags en Git.
- **CI/CD Pipeline:** GitHub Actions / Fastlane. Ejecutar `flutter analyze`, `flutter test`, `flutter build` en cada PR.
- **Distribución:** TestFlight (iOS), Play Console Internal Testing (Android), Firebase App Distribution.
- **Monitoreo:** Crashlytics para errores, Analytics para retención y flujos, Performance para trazas de red/UI.
- **Mantenimiento:** Actualización de dependencias trimestral, revisión de reglas de seguridad, backup automatizado de Firestore.

---

## 📊 10. Gestión del Proyecto y Mitigación de Riesgos
| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| **Reglas de Firestore incorrectas** | Alto (fuga de datos) | Pruebas en Emulador, revisión por pares, validación estricta en cliente |
| **Sobrecarga de Provider** | Medio (rebuilds innecesarios) | Dividir por dominio, usar `select`, evitar `notifyListeners()` frecuentes |
| **Offline sync conflicts** | Medio (pérdida de progreso) | Timestamps, resolución por "última escritura válida", caché local |
| **Notificaciones duplicadas** | Bajo (molestia usuario) | Idempotencia en mensajes, validación de `type + sourceId`, cooldown lógico |
| **Rendimiento en listas largas** | Alto (jank, crash) | Paginación estricta, `ListView.builder`, `const`, optimización de imágenes |
| **Revisión de tiendas rechazada** | Medio (retraso lanzamiento) | Cumplir políticas de contenido, política de privacidad clara, metadatos verificados |

---

## 📦 11. Dependencias Estratégicas (Conceptual)
| Categoría | Paquetes Clave | Función en el Proyecto |
|-----------|----------------|------------------------|
| **Firebase Core** | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging` | Autenticación segura, base de datos en tiempo real, almacenamiento de portadas, notificaciones push |
| **Gestión de Estado** | `provider` | Reacción a cambios de UI, distribución de datos, aislamiento de lógica de negocio |
| **UI/UX** | `google_fonts`, `cached_network_image`, `flutter_markdown`, `intl`, `flutter_svg` | Tipografía neon, carga eficiente de imágenes, renderizado de texto enriquecido, localización de fechas, iconos vectoriales |
| **Utilidades** | `uuid`, `shared_preferences`, `image_picker`, `flutter_localizations`, `go_router` | Identificadores únicos, persistencia local, selección de archivos, soporte multilingüe, enrutamiento declarativo |
| **Testing** | `mocktail`, `firebase_auth_mocks`, `cloud_firestore_mocks` | Aislamiento de pruebas, simulación de backend, validación de flujos sin costos |

---

## 📦 12. `pubspec.yaml` Estructura Recomendada (Completa)
```yaml
name: lecturas_app
description: Plataforma multiplataforma para lectura y escritura de historias.
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # FIREBASE
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.0.0
  firebase_crashlytics: ^4.0.0
  firebase_analytics: ^11.0.0

  # STATE MANAGEMENT
  provider: ^6.1.2

  # ROUTING
  go_router: ^14.0.0

  # UI & ASSETS
  google_fonts: ^6.2.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10
  shimmer: ^3.0.0

  # EDITOR & TEXT
  flutter_markdown: ^0.7.0
  intl: ^0.19.0

  # UTILITIES
  uuid: ^4.3.3
  shared_preferences: ^2.2.3
  image_picker: ^1.1.0
  path: ^1.9.0
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mocktail: ^1.0.3
  build_runner: ^2.4.0
  json_serializable: ^6.8.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: PlayfairDisplay
      fonts:
        - asset: assets/fonts/PlayfairDisplay-Regular.ttf
        - asset: assets/fonts/PlayfairDisplay-Bold.ttf
          weight: 700
    - family: Montserrat
      fonts:
        - asset: assets/fonts/Montserrat-Regular.ttf
        - asset: assets/fonts/Montserrat-Medium.ttf
          weight: 500
```

---

## 🔥 13. Configuración Firebase & Emuladores (Paso a Paso)
1. **Instalar Firebase CLI:** `npm install -g firebase-tools`
2. **Login:** `firebase login`
3. **Inicializar proyecto:** `firebase init` → Seleccionar `Firestore`, `Storage`, `Emulators`
4. **Ejecutar emuladores:** `firebase emulators:start --only auth,firestore,storage,messaging`
5. **Conectar Flutter a emuladores:** En `lib/main.dart`, antes de `runApp()`:
   - Auth: `FirebaseAuth.instance.useAuthEmulator('localhost', 9099)`
   - Firestore: `FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080)`
   - Storage: `FirebaseStorage.instance.useStorageEmulator('localhost', 9199)`
   - Messaging: `FirebaseMessaging.instance.setAutoInitEnabled(true)`
6. **Verificar conexión:** Abrir `http://localhost:4000` (Emulator UI) y validar que los servicios aparecen activos.

---

## 🛡️ 14. Reglas de Seguridad Firestore & Storage

### `firestore.rules`
```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{uid} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == uid;
      allow update, delete: if request.auth.uid == uid;
    }
    match /obras/{obraId} {
      allow read: if true;
      allow create: if request.auth != null && resource.data.autorId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.autorId == request.auth.uid;
      
      match /capitulos/{capId} {
        allow read: if resource.data.publicado == true || request.auth != null;
        allow create, update, delete: if request.auth != null && get(/databases/$(database)/documents/obras/$(obraId)).data.autorId == request.auth.uid;
      }
    }
    match /comentarios/{comId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.texto.size() <= 1000;
      allow update: if request.auth != null && resource.data.usuarioId == request.auth.uid && request.time.timestamp - resource.data.creado_en.timestamp < 300000; // 5 min
      allow delete: if request.auth != null && (resource.data.usuarioId == request.auth.uid || request.auth.token.role == 'admin');
    }
    match /notificaciones/{notifId} {
      allow read, write: if request.auth != null && resource.data.usuarioId == request.auth.uid;
    }
  }
}
```

### `storage.rules`
```text
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /portadas/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 2 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
    match /avatars/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId
                         && request.resource.size < 500 * 1024;
    }
  }
}
```

---

## 🛠️ 15. Guía de Implementación Técnica (Código Esencial)
*(Se incluye solo lo necesario para arrancar sin romper el enfoque procedural del plan)*

### `lib/main.dart` (Inicialización)
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔌 DESACTIVAR EN PRODUCCIÓN
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  runApp(const LecturasApp());
}
```

### `lib/app.dart` (Theme + Providers + Router)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'application/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class LecturasApp extends StatelessWidget {
  const LecturasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Aquí se añaden StoryProvider, LibraryProvider, etc.
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        theme: neonNightTheme,
        darkTheme: neonNightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

### `lib/core/router/app_router.dart` (Guard de Autenticación)
```dart
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'application/providers/auth_provider.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    ShellRoute(
      builder: (_, __, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const FeedScreen()),
        GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
      ],
    ),
  ],
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final isAuth = auth.isAuthenticated;
    final isLogin = state.matchedLocation == '/login';
    
    if (!isAuth && !isLogin) return '/login';
    if (isAuth && isLogin) return '/home';
    return null;
  },
);
```

### `lib/application/providers/auth_provider.dart` (Estado Mínimo)
```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool get isAuthenticated => _user != null;
  String? get userId => _user?.uid;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName('Lector');
  }

  Future<void> signOut() async => await _auth.signOut();
}
```

---

## 🔄 16. Pipeline CI/CD (GitHub Actions)
```yaml
name: Flutter CI/CD
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --release
        if: github.ref == 'refs/heads/main'
      - uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/
```

---

## 🏁 17. Checkpoints de Validación por Fase
| Fase | Entregable Tangible | Criterio de Éxito | Herramienta de Validación |
|------|---------------------|-------------------|---------------------------|
| 1 | `flutter doctor` limpio + repo Git | 0 warnings, rama `main` con `.gitignore` | Terminal + Git |
| 2 | Tema global aplicado + componentes | Contraste ≥ 4.5:1, escalado fuente OK | DevTools + Accessibility Scanner |
| 3 | Login/Registro funcionando | Token JWT válido, redirección correcta | Firebase Auth Logs |
| 4 | Entidades mapeadas + repositorios | Lectura/escritura CRUD en emulador | Firestore Emulator UI |
| 5 | Feed + Navegación | Paginación sin jank, filtros activos | Performance Monitor |
| 6 | Visor + Progreso | Scroll 60fps, guardado offline/online | `shared_preferences` + DevTools |
| 7 | Comentarios + Likes | Tiempo real, sin duplicados, soft delete | StreamProvider tests |
| 8 | Panel Escritor | Publicación, portada Storage, validación | Storage Rules + Logs |
| 9 | Biblioteca + Listas | CRUD listas, estado persistente | Offline simulation |
| 10 | Notificaciones + Follow | Push recibido, deep link funcional | Firebase Messaging console |
| 11 | Tests + Optimización | Cobertura >70%, 0 memory leaks | `flutter test --coverage` |
| 12 | Builds firmados + Monitoreo | APK/IPA firmada, Crashlytics activo | Fastlane / Console |

---

## 📝 Notas Finales de Implementación
- **Orden estricto:** No saltar fases. Validar cada checkpoint antes de avanzar.
- **Emuladores primero:** Toda la lógica de Auth/Firestore/Storage debe probarse localmente antes de conectar a producción.
- **Provider sin abusos:** Dividir providers por dominio. Usar `context.select` en widgets para minimizar rebuilds.
- **Seguridad por defecto:** Las reglas de Firestore son la última línea de defensa. Validar siempre en cliente + servidor.
- **Iteración progresiva:** Lanzar MVP con: Auth + Lectura + Biblioteca + Comentarios. Añadir escritura, notificaciones y seguimiento en v1.1.

Este documento contiene **todo lo solicitado**, expandido con código esencial de arranque, configuración real de dependencias, reglas de seguridad, pipeline CI/CD y checkpoints de validación. Mantiene la estructura original intacta y añade la profundidad técnica necesaria para ejecutar el proyecto sin ambigüedades.

¿Deseas que genere el **esqueleto funcional de la Fase 1 y 2** (tema + componentes + router + auth provider listo para compilar) o prefieres avanzar directamente a la configuración de **Firestore + Emulators**?
