# Patrones y Soluciones: Vaadin UI

Repositorio de componentes, layouts y buenas prácticas de interfaz de usuario en Vaadin para el portal del COAC.

---

## 🎨 Sistema de Diseño y Tokens
- **Colores corporativos:**
  - Texto principal: `--text: #29221e`
  - Fondo: `--background: #f9f6f0`
  - Primario (acciones y destacados): `--primary: #805b42`
  - Secundario: `--secondary: #2a2422`
  - Acento: `--accent: #93694d`
- **Tipografías:**
  - Títulos (`h1`, `h2`): `'Cormorant Garamond'`, serif.
  - Subtítulos, modales y distintivos (`h3`, `h4`, badges): `'Cinzel'`, serif.
  - Textos de contenido, tablas y formularios: `'Lato'`, sans-serif.

## 🧱 Arquitectura de Vistas
- Separación estricta entre `ui.public` (Front-Office abierto a la ciudadanía) y `ui.admin` (Back-Office municipal y jurado).
- Regla: Las vistas nunca llaman a repositorios directos ni ejecutan consultas SQL; consumen servicios de negocio transaccionales (`service.*`).

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[05-Contexto-Sintetizado/Estado-Actual-Sistema|Estado Actual]]
