package com.aytocadiz.carnaval.config;

import com.vaadin.flow.spring.security.VaadinWebSecurity;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

/**
 * Configuracion de seguridad base integrada con Vaadin.
 */
@EnableWebSecurity
@Configuration
public class SecurityConfiguration extends VaadinWebSecurity {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // Permite acceso publico a la consola H2 en desarrollo
        http.authorizeHttpRequests(auth -> auth.requestMatchers("/h2-console/**").permitAll());
        http.csrf(csrf -> csrf.ignoringRequestMatchers("/h2-console/**"));
        http.headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()));

        super.configure(http);
    }
}
