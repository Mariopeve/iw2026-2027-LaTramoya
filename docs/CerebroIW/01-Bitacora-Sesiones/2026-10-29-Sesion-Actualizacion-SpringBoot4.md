# Bitácora de Sesión: 2026-10-29 - Actualización a Spring Boot 4 y Vaadin 25

## 1. Contexto y Objetivos
- Migración y actualización del proyecto base a **Spring Boot 4.1.2**, **Java 21** y **Vaadin 25.3.4** asegurando compatibilidad con el plan de proyecto (`[[plan-proyecto]]`).
- Actualización de los componentes del wrapper de Maven (`mvnw`) a partir del artefacto descargado.

## 2. Cambios Realizados
- **`pom.xml`**:
  - `spring-boot-starter-parent` actualizado a `4.1.2`.
  - `vaadin.version` actualizado a `25.3.4` (BOM y plugins).
- **Maven Wrapper**:
  - Actualizado `.mvn/wrapper/maven-wrapper.properties`, `mvnw` y `mvnw.cmd` a Apache Maven 3.10.0.
- **Seguridad (`SecurityConfiguration.java`)**:
  - Sustituida la herencia de la clase obsoleta `VaadinWebSecurity` por la configuración moderna mediante el bean `SecurityFilterChain` y `VaadinSecurityConfigurer.vaadin()`.
- **Documentación y Arquitectura**:
  - Actualizadas las referencias a Spring Boot 4 y Vaadin 25 en `docs/arquitectura/contexto-c4.dsl`, `docs/arquitectura/decisiones/ADR-001-estilo.md`, `AGENTS.md` y las notas de `CerebroIW`.
  - Registrado el patrón y lección aprendida en `docs/CerebroIW/04-Lecciones-Aprendidas/Gotchas-Tecnologicos.md`.

## 3. Verificación
- Compilación `test-compile`: Exitosa.
- Ejecución de pruebas con `mvn test`: 1 prueba ejecutada, 0 errores, 0 fallos (`BUILD SUCCESS`).
