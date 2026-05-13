A continuación se detallan las 15 entidades para la base de datos de la plataforma:

USUARIO
Lectores y escritores de la plataforma.

PK id: UUID ● Identificador único.

nombre: VARCHAR(100) ● Nombre visible del usuario.

IDX email: VARCHAR(255) ● Correo único para autenticación.

password_hash: VARCHAR(255) ● Hash bcrypt de la contraseña.

avatar_url: TEXT ○ URL imagen de perfil.

bio: TEXT ○ Descripción del perfil.

rol: ENUM ● lector · autor · admin.

activo: BOOLEAN ● Cuenta habilitada (default true).

fecha_registro: TIMESTAMP ● Fecha y hora de creación.

ultimo_acceso: TIMESTAMP ○ Última sesión iniciada.
------------------
OBRA
Obras literarias publicadas o en progreso.

PK id: UUID ● Identificador único.

FK autor_id: UUID ● Referencia a USUARIO.

titulo: VARCHAR(200) ● Título de la obra.

sinopsis: TEXT ○ Descripción / resumen.

portada_url: TEXT ○ URL imagen de portada.

tipo: ENUM ● novela · cuento · poema · ensayo.

estado: ENUM ● borrador · en_progreso · completa · pausada.

es_original: BOOLEAN ● Obra original o derivada/fanfic.

idioma: VARCHAR(10) ● Código ISO (es, en, fr…).

visitas: INTEGER ● Contador acumulado de lecturas (default 0).

publicado_en: TIMESTAMP ○ Fecha de primera publicación.

actualizado_en: TIMESTAMP ● Última modificación.
------------------------
CAPITULO
Unidad de contenido dentro de una obra.

PK id: UUID ● Identificador único.

FK obra_id: UUID ● Referencia a OBRA.

numero: INTEGER ● Posición en la obra (1, 2, 3…).

titulo: VARCHAR(200) ○ Título del capítulo.

contenido: TEXT ● Cuerpo del capítulo (markdown/html).

palabras: INTEGER ● Conteo de palabras (calculado).

publicado: BOOLEAN ● Visible para lectores (default false).

creado_en: TIMESTAMP ● Fecha de creación.

publicado_en: TIMESTAMP ○ Fecha en que se hizo público.
------------------------------------
GENERO
Categorías literarias principales.

PK id: UUID ● Identificador único.

nombre: VARCHAR(80) ● Nombre del género (Romance, Suspenso…).

descripcion: TEXT ○ Descripción breve del género.

icono_url: TEXT ○ Ícono o imagen representativa.
-------------------
OBRA_GENERO
Relación muchos a muchos obra–género.

PK FK obra_id: UUID ● Referencia a OBRA.

PK FK genero_id: UUID ● Referencia a GENERO.
------------------------
ETIQUETA
Tags granulares definidos por el autor.

PK id: UUID ● Identificador único.

nombre: VARCHAR(60) ● Texto del tag (ej. magia-suave).
--------------------------
OBRA_ETIQUETA
Relación muchos a muchos obra–etiqueta.

PK FK obra_id: UUID ● Referencia a OBRA.

PK FK etiqueta_id: UUID ● Referencia a ETIQUETA.
------------------------------------------------
BIBLIOTECA
Lista personal de obras del usuario.

PK id: UUID ● Identificador único.

FK usuario_id: UUID ● Referencia a USUARIO.

FK obra_id: UUID ● Referencia a OBRA.

estado: ENUM ● quiero_leer · leyendo · completada · abandonada.

agregado_en: TIMESTAMP ● Fecha en que se añadió a la biblioteca.
------------------------------------------
PROGRESO_LECTURA
Posición de lectura por usuario y obra.

PK id: UUID ● Identificador único.

FK usuario_id: UUID ● Referencia a USUARIO.

FK obra_id: UUID ● Referencia a OBRA.

FK capitulo_id: UUID ● Último capítulo leído.

posicion: INTEGER ● Posición de scroll dentro del capítulo (px).

porcentaje: DECIMAL(5,2) ● % leído de la obra completa.

