workspace "La Tramoya - Plataforma COAC y Archivo Histórico" "Arquitectura del Sistema basada en el modelo C4 para la digitalización del COAC y preservación histórica (Hitos 1 al 20)" {

    model {
        // =====================================================================
        // PERSONAS / ACTORES
        // =====================================================================
        publicUser = person "Ciudadanía / Afición / Investigador" "Consulta el archivo histórico, cartelera, palmarés y veredictos públicos sin autenticación." "Person,FrontOffice"
        repUser = person "Representante Legal Agrupación" "Registra cuenta, tramita inscripciones telemáticas, autorías, nómina de componentes y sube documentación PDF." "Person,GroupRepresentative"
        adminUser = person "Administrador Municipal / Patronato" "Configura la edición, bases y fases; valida inscripciones; ejecuta el sorteo de preliminares." "Person,MunicipalAdmin"
        juryPresident = person "Presidente / Secretario Jurado" "Supervisa las sesiones del Falla, aplica penalizaciones reglamentarias y publica los fallos de pase de fase y final." "Person,JuryPresident"
        juryMember = person "Vocal del Jurado Oficial" "Accede a su planilla digital ciega y emite las notas de su modalidad asignada." "Person,JuryMember"

        // =====================================================================
        // SISTEMAS EXTERNOS
        // =====================================================================
        s3System = softwareSystem "Amazon Web Services (AWS S3)" "Almacén de objetos en la nube para documentación legal (PDF) y autorizaciones con URLs prefirmadas." "External,Cloud"
        smtpSystem = softwareSystem "Servidor SMTP Municipal" "Servicio institucional para notificaciones de registro y avisos de subsanación." "External,Infrastructure"

        // =====================================================================
        // SISTEMA PRINCIPAL: LA TRAMOYA
        // =====================================================================
        laTramoya = softwareSystem "La Tramoya: Plataforma COAC y Archivo Histórico" "Plataforma central web institucional para digitalizar el concurso COAC de extremo a extremo y preservar la memoria histórica carnavalesca." {
            
            // --- C4 NIVEL 2: CONTENEDORES ---
            vaadinUi = container "Interfaz Web Reactiva (Vaadin)" "Vistas Front-Office (archivo, cartelera) y Back-Office protegido (formularios de inscripción, panel de revisión y planillas del jurado)." "Java 21, HTML/CSS, Vaadin Flow" "WebUI"
            
            database = container "Base de Datos Relacional" "Almacena ediciones, agrupaciones, inscripciones, fases, sesiones, actuaciones, actas y desglose de puntuaciones." "PostgreSQL 16" "Database"

            backendApp = container "Aplicación Monolítica Modular" "Implementa la lógica del concurso, motor de sorteo, cómputo de puntuaciones, control de sesiones y orquestación transaccional." "Spring Boot 4.x, Java 21 LTS, Spring Security" "BackendApp" {
                
                // --- C4 NIVEL 3: COMPONENTES DEL BACKEND (HITOS 1 AL 20) ---
                securityAuthSvc = component "Security & Auth Service" "Gestiona login, registro, sesiones HTTP y protección RBAC (Hitos 1, 2, 3)." "Spring Security + BCrypt"
                editionPhaseSvc = component "Edition & Phase Service" "Ciclo de vida de ediciones, apertura de plazos, configuración de fases y cupos de pase (Hitos 4, 10)." "Spring Service"
                carnivalGroupSvc = component "Carnival Group Service" "Catálogo histórico y CRUD de agrupaciones y localidades (Hito 5)." "Spring Service"
                registrationSvc = component "Registration Service" "Borradores de inscripción, validación de autorías, nómina de componentes y bandeja de revisión (Hitos 6, 7, 8, 9)." "Spring Service"
                docStorageSvc = component "Document Storage Service" "Validación y subida de documentos PDF a S3 con URLs prefirmadas (Hito 13)." "Spring Service + AWS SDK v2"
                drawSchedulingSvc = component "Draw & Scheduling Service" "Algoritmo de sorteo para preliminares, cabezas de serie y orden de sesión (Hito 14)." "Spring Service"
                sessionScheduleSvc = component "Session Schedule Service" "Consulta de calendario y cartelera de funciones del Falla (Hito 15)." "Spring Service"
                juryScoringSvc = component "Jury Scoring Service" "Gestión de planillas ciegas por modalidad y registro de notas de vocales (Hito 16)." "Spring Service"
                scoreTallyPenaltyEngine = component "Score Tally & Penalty Engine" "Descarte de notas extremas, cálculo de penalizaciones por tiempo y agregados (Hito 17)." "Spring Service"
                verdictPublicationSvc = component "Verdict Publication Service" "Cierre de fase, asignación de clasificados y publicación de veredicto oficial (Hito 18)." "Spring Service"
                historicalArchiveSvc = component "Historical Archive Service" "Buscador multi-criterio y fichas completas de palmarés y tipos sin exponer PII (Hitos 11, 19, 20)." "Spring Service + JPA Spec"
                dataSeederSvc = component "Data Seeder Service" "Carga inicial de agrupaciones y ediciones históricas para pruebas y staging (Hito 12)." "Spring Component"
                repositoryLayer = component "Capa de Repositorios (Data Access)" "Acceso y persistencia tipada sobre el modelo de datos relacional." "Spring Data JPA Repositories"
            }
        }

        // =====================================================================
        // RELACIONES - NIVEL 1 (CONTEXTO)
        // =====================================================================
        publicUser -> laTramoya "Consulta cartelera, archivo histórico y actas oficiales publicadas" "HTTPS"
        repUser -> laTramoya "Inicia sesión, rellena borradores, sube componentes/autores y confirma inscripción" "HTTPS"
        adminUser -> laTramoya "Administra ediciones, valida admisiones y ejecuta el algoritmo de sorteo" "HTTPS"
        juryPresident -> laTramoya "Supervisa deliberaciones, registra penalizaciones y firma fallos oficiales" "HTTPS"
        juryMember -> laTramoya "Cumplimenta planillas de notas digitales por actuación" "HTTPS"

        laTramoya -> s3System "Guarda y recupera expedientes en formato PDF de inscripción mediante presigned URLs" "S3 SDK / HTTPS"
        laTramoya -> smtpSystem "Envía notificaciones de registro y cambios de estado de expediente" "SMTP"

        // =====================================================================
        // RELACIONES - NIVEL 2 (CONTENEDORES)
        // =====================================================================
        publicUser -> vaadinUi "Navega por la landing, buscador del archivo y cartelera de funciones" "HTTPS"
        repUser -> vaadinUi "Inicia sesión y tramita inscripciones" "HTTPS"
        adminUser -> vaadinUi "Gestiona concurso, revisión y sorteos" "HTTPS"
        juryPresident -> vaadinUi "Supervisa y firma actas" "HTTPS"
        juryMember -> vaadinUi "Califica actuaciones en directo" "HTTPS"

        vaadinUi -> backendApp "Invoca servicios de aplicación y casos de uso de negocio" "In-Process Java Calls / Spring Context"
        backendApp -> database "Lee y escribe datos transaccionales mediante JPA/Hibernate y Flyway" "JDBC / TCP 5432"
        backendApp -> s3System "Genera Presigned URLs y almacena documentos PDF adjuntos" "AWS SDK v2 / HTTPS"
        backendApp -> smtpSystem "Despacha correos transaccionales y avisos" "JavaMail / SMTP"

        // =====================================================================
        // RELACIONES - NIVEL 3 (COMPONENTES INTERNOS DEL BACKEND)
        // =====================================================================
        registrationSvc -> editionPhaseSvc "Verifica estado de plazos"
        registrationSvc -> carnivalGroupSvc "Asocia inscripción a grupo"
        registrationSvc -> docStorageSvc "Adjunta expedientes PDF"
        drawSchedulingSvc -> registrationSvc "Obtiene inscripciones aceptadas"
        drawSchedulingSvc -> sessionScheduleSvc "Genera sesiones y actuaciones"
        scoreTallyPenaltyEngine -> juryScoringSvc "Recoge planillas enviadas"
        verdictPublicationSvc -> scoreTallyPenaltyEngine "Aplica totales y genera cortes de fase"
        historicalArchiveSvc -> carnivalGroupSvc "Consulta fichas y palmarés"

        // Dependencias hacia la Capa de Repositorios (Persistencia)
        securityAuthSvc -> repositoryLayer "Consulta credenciales y roles"
        editionPhaseSvc -> repositoryLayer "Persiste ediciones y fases"
        carnivalGroupSvc -> repositoryLayer "Persiste agrupaciones y localidades"
        registrationSvc -> repositoryLayer "Persiste inscripciones, autores y componentes"
        sessionScheduleSvc -> repositoryLayer "Persiste sesiones y actuaciones"
        drawSchedulingSvc -> repositoryLayer "Persiste cuadrante y orden de actuación"
        juryScoringSvc -> repositoryLayer "Persiste planillas y notas de vocales"
        scoreTallyPenaltyEngine -> repositoryLayer "Persiste actas acumuladas y penalizaciones"
        verdictPublicationSvc -> repositoryLayer "Persiste fallos y clasificados oficiales"
        historicalArchiveSvc -> repositoryLayer "Consultas complejas con JPA Criteria/Spec"
        dataSeederSvc -> repositoryLayer "Inserta datos maestros e históricos"

        docStorageSvc -> s3System "Transfiere binarios PDF y gestiona presigned URLs"
        repositoryLayer -> database "Operaciones SQL / JDBC"
    }

    views {
        systemContext laTramoya "DiagramaContexto" {
            include *
            autoLayout tb
            title "C4 - Nivel 1: Diagrama de Contexto del Sistema (La Tramoya - Hitos 1-20)"
        }

        container laTramoya "DiagramaContenedores" {
            include *
            autoLayout tb
            title "C4 - Nivel 2: Diagrama de Contenedores (La Tramoya - Hitos 1-20)"
        }

        component backendApp "DiagramaComponentesBackend" {
            include *
            autoLayout tb
            title "C4 - Nivel 3: Diagrama de Componentes del Backend (Hitos 1 al 20)"
        }

        styles {
            element "Person" {
                background #1168bd
                color #ffffff
                shape Person
            }
            element "Software System" {
                background #2d3e50
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #2b78e4
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }
}
