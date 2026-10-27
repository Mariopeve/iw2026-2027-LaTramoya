# Backlog de Tareas Pendientes y Mejoras

Lista viva de tareas, refinamientos arquitectónicos y mejoras detectadas a lo largo de las sesiones de desarrollo.

---

## 📌 Prioridad Alta (Inmediatas / Sprint Actual)
- [ ] Inicialización controlada del backend Spring Boot con Java 21 y Maven según `AGENTS.md`.
- [ ] Configuración de la capa de persistencia y conexión a base de datos PostgreSQL (con soporte para perfiles dev y prod).
- [ ] Definición del modelo de dominio inicial del COAC:
  - `Modality` (Enum: COMPARSA, CHIRIGOTA, CORO, CUARTETO).
  - `Edition` (Ciclo de vida anual, bases, estados).
  - `CarnivalGroup` / `Ensemble` (Historial, tipos, nombres previos).

## ⏳ Prioridad Media (Siguientes Sprints)
- [ ] Implementación de la vista pública de consulta de agrupaciones y archivo histórico en Vaadin (Front-Office).
- [ ] Implementación de vistas administrativas de registro y baremación de jurado (Back-Office).
- [ ] Aplicación estricta del sistema de diseño (paleta de colores y tipografías Cormorant Garamond / Cinzel / Lato).

## 💡 Ideas y Mejoras a Evaluar
- [ ] Generación automática de actas de jurado en formato PDF exportable.
- [ ] Sistema de sellado inmutable para ediciones concluidas.

---
*Enlaces relacionados:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[05-Contexto-Sintetizado/Estado-Actual-Sistema|Estado Actual del Sistema]]
