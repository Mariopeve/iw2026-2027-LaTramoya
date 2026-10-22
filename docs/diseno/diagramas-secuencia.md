# Diagramas de Secuencia del Sistema

Este documento recoge los diagramas de secuencia detallados en sintaxis **Mermaid** para los flujos de interacción clave del sistema **La Tramoya**, cubriendo la interacción entre la interfaz Vaadin, los servicios de aplicación `@Transactional`, los repositorios Spring Data JPA, entidades del dominio y los servicios de infraestructura externa (AWS S3 y PostgreSQL).

---

## 1. Tramitación Telemática de Inscripción (Representante Legal)

Refleja el flujo completo donde el representante legal de una agrupación rellena los datos, sube el archivo PDF mediante una URL prefirmada de AWS S3, y formaliza el envío ejecutando las validaciones de invariantes de negocio (no duplicidad de grupo en la edición, no incompatibilidad de componentes en la misma modalidad y transición de estado).

```mermaid
sequenceDiagram
    autonumber
    actor Rep as Representante Legal
    participant View as :RegistrationWizardView
    participant Svc as :RegistrationServiceImpl
    participant DocSvc as :DocumentStorageService
    participant RegRepo as :RegistrationRepository
    participant EdRepo as :EditionRepository
    participant S3 as AWS S3 Bucket
    participant DB as PostgreSQL

    Rep->>View: Rellena datos (autores, componentes, PDF) y pulsa "Enviar Inscripción"
    View->>DocSvc: generatePresignedUploadUrl(fileName, regId)
    DocSvc-->>View: presignedUrl, s3ObjectKey
    View->>S3: PUT expediente.pdf (mediante presignedUrl)
    S3-->>View: 200 OK

    View->>Svc: submitRegistration(registrationId, s3ObjectKey)
    activate Svc
    Svc->>EdRepo: findActiveEdition()
    EdRepo-->>Svc: edition (status: REGISTRATION_OPEN)

    rect rgb(255, 245, 230)
        Note over Svc, RegRepo: Validación de Invariantes de Negocio
        Svc->>RegRepo: existsByEditionIdAndGroupId(editionId, groupId)
        RegRepo-->>Svc: false (no duplicada)
        Svc->>RegRepo: validateNoMemberDuplicity(rosterList, editionId, modality)
        RegRepo-->>Svc: true (sin incompatibilidades de componentes)
    end

    Svc->>RegRepo: findById(registrationId)
    RegRepo-->>Svc: registrationEntity (estado: DRAFT)

    Note over Svc: Transición de estado:<br/>DRAFT -> SUBMITTED
    Svc->>Svc: registrationEntity.submit(s3ObjectKey)

    Svc->>RegRepo: save(registrationEntity)
    RegRepo->>DB: UPDATE registrations SET status='SUBMITTED', s3_key=... WHERE id=...
    DB-->>RegRepo: ok
    RegRepo-->>Svc: persistedEntity

    Svc-->>View: RegistrationSummaryDto (SUBMITTED)
    deactivate Svc

    View-->>Rep: Muestra confirmación con justificante de registro telemático
```

---

## 2. Emisión y Firma de Planilla Confidencial de Puntuación (Vocal del Jurado)

Describe el proceso en vivo en el Gran Teatro Falla cuando un vocal del jurado evalúa a una agrupación de su modalidad asignada, calculando el subtotal y bloqueando la planilla de forma inmutable.

```mermaid
sequenceDiagram
    autonumber
    actor Vocal as Vocal del Jurado
    participant View as :JuryScoringView
    participant Svc as :JuryScoringServiceImpl
    participant ScoreRepo as :ScoreSheetRepository
    participant PerfRepo as :PerformanceRepository
    participant DB as PostgreSQL

    Vocal->>View: Selecciona actuación en curso y califica criterios
    Vocal->>View: Pulsa "Firmar y Enviar Planilla"
    View->>Svc: submitJuryScoreSheet(performanceId, submissionDto)
    activate Svc

    Svc->>PerfRepo: findById(performanceId)
    PerfRepo-->>Svc: performanceEntity (Session: IN_PROGRESS)

    rect rgb(240, 248, 255)
        Note over Svc: Validación de Reglas del Jurado
        Svc->>Svc: checkModalityMatch(vocal.assignedModality, performance.group.modality)
        Svc->>ScoreRepo: existsByPerformanceIdAndJuryMemberId(perfId, vocal.id)
        ScoreRepo-->>Svc: false (primera entrega)
        Svc->>Svc: validateCriteriaRanges(submissionDto.items)
    end

    Note over Svc: Creación de ScoreSheet inmutable<br/>isSubmitted = true
    Svc->>ScoreRepo: save(scoreSheetEntity)
    ScoreRepo->>DB: INSERT INTO score_sheets (...) VALUES (...)
    DB-->>ScoreRepo: id generado
    ScoreRepo->>DB: INSERT INTO score_items (...) VALUES (...)
    DB-->>ScoreRepo: ok
    ScoreRepo-->>Svc: persistedScoreSheet

    Svc-->>View: ScoreSheetDto (LOCKED / SUBMITTED)
    deactivate Svc

    View-->>Vocal: Notifica recepción y bloquea formulario de puntuación
```

---

## 3. Cierre de Fase, Cómputo de Medias y Fallo Oficial (Presidente del Jurado)

Flujo de agregación de calificaciones al terminar una fase del COAC, con aplicación de penalizaciones de tiempo y descarte de notas extremas.

```mermaid
sequenceDiagram
    autonumber
    actor Pres as Presidente del Jurado
    participant View as :MunicipalReviewView / AdminView
    participant Svc as :ScoreTallyEngineServiceImpl
    participant PhaseRepo as :PhaseRepository
    participant ScoreRepo as :ScoreSheetRepository
    participant VerdictRepo as :OfficialVerdictRepository
    participant DB as PostgreSQL

    Pres->>View: Solicita "Cerrar Fase y Computar Puntuaciones"
    View->>Svc: closePhaseAndTally(phaseId)
    activate Svc

    Svc->>PhaseRepo: findById(phaseId)
    PhaseRepo-->>Svc: phaseEntity (isClosed: false)

    Svc->>ScoreRepo: findPendingScoreSheets(phaseId)
    ScoreRepo-->>Svc: emptyList (todas las planillas recibidas)

    rect rgb(255, 250, 240)
        Note over Svc: Motor de Cómputo de Calificaciones
        Svc->>Svc: discardExtremeScores() (elimina nota máx. y mín.)
        Svc->>Svc: computeAverageScorePerCriterion()
        Svc->>Svc: applyTimePenalties(performance.penaltyPoints)
        Svc->>Svc: rankPerformancesByModality()
    end

    alt Es Fase FINAL
        Svc->>VerdictRepo: saveAll(officialVerdicts)
        VerdictRepo->>DB: INSERT INTO official_verdicts (...) VALUES (...)
        DB-->>VerdictRepo: ok
    end

    Svc->>PhaseRepo: markAsClosed(phaseId)
    PhaseRepo->>DB: UPDATE phases SET is_closed = true WHERE id = phaseId
    DB-->>PhaseRepo: ok

    Svc-->>View: PhaseTallyResultDto (Clasificados y Premios)
    deactivate Svc

    View-->>Pres: Muestra acta oficial generada y publica resultados en Front-Office
```
