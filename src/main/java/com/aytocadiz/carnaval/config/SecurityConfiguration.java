package com.aytocadiz.carnaval.config;

import com.vaadin.flow.spring.security.VaadinSecurityConfigurer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Configuracion de seguridad base integrada con Vaadin 25 y Spring Boot 4.
 */
@EnableWebSecurity
@Configuration
public class SecurityConfiguration {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        // Permite acceso publico a la consola H2 en desarrollo
        http.authorizeHttpRequests(auth -> auth.requestMatchers("/h2-console/**").permitAll());
        http.csrf(csrf -> csrf.ignoringRequestMatchers("/h2-console/**"));
        http.headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()));

        // Configura el soporte de seguridad propio de Vaadin
        http.with(VaadinSecurityConfigurer.vaadin(), configurer -> {});

        return http.build();
    }
}
