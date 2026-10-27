# Patrones y Soluciones: PostgreSQL Queries

Registro de consultas complejas, optimizaciones de índices, migraciones y patrones de persistencia para el archivo histórico del Carnaval de Cádiz.

---

## 🏛️ Directrices de Persistencia y Consultas
- **Longevidad y Portabilidad:** Esquemas relacionales normalizados y estándar SQL para asegurar una vida útil de +15 años sin acoplamiento a extensiones privativas.
- **Principio de Mínimo Privilegio (PoLP):** Proyecciones específicas para vistas públicas evitando `SELECT *` sobre tablas que contengan datos personales o sensibles.
- **Inmutabilidad de Ediciones Concluidas:** Índices de solo lectura y estrategias de consulta para datos históricos y palmarés.

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[05-Contexto-Sintetizado/Estado-Actual-Sistema|Estado Actual]]
