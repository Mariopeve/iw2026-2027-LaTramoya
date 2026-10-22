# Arquitectura del Sistema - Modelo C4 (La Tramoya)

Este documento describe la arquitectura global del sistema **La Tramoya (Plataforma COAC y Archivo Histórico)** siguiendo la metodología C4 (Contexto, Contenedores y Componentes) que cubre los hitos funcionales 1 al 20.

---

## 1. C4 Nivel 1: Diagrama de Contexto del Sistema

Describe la interacción entre los distintos tipos de usuarios institucionales y de la ciudadanía con el sistema La Tramoya y los sistemas externos integrados.

```mermaid
flowchart TB
    subgraph Actores["Actores del Sistema"]
        pubUser["<b>Ciudadanía / Afición / Investigador</b><br/>[Person]<br/>Consulta el archivo histórico, cartelera, palmarés y veredictos públicos sin autenticación."]
        repUser["<b>Representante Legal Agrupación</b><br/>[Person]<br/>Registra cuenta, tramita inscripciones telemáticas, autorías, nómina de componentes y sube documentación PDF."]
        adminUser["<b>Administrador Municipal / Patronato</b><br/>[Person]<br/>Configura la edición, bases y fases; valida inscripciones; ejecuta el sorteo de preliminares."]
        presUser["<b>Presidente / Secretario Jurado</b><br/>[Person]<br/>Supervisa las sesiones del Falla, aplica penalizaciones reglamentarias y publica los fallos de pase de fase y final."]
        vocUser["<b>Vocal del Jurado Oficial</b><br/>[Person]<br/>Accede a su planilla digital ciega y emite las notas de su modalidad asignada."]
    end

    subgraph SistemaCentral["Sistema Central"]
        laTramoya["<b>La Tramoya: Plataforma COAC y Archivo Histórico</b><br/>[Software System]<br/>Plataforma central web institucional para digitalizar el concurso COAC de extremo a extremo y preservar la memoria histórica carnavalesca."]
    end

    subgraph Externos["Sistemas Externos"]
        awsS3["<b>Amazon Web Services (AWS S3)</b><br/>[Software System]<br/>Almacén de objetos en la nube para documentación legal (PDF) y autorizaciones con URLs prefirmadas."]
        smtpServer["<b>Servidor SMTP Municipal</b><br/>[Software System]<br/>Servicio institucional para notificaciones de registro y avisos de subsanación."]
    end

    pubUser -->|"Consulta cartelera, archivo histórico y actas oficiales publicadas<br/>[HTTPS]"| laTramoya
    repUser -->|"Inicia sesión, rellena borradores, sube componentes/autores y confirma inscripción<br/>[HTTPS]"| laTramoya
    adminUser -->|"Administra ediciones, valida admisiones y ejecuta el algoritmo de sorteo<br/>[HTTPS]"| laTramoya
    presUser -->|"Supervisa deliberaciones, registra penalizaciones y firma fallos oficiales<br/>[HTTPS]"| laTramoya
    vocUser -->|"Cumplimenta planillas de notas digitales por actuación<br/>[HTTPS]"| laTramoya

    laTramoya -->|"Guarda y recupera expedientes en formato PDF de inscripción mediante presigned URLs<br/>[S3 SDK / HTTPS]"| awsS3
    laTramoya -->|"Envía notificaciones de registro y cambios de estado de expediente<br/>[SMTP]"| smtpServer
```

---

## 2. C4 Nivel 2: Diagrama de Contenedores

Muestra la separación física y de procesos: la capa de presentación rica e interactiva en **Vaadin Flow**, el monolito modular desacoplado en **Spring Boot**, la base de datos relacional **PostgreSQL** y el almacenamiento de expedientes en **AWS S3**.