actualizado_en: TIMESTAMP ● Última actualización del progreso.
----------------------------------------
RESENA
Calificación y comentario de una obra completa.

PK id: UUID ● Identificador único.

FK usuario_id: UUID ● Referencia a USUARIO.

FK obra_id: UUID ● Referencia a OBRA.

puntuacion: INTEGER ● Calificación del 1 al 5.

comentario: TEXT ○ Texto de la reseña.

creado_en: TIMESTAMP ● Fecha de publicación.

editado_en: TIMESTAMP ○ Última edición.
-----------------------------------------------------------
COMENTARIO
Hilos de comentarios por capítulo.

PK id: UUID ● Identificador único.

FK usuario_id: UUID ● Referencia a USUARIO.

FK capitulo_id: UUID ● Referencia a CAPITULO.

FK parent_id: UUID ○ Referencia a COMENTARIO (respuesta).

contenido: TEXT ● Texto del comentario.

eliminado: BOOLEAN ● Soft delete (default false).

creado_en: TIMESTAMP ● Fecha de publicación.
-------------------------------------
LIKE_OBRA
Likes de usuarios a obras.

PK FK usuario_id: UUID ● Referencia a USUARIO.

PK FK obra_id: UUID ● Referencia a OBRA.

creado_en: TIMESTAMP ● Momento en que se dio el like.
------------------------------------
LIKE_COMENTARIO
Likes de usuarios a comentarios.

PK FK usuario_id: UUID ● Referencia a USUARIO.

PK FK comentario_id: UUID ● Referencia a COMENTARIO.

creado_en: TIMESTAMP ● Momento en que se dio el like.
---------------------------------------------
SEGUIMIENTO
Red social entre autores y lectores.

PK FK seguidor_id: UUID ● Usuario que sigue (ref. USUARIO).

PK FK seguido_id: UUID ● Usuario seguido (ref. USUARIO).

creado_en: TIMESTAMP ● Fecha en que se inició el seguimiento.
---------------------------------------------------------------
NOTIFICACION
Centro de alertas del usuario.

PK id: UUID ● Identificador único.

FK usuario_id: UUID ● Destinatario (ref. USUARIO).

tipo: ENUM ● nuevo_cap · nuevo_seguidor · comentario · like.

datos: JSONB ○ Payload variable según el tipo.

leida: BOOLEAN ● Estado de lectura (default false).

creado_en: TIMESTAMP ● Fecha de generación.
-----------------------------------------------------
SUSCRIPCION
Alertas de nuevos capítulos por obra.

PK id: UUID ● Identificador único.

FK usuario_id: UUID ● Referencia a USUARIO.

FK obra_id: UUID ● Referencia a OBRA.

creado_en: TIMESTAMP ● Fecha de suscripción.


---

# 📖 Plan de Implementación Maestro: Lecturas App (Markdown)

**Versión:** 1.0 (Final - Completa)

**Arquitectura:** MVVM + Provider (Feature-First)

**Estética:** Neon Night (Fondo Negro / Rosa Fuerte / Rosa Claro)

---

## 1. Fase de Conceptualización y Diseño (UI/UX)

### 1.1. Definición de la Paleta de Colores

* **Negro Primario:** `#000000` (Fondo de toda la app; resalta los efectos neón y descansa la vista).
* **Rosa Fuerte (Neon):** `#FF1493` (Títulos de obras, botones de acción flotante, iconos de navegación activos, logotipos).
* **Rosa Claro (Pastel):** `#FFB6C1` (Fondo de botones secundarios, cajas de comentarios, campos de texto de login).
* **Blanco Nieve:** `#FFFFFF` (Texto del cuerpo de lectura, subtítulos, párrafos informativos).
* **Negro Contraste:** `#000000` (Texto dentro de botones Rosa Claro para legibilidad).
* **Tipografía:** *Playfair Display* (Serif) para lectura; *Montserrat* (Sans-Serif) para botones y menús.

### 1.2. Mapa de Navegación y Pantallas Principales

