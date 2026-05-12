# proyecto-App-Lecturas-12-mayo-2026
Como administrador de base de datos del proyecto **Lecturas**, aquí están las entidades necesarias para gestionar la plataforma completa:Aquí el desglose agrupado por dominio funcional:

---

**Núcleo de contenido**

`USUARIO` — Almacena lectores y escritores. El campo `rol` distingue entre usuario básico, autor verificado y administrador.

`OBRA` — Entidad central de la plataforma. El campo `es_original` diferencia obras publicadas aquí por primera vez de adaptaciones o fanfics. `estado` puede ser: borrador, en progreso, completada, pausada.

`CAPITULO` — Las obras se publican por capítulos para permitir publicación progresiva. Guarda el conteo de palabras para métricas del autor.

---

**Clasificación y descubrimiento**

`GENERO` y `OBRA_GENERO` — Relación muchos a muchos (una obra puede ser Romance/Suspenso/Drama simultáneamente).

`ETIQUETA` y `OBRA_ETIQUETA` — Tags más granulares definidos por el autor, como `magia-suave`, `viaje-en-el-tiempo`, `slow-burn`.

---

**Interacción social**

`RESENA` — Calificación con texto largo, una por usuario/obra. Diferente al comentario de capítulo.

`COMENTARIO` — Hilo por capítulo, con soporte de respuestas anidadas vía `parent_id`.

`LIKE_OBRA` / `LIKE_COMENTARIO` — Tablas separadas para mantener integridad referencial limpia.

`SEGUIMIENTO` — Red social de autores (follower/following).

`SUSCRIPCION` — El usuario se suscribe a una obra para recibir alertas de nuevos capítulos.

---

**Experiencia de lectura**

`PROGRESO_LECTURA` — Guarda en qué capítulo y posición (scroll/página) quedó el lector. Permite continuar donde lo dejó.

`BIBLIOTECA` — Lista personal del usuario con estados: quiero-leer, leyendo, completada, abandonada.

---

**Soporte del sistema**

`NOTIFICACION` — Centraliza todos los eventos (nuevo capítulo, nuevo seguidor, respuesta a comentario). El campo `datos` en JSONB permite payload flexible según el tipo de notificación.

---

**Decisiones de diseño clave:** usar `uuid` en lugar de enteros secuenciales facilita la distribución futura; separar `RESENA` de `COMENTARIO` permite métricas de calificación independientes del engagement por capítulo; y el campo `es_original` en `OBRA` abre la puerta a gestión de derechos en el futuro.

¿Quieres profundizar en alguna entidad, definir índices y restricciones, o diseñar la estrategia de particionamiento?

<img width="939" height="480" alt="image" src="https://github.com/user-attachments/assets/8d9e2fff-2b9b-4c8b-ae32-59a3aeac1c71" />

<img width="741" height="433" alt="image" src="https://github.com/user-attachments/assets/5222bf59-4939-4873-baea-cc2b098c7379" />
<img width="733" height="536" alt="image" src="https://github.com/user-attachments/assets/eedd58d6-2923-4060-a03f-28ac0d05cfba" />
<img width="734" height="404" alt="image" src="https://github.com/user-attachments/assets/cf449f9e-342d-4fd1-ac4e-acda2af2d4ff" />
<img width="737" height="249" alt="image" src="https://github.com/user-attachments/assets/e924c92c-1c50-431a-b3df-9c54e777820f" />
<img width="733" height="162" alt="image" src="https://github.com/user-attachments/assets/67eab6cf-eaec-4e58-97f5-eb9b5fd5254b" />
<img width="731" height="162" alt="image" src="https://github.com/user-attachments/assets/2c96493d-f8be-4997-9d94-40c3aadd5a46" />
<img width="730" height="165" alt="image" src="https://github.com/user-attachments/assets/0aff5029-e628-444f-a465-31bc2a23cc1a" />
<img width="735" height="283" alt="image" src="https://github.com/user-attachments/assets/b42c7caf-7abf-41be-b40d-82f2a8465407" />
<img width="732" height="348" alt="image" src="https://github.com/user-attachments/assets/1eb28f2b-555a-4e08-af89-2ecc67e46737" />
<img width="729" height="331" alt="image" src="https://github.com/user-attachments/assets/816aa474-7e07-4b24-8681-a5ca5a8cd369" />
<img width="731" height="346" alt="image" src="https://github.com/user-attachments/assets/92c02934-fe20-4063-bde5-094919bb4c00" />
<img width="731" height="194" alt="image" src="https://github.com/user-attachments/assets/0545990a-5337-4d60-8bc5-ee517403eceb" />
<img width="729" height="197" alt="image" src="https://github.com/user-attachments/assets/5bb35158-f85c-43cb-afff-d47ac7d6a3a0" />
<img width="735" height="199" alt="image" src="https://github.com/user-attachments/assets/15253d4c-67fd-4c8a-9e0c-2dc540e9c895" />
<img width="729" height="317" alt="image" src="https://github.com/user-attachments/assets/4ac241a5-ea9a-46a8-bb4d-f4604b1e2045" />
<img width="734" height="237" alt="image" src="https://github.com/user-attachments/assets/b0f68a41-03e0-41ca-b9e5-6b3747a003ca" />
