# Lecciones Aprendidas: Gotchas Tecnológicos

Comportamientos inesperados o particularidades del stack tecnológico (Java 21, Spring Boot 3+, Vaadin, PostgreSQL, Obsidian).

---

## ⚡ Particularidades Identificadas

### 1. Directorios vacíos en Git
- **Comportamiento:** Git no rastrea carpetas vacías por sí solas.
- **Solución adoptada:** Cada subcarpeta funcional del Segundo Cerebro (`docs/CerebroIW/`) cuenta con su archivo `.md` inicial representativo con información del contexto para que ambos desarrolladores cuenten con la misma estructura al clonar o hacer pull.

### 2. Formato y nombres de notas en Obsidian
- **Recomendación:** Emplear nombres de archivo sin caracteres especiales problemáticos en sistemas de archivos Windows/Linux, y utilizar enlaces bidireccionales con alias cuando sea necesario (`[[Ruta/Nota|Texto Visible]]`).

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[04-Lecciones-Aprendidas/Errores-Comunes|Errores Comunes]]