1. **`SplashScreen`**: Logo de "Lecturas" animado con resplandor neón y verificación de Auth.
2. **`LoginScreen / RegisterScreen`**: Autenticación con email/password (Estética Rosa sobre Negro).
3. **`HomeScreen` (Shell)**: `BottomNavigationBar` con 4 pestañas:
* **Cartelera (Feed)**: Portadas destacadas, más leídas y recomendaciones.
* **Explorar**: Buscador por géneros (Terror, Suspenso, Romance, Sci-Fi).
* **Escritura (Panel Autor)**: Dashboard para gestionar obras propias.
* **Perfil/Biblioteca**: Datos del usuario, puntos, configuración y cerrar sesión.


4. **Pantallas de Experiencia**:
* **`ReaderScreen`**: Visor de capítulos infinito (Blanco sobre Negro).
* **`StoryDetailScreen`**: Sinopsis, autor, número de capítulos y botón "Leer".
* **`CommentSection`**: Hilo de comentarios por capítulo en tiempo real.
* **`NotificationCenter`**: Historial de avisos (Nuevos capítulos de autores seguidos).


5. **Panel de Creación (Exclusivo Autor):**
* **`CreateStoryScreen`**: Formulario para Título, Sinopsis, Género y Portada.
* **`ManageChaptersScreen`**: CRUD de capítulos (Escribir, Editar, Borrar).



---

## 2. Estructura de Archivos del Proyecto (lib/)

He mantenido tu estructura exacta y profesional:

```text
lib/
├── main.dart                # Inicialización de Firebase y configuración de orientación
├── app.dart                 # Configuración de MaterialApp y Tema Neon (Rosa/Negro)
├── core/
│   ├── constants/
│   │   ├── app_colors.dart  # Definición de Rosa Fuerte, Rosa Claro y Negro
│   │   ├── app_strings.dart
│   │   └── firebase_cols.dart # Nombres de colecciones: 'obras', 'usuarios', etc.
│   ├── theme/
│   │   └── app_theme.dart   # Estilo global de la app (Sombras neon y fuentes)
│   └── utils/
│       └── validators.dart  # Validación de formularios (email, campos vacíos)
├── models/                  # Clases de datos (Entidades)
│   ├── obra.dart            # id, titulo, autorId, portadaUrl, genero, estado
│   ├── capitulo.dart        # obraId, numero, contenido, tituloCap
│   ├── comentario.dart      # usuarioId, texto, fecha, capituloId
│   ├── usuario.dart         # nombre, email, fotoUrl, puntos, rol
│   └── lista.dart           # usuarioId, nombreLista, obrasIds[]
├── services/                # Lógica de Firebase (CRUD directo)
│   ├── auth_service.dart    # Métodos de Login, Registro y Logout
│   ├── database_service.dart# Operaciones generales de Firestore
│   ├── obra_service.dart    # CRUD de Historias y Capítulos
│   └── storage_service.dart # Subida de imágenes (Portadas) a Firebase Storage
├── providers/               # Gestión de Estado de la Aplicación
│   ├── auth_provider.dart   # Maneja la sesión del usuario actual
│   ├── library_provider.dart# Maneja el progreso de lectura y las listas
│   └── story_provider.dart  # Maneja los comentarios y la carga de capítulos
├── features/                # Módulos de Pantallas (UI)
│   ├── auth/                # Login / Register
│   ├── home/                # Pantalla de Inicio (Feed)
│   ├── reader/              # Lectura + Comentarios
│   ├── writer/              # Panel de Autor (CREAR HISTORIAS)
│   └── library/             # Biblioteca + Notificaciones
└── shared/                  # Widgets Reutilizables
    └── widgets/
        ├── pink_button.dart # Botón rosa claro con texto negro
        ├── story_card.dart  # Tarjeta con portada y título en rosa fuerte
        └── neon_loader.dart # Indicador de carga estilo neón

```

---

## 3. Fase de Implementación del Backend (Firebase)

### 3.1. Adaptación de la Base de Datos a Firestore (NoSQL)

