# Patrones y Soluciones: Spring Backend

Guía de patrones de diseño, transaccionalidad, inyección de dependencias y seguridad en Spring Boot 4 (Java 21).

---

## 🏗️ Principios Generales
- **Inyección por constructor:** Uso estricto de inyección mediante constructores (o `@RequiredArgsConstructor` de Lombok), prohibiendo `@Autowired` en atributos privados.
- **Límites Transaccionales (`@Transactional`):** Delimitar las operaciones atómicas en la capa de servicios (`com.aytocadiz.carnaval.service`).
- **Validación en los bordes:** Uso de `jakarta.validation` (`@NotNull`, `@Size`, `@Pattern`) en DTOs y modelos de formulario.
- **Seguridad y Control de Acceso:** Restricciones declarativas mediante `@PreAuthorize` según roles (`MUNICIPAL_ADMIN`, `JURY_PRESIDENT`, etc.).

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[05-Contexto-Sintetizado/Estado-Actual-Sistema|Estado Actual]]