```mermaid
flowchart TB
    subgraph Usuarios["Usuarios"]
        uPub["<b>Usuario Público</b><br/>[Person]<br/>Front-Office"]
        uReg["<b>Usuario Registrado / Gestión</b><br/>[Person]<br/>Representante, Administrador, Jurado"]
    end

    subgraph Plataforma["Plataforma La Tramoya [Container Boundary]"]
        vaadinUi["<b>Interfaz Web Reactiva (Vaadin)</b><br/>[Container: Java, HTML/CSS, Vaadin Flow]<br/>Vistas Front-Office (archivo, cartelera) y Back-Office protegido (formularios de inscripción, panel de revisión y planillas del jurado)."]
        backendApp["<b>Aplicación Monolítica Modular</b><br/>[Container: Spring Boot, Java 21, Spring Security]<br/>Implementa la lógica del concurso, motor de sorteo, cómputo de puntuaciones, control de sesiones y orquestación transaccional."]
        db["<b>Base de Datos Relacional</b><br/>[Container: PostgreSQL]<br/>Almacena ediciones, agrupaciones, inscripciones, fases, sesiones, actuaciones, actas y desglose de puntuaciones."]
    end

    subgraph Cloud["Infraestructura Cloud"]
        s3["<b>AWS S3 Bucket</b><br/>[Software System]<br/>Almacenamiento de archivos PDF de inscripción"]
    end

    uPub -->|"Navega por la landing, buscador del archivo y cartelera de funciones<br/>[HTTPS]"| vaadinUi
    uReg -->|"Inicia sesión, gestiona inscripciones, realiza sorteos y califica en directo<br/>[HTTPS]"| vaadinUi

    vaadinUi -->|"Invoca servicios de aplicación y casos de uso de negocio<br/>[In-Process Java Calls / Spring Context]"| backendApp
    backendApp -->|"Lee y escribe datos transaccionales mediante JPA/Hibernate y Flyway<br/>[JDBC / TCP 5432]"| db
    backendApp -->|"Genera Presigned URLs y almacena documentos PDF adjuntos<br/>[AWS SDK v2 / HTTPS]"| s3
```

---

## 3. C4 Nivel 3: Diagrama de Componentes del Backend (Hitos 1 al 20)

Detalla los componentes modulares de Spring Boot y el flujo de comunicación interna y de dependencias hacia la capa de persistencia y servicios externos.

```mermaid
flowchart TB
    subgraph SpringApp["Contenedor de Aplicación (Spring Boot) [CONTAINER]"]
        direction TB

        secSvc["<b>Security & Auth Service</b><br/>[Component: Spring Security + BCrypt]<br/>Gestiona login, registro, sesiones HTTP y protección RBAC (Hitos 1, 2, 3)."]
        editionSvc["<b>Edition & Phase Service</b><br/>[Component: Spring Service]<br/>Ciclo de vida de ediciones, apertura de plazos, configuración de fases y cupos de pase (Hitos 4, 10)."]
        groupSvc["<b>Carnival Group Service</b><br/>[Component: Spring Service]<br/>Catálogo histórico y CRUD de agrupaciones y localidades (Hito 5)."]
        regSvc["<b>Registration Service</b><br/>[Component: Spring Service]<br/>Borradores de inscripción, validación de autorías, nómina de componentes y bandeja de revisión (Hitos 6, 7, 8, 9)."]
        docSvc["<b>Document Storage Service</b><br/>[Component: Spring Service + AWS SDK]<br/>Validación y subida de documentos PDF a S3 con URLs prefirmadas (Hito 13)."]
        drawSvc["<b>Draw & Scheduling Service</b><br/>[Component: Spring Service]<br/>Algoritmo de sorteo para preliminares, cabezas de serie y orden de sesión (Hito 14)."]
        sessionSvc["<b>Session Schedule Service</b><br/>[Component: Spring Service]<br/>Consulta de calendario y cartelera de funciones del Falla (Hito 15)."]
        jurySvc["<b>Jury Scoring Service</b><br/>[Component: Spring Service]<br/>Gestión de planillas ciegas por modalidad y registro de notas de vocales (Hito 16)."]
        scoreTally["<b>Score Tally & Penalty Engine</b><br/>[Component: Spring Service]<br/>Descarte de notas extremas, cálculo de penalizaciones por tiempo y agregados (Hito 17)."]
        verdictSvc["<b>Verdict Publication Service</b><br/>[Component: Spring Service]<br/>Cierre de fase, asignación de clasificados y publicación de veredicto oficial (Hito 18)."]
        archiveSvc["<b>Historical Archive Service</b><br/>[Component: Spring Service + JPA Spec]<br/>Buscador multi-criterio y fichas completas de palmarés y tipos sin exponer PII (Hitos 11, 19, 20)."]
        seederSvc["<b>Data Seeder Service</b><br/>[Component: Spring Component]<br/>Carga inicial de agrupaciones y ediciones históricas para pruebas y staging (Hito 12)."]

        repoLayer["<b>Capa de Repositorios (Data Access)</b><br/>[Component: Spring Data JPA Repositories]<br/>Acceso y persistencia tipada sobre el modelo de datos relacional."]
    end

    subgraph ExtStorage["Infraestructura Externa"]
        s3Ext["<b>AWS S3</b><br/>[Software System]"]
    end

    %% Relaciones de Colaboración de Negocio
    regSvc -->|"Verifica estado de plazos"| editionSvc
    regSvc -->|"Asocia inscripción a grupo"| groupSvc
    regSvc -->|"Adjunta expedientes PDF"| docSvc
    drawSvc -->|"Obtiene inscripciones aceptadas"| regSvc
    drawSvc -->|"Genera sesiones y actuaciones"| sessionSvc
    scoreTally -->|"Recoge planillas enviadas"| jurySvc
    verdictSvc -->|"Aplica totales y genera cortes de fase"| scoreTally
    archiveSvc -->|"Consulta fichas y palmarés"| groupSvc

    %% Conexiones a la Capa de Repositorios
    editionSvc --> repoLayer
    groupSvc --> repoLayer
    regSvc --> repoLayer
    sessionSvc --> repoLayer
    drawSvc --> repoLayer
    jurySvc --> repoLayer
    scoreTally --> repoLayer
    verdictSvc --> repoLayer
    archiveSvc --> repoLayer
    seederSvc --> repoLayer
    secSvc --> repoLayer

    %% Acceso Externo
    docSvc -->|"S3 SDK v2"| s3Ext
```