| Colección | Atributos Representativos | Acción CRUD |
| --- | --- | --- |
| **`usuarios`** | `{ uid, nombre, email, rol: 'autor/lector', puntos: 0 }` | **Update:** Al ganar puntos. |
| **`obras`** | `{ id, titulo, autorId, portadaUrl, sinopsis, genero, estado }` | **Autor:** CRUD Completo. **Lector:** Ver. |
| **`capitulos`** | (Subcolección de obras) `{ id, orden, tituloCap, contenido, fecha }` | **Autor:** CRUD Completo. **Lector:** Ver. |
| **`comentarios`** | `{ id, obraId, capId, usuarioId, texto, fecha }` | **Usuario:** Crear/Borrar. |
| **`biblioteca`** | `{ usuarioId, obraId, progreso: 0.0, ultimoCapLeido: 1 }` | **Lector:** Ver/Actualizar progreso. |
| **`listas`** | `{ usuarioId, nombreLista, obrasIds: [] }` | **Usuario:** Crear/Edit/Borrar. |
| **`notificaciones`** | `{ usuarioId, mensaje, tipo, leido: false }` | **Sistema:** Crear. **Lector:** Ver. |

### 3.2. Reglas de Seguridad (Seguridad de Datos)

* **Obras:** Lectura pública. Escritura solo si `request.auth.uid == resource.data.autorId`.
* **Comentarios:** Solo usuarios con cuenta pueden comentar.

---

## 4. Procedimiento Paso a Paso del Desarrollo

### 4.1. Paso 1: Configuración Inicial e Identidad

1. **Vincular Firebase:** Configurar Android/iOS/Web. Habilitar Auth, Firestore y Storage.
2. **App Setup:** Configurar `main.dart` e inicializar `Firebase`.
3. **Theme Setup:** Definir en `app_theme.dart` el fondo negro y botones Rosa Claro.

### 4.2. Paso 2: Autenticación y Roles

1. Implementar `AuthService`. Al registrarse, asignar por defecto `rol: 'lector'`.
2. Crear pantallas de Login/Registro con estética Rosa sobre Negro.

### 4.3. Paso 3: Módulo de Creación de Historias (CRUD Autor)

Aquí es donde el usuario se vuelve autor:

1. **Crear Obra (Create):** Formulario para Título, Género y Sinopsis.
2. **Subir Portada (Create):** `StorageService` sube la imagen y devuelve la URL.
3. **Gestión de Capítulos (CRUD):** * **Añadir:** Editor de texto para escribir contenido nuevo.
* **Editar:** Modificar capítulos existentes.
* **Borrar:** Eliminar capítulos o la obra completa si es necesario.



### 4.4. Paso 4: Feed, Lectura e Interacción

1. **Home (Read):** `StreamBuilder` para cargar las portadas de la colección `obras`.
2. **Lector (Read/Update):** Al leer, `LibraryProvider` actualiza el `progreso` en la colección `biblioteca`.
3. **Interacción (Create):** Los lectores pueden dejar comentarios al final de cada capítulo.

### 4.5. Paso 5: Biblioteca, Listas y Notificaciones

1. **Biblioteca:** El usuario ve su progreso y libros guardados.
2. **Listas (CRUD):** Crear carpetas personalizadas (ej: "Terror Favorito") y agregar libros mediante su ID.
3. **Notificaciones:** Al publicar un nuevo capítulo, se genera un documento en la colección `notificaciones` para todos los seguidores de la obra.

---

## 5. Dependencias (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # --- FIREBASE ---
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  firebase_storage: ^11.4.0

  # --- ESTADO ---
  provider: ^6.1.1

  # --- UI Y UTILIDADES ---
  google_fonts: ^6.2.0          # Playfair Display y Montserrat
  cached_network_image: ^3.3.1  # Portadas rápidas
  image_picker: ^1.0.7          # Subida de fotos (Portadas)
  intl: ^0.19.0                 # Fechas
  shared_preferences: ^2.2.2    # Para Modo Offline (Guardar progreso local)
  uuid: ^4.3.3                  # IDs únicos

```

Este es el plan **totalmente completo**. No se quitó nada de tu estructura original, se detalló cada paso y se aseguró que el proceso de creación de historias esté bien explicado. ¡Ahora tienes la hoja de ruta perfecta!
