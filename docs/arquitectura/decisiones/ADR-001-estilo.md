# ADR-001: Estilo Arquitectónico Monolítico Modular con Frontend Vaadin y Backend Spring Boot

* **Estado:** Aceptado
* **Fecha:** 2026-10-22
* **Decisores:** Equipo de Desarrollo (Mario Peláez Vera, Juan Francisco Rodríguez Bilbao)

---

## 1. Contexto y Planteamiento del Problema

El sistema **La Tramoya** digitaliza el Concurso Oficial de Agrupaciones Carnavalescas (COAC) y salvaguarda el patrimonio histórico documental del Carnaval de Cádiz para el Excmo. Ayuntamiento de Cádiz. 

Los requerimientos fundamentales imponen:
1. **Horizonte de mantenimiento a más de 15 años:** El sistema debe permanecer comprensible, ejecutable y mantenible en el futuro por desarrolladores desconocidos hoy.
2. **Coherencia transaccional estricta:** Procesos críticos como el cierre de inscripciones, el sorteo preliminar de cabezas de serie y el cómputo de calificaciones con descarte de notas extremas requieren consistencia ACID absoluta.
3. **Múltiples perfiles de usuario:** Desde la afición e investigadores en el Front-Office abierto hasta administradores municipales y jurados oficiales calificando en tiempo real en el Gran Teatro Falla.
4. **Presupuesto y simplicidad operativa:** Evitar sobrecostes de infraestructura en la nube y complejidad innecesaria de orquestación distribuida (microservicios).

---

## 2. Decisión Tomada

Se decide adoptar un **Monolito Modular** estructurado en:
- **Capa de Presentación Web:** **Vaadin Flow (Java 21 / HTML5)**. Permite construir tanto el Front-Office accesible como las vistas ricas del Back-Office (grids, formularios multipaso de inscripción, planillas en vivo del jurado) de forma tipada, segura y unificada en Java.
- **Capa de Aplicación y Dominio:** **Spring Boot 3.x / Java 21 LTS**, organizado en módulos de servicio cohesivos por hito/dominio (inscripciones, jurado, archivo histórico, etc.).
- **Capa de Persistencia:** **Spring Data JPA / Hibernate con PostgreSQL 16**, con soporte de migraciones de esquema mediante **Flyway**.
- **Almacenamiento de Binarios:** **AWS S3** desacoplado mediante URLs prefirmadas para documentación PDF sensible, evitando saturar la base de datos relacional.

---

## 3. Justificación y Alternativas Evaluadas

### Alternativa 1: Arquitectura de Microservicios Distribuidos
- *Descartada:* Añadiría sobrecoste severo de red, latencia, necesidad de coordinadores de transacciones distribuidas (Saga/2PC) para sorteos y calificaciones, y una sobrecarga operativa (múltiples pipelines, monitorización distribuida) inviable para un equipo reducido y una entidad pública municipal.

### Alternativa 2: Single Page Application (SPA en React/Angular/Vue) + REST API
- *Descartada:* Exigiría duplicar modelos y validaciones de tipos en TypeScript y Java. Vaadin Flow mantiene la lógica y validación en el servidor con comunicación reactiva mediante WebSocket/XHR transparente, reduciendo el riesgo de vulnerabilidades XSS/CSRF y facilitando el cumplimiento de accesibilidad WCAG 2.1 AA.

---

## 4. Consecuencias y Beneficios

### Positivas:
- **Alta Cohesión y Bajo Acoplamiento:** Cada servicio encapsula su lógica y se comunica mediante contratos e interfaces Java fuertemente tipadas en memoria.
- **Transaccionalidad Directa:** Uso de `@Transactional` de Spring con aislamiento garantizado en la base de datos PostgreSQL.
- **Despliegue y Mantenimiento Sencillo:** Un único artefacto desplegable ejecutable en contenedor Docker / AWS ECS Fargate, reduciendo los costes en la nube.
- **Seguridad Robusta:** Control de acceso centralizado mediante Spring Security (RBAC) y sesiones seguras.

### Negativas / Mitigaciones:
- *Riesgo de acoplamiento accidental entre módulos:* Se mitigará aplicando reglas estrictas de visibilidad de paquetes, inversión de dependencias y pruebas unitarias aisladas por servicio.
