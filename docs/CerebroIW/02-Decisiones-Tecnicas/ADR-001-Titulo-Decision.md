# ADR-001: Adopción del Segundo Cerebro (CerebroIW) en Obsidian

- **Estado:** Aceptado
- **Fecha:** 2026-10-27
- **Decisores:** Equipo de Desarrollo COAC / Agente de Pair Programming

---

## 1. Contexto y Problema
El desarrollo de la plataforma de digitalización del COAC (Ayuntamiento de Cádiz) contempla un horizonte operativo de más de 15 años y un trabajo colaborativo entre dos desarrolladores y un agente inteligente. Es crítico mantener sincronizada la memoria del proyecto, las justificaciones arquitectónicas, las lecciones aprendidas y el estado de avance sin depender de memoria volátil de chat o herramientas externas cerradas.

## 2. Decisión Tomada
Se adopta una estructura de notas en Markdown gestionadas con Obsidian ubicada en `docs/CerebroIW/` con las siguientes directrices:
1. **Idioma único:** Todas las notas, decisiones y bitácoras se redactan en español claro y conciso.
2. **Exclusión de configuración local:** El directorio `.obsidian/` se añade a `.gitignore` para permitir que cada miembro del equipo configure su cliente local sin sobreescribir la del compañero.
3. **Mantenimiento incremental:** Al finalizar cada hito o tarea técnica, se registrarán decisiones (ADR), patrones, errores resueltos y bitácoras mediante enlaces bidireccionales (`[[...]]`).

## 3. Consecuencias
- **Positivas:**
  - Base de conocimiento desacoplada de plataformas propietarias (formato Markdown puro y portable).
  - Trazabilidad y contexto histórico compartido entre ambos miembros del equipo.
  - Sincronización transparente vía Git sin conflictos en archivos de configuración local.
- **Negativas / Compromisos:**
  - Requiere disciplina para registrar activamente los cambios y mantener vivos los enlaces bidireccionales.

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[01-Bitacora-Sesiones/Backlog-Pendientes|Backlog Pendientes]]
