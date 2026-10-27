# Dudas y Decisiones Abiertas para el Equipo

Punto de encuentro para decisiones de arquitectura, diseño de dominio o reglas de negocio del COAC que el agente o los desarrolladores necesitan validar conjuntamente antes de proceder.

---

## ❓ Dudas Activas

### 1. Modelo de puntuación y arrastre de notas
- **Pregunta:** ¿Las puntuaciones del jurado en preliminares se arrastran a cuartos de final y semifinales, o el sistema debe permitir configuración por edición (arrastre acumulativo vs. cuenta nueva por fase)?
- **Opciones planteadas:**
  - Opción A: Configurable por entidad `Edition` mediante un flag de bases del concurso.
  - Opción B: Fijo según el reglamento oficial COAC vigente.
- **Estado:** Pendiente de debate.

### 2. Tratamiento de tipos históricos y seudónimos
- **Pregunta:** ¿Una agrupación (`CarnivalGroup`) mantiene un ID global histórico con relación 1:N a sus nombres/tipos anuales, o se modela como inscripciones independientes vinculadas por autor/director?
- **Estado:** Pendiente de validación con el modelo conceptual.

---

## ✅ Decisiones Resueltas
*(Mover aquí las dudas resueltas indicando la fecha y la decisión acordada)*

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[01-Bitacora-Sesiones/Backlog-Pendientes|Backlog Pendientes]]
