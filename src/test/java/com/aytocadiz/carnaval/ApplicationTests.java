package com.aytocadiz.carnaval;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * Prueba de carga del contexto Spring Boot y Vaadin.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@Tag("integration")
class ApplicationTests {

    @Test
    void contextLoads() {
        // Verifica que el contexto de Spring arranque adecuadamente
    }
}
