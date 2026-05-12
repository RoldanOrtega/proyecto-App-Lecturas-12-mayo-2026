-- Script de creación de base de datos para Proyecto LECTURAS
-- Dialecto: PostgreSQL (Recomendado por el uso de UUID y JSONB)

-- Extensiones necesarias para UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USUARIO
CREATE TABLE USUARIO (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('lector', 'autor', 'admin')),
    activo BOOLEAN NOT NULL DEFAULT true,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP
);

-- 2. OBRA
CREATE TABLE OBRA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    autor_id UUID NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    sinopsis TEXT,
    portada_url TEXT,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('novela', 'cuento', 'poema', 'ensayo')),
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('borrador', 'en_progreso', 'completa', 'pausada')),
    es_original BOOLEAN NOT NULL DEFAULT true,
    idioma VARCHAR(10) NOT NULL DEFAULT 'es',
    visitas INTEGER NOT NULL DEFAULT 0,
    publicado_en TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_obra_autor FOREIGN KEY (autor_id) REFERENCES USUARIO(id) ON DELETE CASCADE
);

-- 3. CAPITULO
CREATE TABLE CAPITULO (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    obra_id UUID NOT NULL,
    numero INTEGER NOT NULL,
    titulo VARCHAR(200),
    contenido TEXT NOT NULL,
    palabras INTEGER NOT NULL DEFAULT 0,
    publicado BOOLEAN NOT NULL DEFAULT false,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    publicado_en TIMESTAMP,
    CONSTRAINT fk_capitulo_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE
);

-- 4. GENERO
CREATE TABLE GENERO (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT,
    icono_url TEXT
);

-- 5. OBRA_GENERO (Relación Muchos a Muchos)
CREATE TABLE OBRA_GENERO (
    obra_id UUID NOT NULL,
    genero_id UUID NOT NULL,
    PRIMARY KEY (obra_id, genero_id),
    CONSTRAINT fk_og_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE,
    CONSTRAINT fk_og_genero FOREIGN KEY (genero_id) REFERENCES GENERO(id) ON DELETE CASCADE
);

-- 6. ETIQUETA
CREATE TABLE ETIQUETA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(60) NOT NULL UNIQUE
);

-- 7. OBRA_ETIQUETA (Relación Muchos a Muchos)
CREATE TABLE OBRA_ETIQUETA (
    obra_id UUID NOT NULL,
    etiqueta_id UUID NOT NULL,
    PRIMARY KEY (obra_id, etiqueta_id),
    CONSTRAINT fk_oe_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE,
    CONSTRAINT fk_oe_etiqueta FOREIGN KEY (etiqueta_id) REFERENCES ETIQUETA(id) ON DELETE CASCADE
);

-- 8. BIBLIOTECA (Lista personal)
CREATE TABLE BIBLIOTECA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    obra_id UUID NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('quiero_leer', 'leyendo', 'completada', 'abandonada')),
    agregado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, obra_id),
    CONSTRAINT fk_bib_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_bib_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE
);

-- 9. PROGRESO_LECTURA
CREATE TABLE PROGRESO_LECTURA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    obra_id UUID NOT NULL,
    capitulo_id UUID NOT NULL,
    posicion INTEGER NOT NULL DEFAULT 0, -- px o scroll
    porcentaje DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, obra_id),
    CONSTRAINT fk_prog_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_prog_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE,
    CONSTRAINT fk_prog_cap FOREIGN KEY (capitulo_id) REFERENCES CAPITULO(id) ON DELETE CASCADE
);

-- 10. RESENA
CREATE TABLE RESENA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    obra_id UUID NOT NULL,
    puntuacion INTEGER NOT NULL CHECK (puntuacion >= 1 AND puntuacion <= 5),
    comentario TEXT,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    editado_en TIMESTAMP,
    UNIQUE(usuario_id, obra_id),
    CONSTRAINT fk_res_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_res_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE
);

-- 11. COMENTARIO
CREATE TABLE COMENTARIO (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    capitulo_id UUID NOT NULL,
    parent_id UUID, -- Para hilos/respuestas
    contenido TEXT NOT NULL,
    eliminado BOOLEAN NOT NULL DEFAULT false,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_com_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_com_capitulo FOREIGN KEY (capitulo_id) REFERENCES CAPITULO(id) ON DELETE CASCADE,
    CONSTRAINT fk_com_parent FOREIGN KEY (parent_id) REFERENCES COMENTARIO(id) ON DELETE SET NULL
);

-- 12. LIKE_OBRA
CREATE TABLE LIKE_OBRA (
    usuario_id UUID NOT NULL,
    obra_id UUID NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, obra_id),
    CONSTRAINT fk_lo_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_lo_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE
);

-- 13. LIKE_COMENTARIO
CREATE TABLE LIKE_COMENTARIO (
    usuario_id UUID NOT NULL,
    comentario_id UUID NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, comentario_id),
    CONSTRAINT fk_lc_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_lc_comentario FOREIGN KEY (comentario_id) REFERENCES COMENTARIO(id) ON DELETE CASCADE
);

-- 14. SEGUIMIENTO
CREATE TABLE SEGUIMIENTO (
    seguidor_id UUID NOT NULL,
    seguido_id UUID NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (seguidor_id, seguido_id),
    CHECK (seguidor_id <> seguido_id),
    CONSTRAINT fk_seg_seguidor FOREIGN KEY (seguidor_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_seg_seguido FOREIGN KEY (seguido_id) REFERENCES USUARIO(id) ON DELETE CASCADE
);

-- 15. NOTIFICACION
CREATE TABLE NOTIFICACION (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    tipo VARCHAR(20) NOT NULL, -- nuevo_cap, nuevo_seguidor, comentario, like
    datos JSONB,
    leida BOOLEAN NOT NULL DEFAULT false,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_not_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE
);

-- 16. SUSCRIPCION
CREATE TABLE SUSCRIPCION (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    obra_id UUID NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, obra_id),
    CONSTRAINT fk_sus_usuario FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE,
    CONSTRAINT fk_sus_obra FOREIGN KEY (obra_id) REFERENCES OBRA(id) ON DELETE CASCADE
);
