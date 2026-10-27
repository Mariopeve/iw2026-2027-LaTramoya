# Lecciones Aprendidas: Errores Comunes

Catálogo de errores resueltos, bugs encontrados y advertencias prácticas para evitar reincidir en problemas ya superados.

---

## 📋 Registro de Errores

### 1. Inclusión accidental de metadatos locales de Obsidian en Git
- **Problema:** Tras abrir la carpeta `docs/CerebroIW` en Obsidian, se generaba el directorio `.obsidian/` con configuraciones locales de workspace y plugins personales, ensuciando los commits.
- **Causa:** Ausencia de la regla en el archivo `.gitignore` raíz.
- **Solución:** Añadir `.obsidian/` y `**/.obsidian/` al `.gitignore` para versionar únicamente el contenido documental (`.md`).

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[04-Lecciones-Aprendidas/Gotchas-Tecnologicos|Gotchas Tecnológicos]]