---

## 4. Trazabilidad por Hitos de Desarrollo (Hitos 1 al 20)

| Hito | Área Funcional | Componente Backend Responsable |
| :--- | :--- | :--- |
| **Hito 1** | Autenticación y Cuentas | `Security & Auth Service` |
| **Hito 2** | Gestión de Roles y Permisos (RBAC) | `Security & Auth Service` |
| **Hito 3** | Perfil de Usuario y Sesión | `Security & Auth Service` |
| **Hito 4** | Configuración de Edición COAC | `Edition & Phase Service` |
| **Hito 5** | Catálogo de Agrupaciones y Localidades | `Carnival Group Service` |
| **Hito 6** | Borrador de Inscripción Telemática | `Registration Service` |
| **Hito 7** | Registro de Autorías y Representantes | `Registration Service` |
| **Hito 8** | Registro de Nómina de Componentes | `Registration Service` |
| **Hito 9** | Bandeja Municipal de Revisión y Admisión | `Registration Service` |
| **Hito 10** | Configuración de Fases y Cupos de Pase | `Edition & Phase Service` |
| **Hito 11** | Consulta Pública de Agrupaciones Inscritas | `Historical Archive Service` |
| **Hito 12** | Carga de Datos Históricos (Data Seeding) | `Data Seeder Service` |
| **Hito 13** | Almacenamiento Seguro de Expedientes PDF | `Document Storage Service` (AWS S3) |
| **Hito 14** | Motor de Sorteo y Orden de Preliminares | `Draw & Scheduling Service` |
| **Hito 15** | Cartelera y Calendario del Falla | `Session Schedule Service` |
| **Hito 16** | Planilla Digital de Puntuaciones Ciegas | `Jury Scoring Service` |
| **Hito 17** | Motor de Cómputo de Medias y Penalizaciones | `Score Tally & Penalty Engine` |
| **Hito 18** | Cierre de Fases, Clasificados y Fallo Oficial | `Verdict Publication Service` |
| **Hito 19** | Buscador Avanzado del Archivo Histórico | `Historical Archive Service` |
| **Hito 20** | Fichas de Agrupaciones, Palmarés y Tipos (GDPR) | `Historical Archive Service` |
