# Lecciones Aprendidas: Gotchas Tecnológicos

Comportamientos inesperados o particularidades del stack tecnológico (Java 21, Spring Boot 4, Vaadin 25, PostgreSQL, Obsidian).

## 1. Migración a Vaadin 25 y Spring Boot 4: Eliminación de VaadinWebSecurity
- **Problema:** En Vaadin 25 la clase abstracta `VaadinWebSecurity` ha sido removida completamente.
- **Solución:** Definir la seguridad declarando un bean `SecurityFilterChain` usando `VaadinSecurityConfigurer.vaadin()`:
  ```java
  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
      http.authorizeHttpRequests(auth -> auth.requestMatchers("/h2-console/**").permitAll());
      http.csrf(csrf -> csrf.ignoringRequestMatchers("/h2-console/**"));
      http.headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()));
      http.with(VaadinSecurityConfigurer.vaadin(), configurer -> {});
      return http.build();
  }
  ```

---

## ⚡ Particularidades Identificadas

### 1. Directorios vacíos en Git
- **Comportamiento:** Git no rastrea carpetas vacías por sí solas.
- **Solución adoptada:** Cada subcarpeta funcional del Segundo Cerebro (`docs/CerebroIW/`) cuenta con su archivo `.md` inicial representativo con información del contexto para que ambos desarrolladores cuenten con la misma estructura al clonar o hacer pull.

### 2. Formato y nombres de notas en Obsidian
- **Recomendación:** Emplear nombres de archivo sin caracteres especiales problemáticos en sistemas de archivos Windows/Linux, y utilizar enlaces bidireccionales con alias cuando sea necesario (`[[Ruta/Nota|Texto Visible]]`).

---
*Enlaces:* [[05-Contexto-Sintetizado/Indice-General|Índice General]] | [[04-Lecciones-Aprendidas/Errores-Comunes|Errores Comunes]]
