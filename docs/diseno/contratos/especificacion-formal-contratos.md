# Especificación Formal de Contratos de Operaciones

Este documento consolida la especificación formal de los contratos de operaciones de los servicios de aplicación del sistema **La Tramoya** (Hitos 1 al 20), definiendo signaturas, actores, precondiciones, postcondiciones, invariantes y excepciones.

---

## 1. Módulo de Seguridad y Autenticación (Hitos 1, 2 y 3)

### Operación: `registerUser`
- **Signatura:** `UserProfileDto registerUser(UserRegistrationDto request)`
- **Hito trazable:** `FEAT-02: Registro de usuarios y gestión de perfiles`
- **Actor:** Usuario anónimo (`ANONYMOUS`)
- **Descripción:** Registra un nuevo usuario en la plataforma validando identidad y asignando el rol base.
- **Precondiciones:**
  1. `request.email` no existe previamente en la tabla `persons` / `users`.
  2. `request.nationalId` (DNI/NIE) es válido según el algoritmo oficial español y no está duplicado.
  3. `request.password` cumple con las políticas de complejidad (mínimo 8 caracteres, al menos una mayúscula, un dígito y un carácter especial).
- **Postcondiciones:**
  1. Se crea y persiste una nueva entidad `Person` con el hash de contraseña generado mediante `BCryptPasswordEncoder`.
  2. Se asigna automáticamente el rol por defecto `GROUP_REPRESENTATIVE` o `PUBLIC_RESEARCHER`.
  3. Se emite un evento de dominio `UserRegisteredEvent` para notificación por correo.
  4. Retorna el DTO con el identificador generado sin exponer el hash de contraseña.
- **Excepciones:**
  - `EmailAlreadyExistsException`: Si el correo electrónico ya está registrado.
  - `InvalidNationalIdException`: Si el DNI/NIE es sintácticamente inválido o duplicado.
  - `WeakPasswordException`: Si la contraseña no satisface la política de seguridad.

---

## 2. Módulo de Inscripciones y Documentación (Hitos 6, 7, 8, 9 y 13)

### Operación: `submitRegistration`
- **Signatura:** `RegistrationSummaryDto submitRegistration(Long registrationId, String s3DocumentKey)`
- **Hito trazable:** `FEAT-06 / FEAT-07 / FEAT-08 / FEAT-13: Tramitación telemática de inscripciones`
- **Actor:** Representante legal (`GROUP_REPRESENTATIVE`) autenticado
- **Descripción:** Formaliza el envío telemático de una inscripción que estaba en borrador tras validar nómina, autorías y expediente en AWS S3.
- **Precondiciones:**
  1. La inscripción con `registrationId` existe y pertenece a una `Edition` en estado `REGISTRATION_OPEN`.
  2. El usuario autenticado es el propietario legítimo (`GROUP_REPRESENTATIVE`) de la inscripción.
  3. El estado actual de la entidad `Registration` es `DRAFT`.
  4. `s3DocumentKey` corresponde a un archivo PDF existente y verificado en el bucket S3.
  5. La inscripción tiene asignado como mínimo:
     - 1 Autor de letra (`AuthorRole.LYRICS`).
     - 1 Autor de música (`AuthorRole.MUSIC`).
     - 1 Director (`AuthorRole.DIRECTOR`).
  6. La nómina de componentes (`roster_members`) cumple los límites reglamentarios según la modalidad:
     - `CUARTETO`: Entre 3 y 5 componentes.
     - `CHIRIGOTA`: Entre 10 y 15 componentes.
     - `COMPARSA`: Entre 12 y 18 componentes.
     - `CORO`: Entre 12 y 45 componentes.
  7. **Incompatibilidad reglamentaria:** Ninguna persona de la nómina ni autores figura en otra inscripción de la **misma modalidad** en el mismo año.
  8. El grupo carnavalesco (`CarnivalGroup`) no tiene otra inscripción registrada para esta edición.
- **Postcondiciones:**
  1. `Registration.status` cambia de `DRAFT` a `SUBMITTED`.
  2. `Registration.submissionDate` se establece a la marca de tiempo actual del sistema (`LocalDateTime.now()`).
  3. `Registration.s3DocumentKey` queda vinculado de manera inmutable al expediente.
  4. Se genera un número correlativo de registro de entrada municipal.
  5. La inscripción queda bloqueada para edición por parte del representante.
- **Excepciones:**
  - `RegistrationPeriodClosedException`: Si la edición no admite inscripciones activas.
  - `IllegalRegistrationStateException`: Si la inscripción no está en estado `DRAFT`.
  - `IncompatibleRosterMemberException`: Si un componente o autor infringe la exclusividad de modalidad anual.
  - `InvalidRosterSizeException`: Si no se alcanzan o se superan los límites de integrantes por modalidad.
  - `MissingRequiredRolesException`: Si falta autor de letra, autor de música o director.
  - `DocumentNotUploadedException`: Si el archivo en AWS S3 no es accesible o no existe.

---

### Operación: `reviewRegistration`
- **Signatura:** `void reviewRegistration(Long registrationId, ReviewDecisionDto decision)`
- **Hito trazable:** `FEAT-09: Panel de validación de inscripciones para el Ayuntamiento`
- **Actor:** Administrador municipal (`MUNICIPAL_ADMIN`)
- **Descripción:** Aprueba o rechaza formalmente un expediente de inscripción presentado.
- **Precondiciones:**
  1. El usuario tiene el rol `MUNICIPAL_ADMIN`.
  2. La inscripción existe y su estado es `SUBMITTED` o `UNDER_REVIEW`.
  3. Si la decisión es `REJECT`, el campo `decision.rejectionReason` no puede ser nulo ni vacío.
- **Postcondiciones:**
  1. Si `decision.action == APPROVE`:
     - `Registration.status` cambia a `ACCEPTED`.
     - Se asigna número de censo oficial de participante.
  2. Si `decision.action == REJECT`:
     - `Registration.status` cambia a `REJECTED`.
     - `Registration.municipalNotes` guarda el motivo del rechazo para consulta del representante.
  3. Se registra entrada en la traza de auditoría administrativa con el ID del funcionario.
- **Excepciones:**
  - `RegistrationNotFoundException`: Si el ID no existe.
  - `InvalidStateTransitionException`: Si la inscripción ya estaba en estado final (`ACCEPTED` o `REJECTED`).
  - `MissingReasonException`: Si se intenta rechazar sin justificación motivada.

---

## 3. Módulo de Sorteo y Programación (Hito 14)

### Operación: `executePreliminaryDraw`
- **Signatura:** `DrawResultDto executePreliminaryDraw(Long editionId, DrawConfigurationDto config)`
- **Hito trazable:** `FEAT-14: Algoritmo de sorteo y generación de sesiones de Preliminares`
- **Actor:** Administrador municipal (`MUNICIPAL_ADMIN`)
- **Descripción:** Ejecuta el sorteo oficial del orden de actuación de la fase preliminar en el Gran Teatro Falla.
- **Precondiciones:**
  1. `Edition.status` es exactamente `REGISTRATION_CLOSED`.
  2. Existen al menos dos agrupaciones aceptadas (`ACCEPTED`) por cada modalidad inscrita.
  3. No existen sesiones generadas previamente para la fase `PRELIMINARES`.
  4. Los parámetros de configuración definen el número de funciones y franjas horarias válidas.
- **Postcondiciones:**
  1. Se generan entidades `Session` para cada fecha de preliminares.
  2. Se generan entidades `Performance` asignadas a cada sesión con `orderInSession` correlativo (1 a N).
  3. Las agrupaciones catalogadas como "cabeza de serie" quedan distribuidas evitando coincidencia múltiple en una misma función.
  4. Salvo excepciones por reglamento, no concurren agrupaciones consecutivas de la misma modalidad.
  5. `Edition.status` transiciona a `DRAW_COMPLETED`.
- **Excepciones:**
  - `InvalidEditionStatusException`: Si las inscripciones no han cerrado o el sorteo ya se había completado.
  - `InsufficientRegistrationsException`: Si no hay quórum de agrupaciones aceptadas para conformar las sesiones.
  - `DrawConfigurationException`: Si el número de sesiones no cuadra con el número total de grupos.

---

## 4. Módulo de Jurado y Calificaciones (Hitos 16, 17 y 18)

### Operación: `submitJuryScoreSheet`
- **Signatura:** `ScoreSheetDto submitJuryScoreSheet(Long performanceId, ScoreSheetSubmissionDto submission)`
- **Hito trazable:** `FEAT-16: Planilla confidencial de puntuación para vocales del Jurado`
- **Actor:** Vocal del jurado (`JURY_MEMBER`) autenticado
- **Descripción:** Registra las calificaciones individuales y ciegas de un vocal para una actuación en escena.
- **Precondiciones:**
  1. La `Performance` existe y su sesión asociada está en estado `IN_PROGRESS` o recién finalizada.
  2. El vocal autenticado tiene asignada la misma modalidad (`assignedModality`) a la que pertenece la agrupación evaluada.
  3. No existe previamente una `ScoreSheet` con `isSubmitted = true` para la tupla `(performanceId, juryMemberId)`.
  4. Las puntuaciones desglosadas por criterio (`ScoreItem`) se encuentran dentro de los intervalos reglamentarios oficiales (ej. Presentación: [0 - 10], Pasodobles/Tangos: [0 - 30], etc.).
- **Postcondiciones:**
  1. Se crea la entidad `ScoreSheet` con `isSubmitted = true` y marca temporal `submittedAt`.
  2. Se persisten los ítems desglosados en `score_items`.
  3. Se calcula y asigna el total bruto del acta (`totalScore`).
  4. La planilla queda bloqueada de forma inmutable; ningún otro vocal ni el propio autor puede alterar los valores.
- **Excepciones:**
  - `ModalityMismatchException`: Si el vocal intenta puntuar una actuación ajena a su modalidad asignada.
  - `ScoreSheetAlreadySubmittedException`: Si el vocal ya emitió y firmó su veredicto para dicha actuación.
  - `ScoreOutOfRangeException`: Si algún criterio supera el límite máximo o es inferior a cero.
  - `SessionNotInProgressException`: Si la sesión aún no ha comenzado o ya fue cerrada administrativamente.

---

### Operación: `registerPenalty`
- **Signatura:** `void registerPenalty(Long performanceId, BigDecimal excessMinutes)`
- **Hito trazable:** `FEAT-17: Motor de cálculo de puntuaciones y aplicación de penalizaciones`
- **Actor:** Presidente del jurado (`JURY_PRESIDENT`)
- **Descripción:** Aplica penalizaciones oficiales por tiempo excesivo sobre el escenario del Gran Teatro Falla.
- **Precondiciones:**
  1. El usuario tiene el rol `JURY_PRESIDENT`.
  2. La `Performance` existe y no está en estado cancelado o descalificado.
  3. `excessMinutes` es mayor que cero.
- **Postcondiciones:**
  1. Se calcula la penalización reglamentaria (ej. $N$ puntos por cada fracción de minuto excedido según las bases).
  2. Se actualiza el campo `Performance.penaltyPoints`.
  3. Queda registrado en el log del acta de la presidencia.
- **Excepciones:**
  - `PerformanceNotFoundException`: Si la actuación no existe.
  - `UnauthorizedJuryActionException`: Si el usuario no es presidente o secretario del jurado.

---

### Operación: `closePhaseAndTally`
- **Signatura:** `PhaseTallyResultDto closePhaseAndTally(Long phaseId)`
- **Hito trazable:** `FEAT-17 / FEAT-18: Cómputo de notas, pase de fase y publicación de veredicto`
- **Actor:** Presidente del jurado (`JURY_PRESIDENT`)
- **Descripción:** Consolida todas las actas de una fase, descarta notas extremas, aplica penalizaciones, determina qué agrupaciones superan el corte de clasificación y publica las actas.
- **Precondiciones:**
  1. La fase (`Phase`) tiene `isClosed = false`.
  2. Todas las actuaciones de la fase tienen sus sesiones en estado `COMPLETED`.
  3. Todas las planillas requeridas de los vocales de cada modalidad han sido entregadas (`isSubmitted = true`).
  4. Todas las incidencias y penalizaciones de tiempo han sido consignadas.
- **Postcondiciones:**
  1. Para cada actuación, se descartan la nota más alta y más baja por criterio según reglamento anual.
  2. Se suma la puntuación media resultante y se resta `Performance.penaltyPoints`.
  3. Si la fase tiene `scoresCarryOver == true`, se suma el acumulado de fases previas.
  4. Se ordenan las agrupaciones por puntuación descendente por cada modalidad.
  5. Se marcan como clasificadas las primeras $N$ agrupaciones según `Phase.maxAdvancingGroups`.
  6. Si la fase es `FINAL`, se generan y persisten las entidades `OfficialVerdict` asignando los premios (`FIRST_PRIZE`, `SECOND_PRIZE`, etc.).
  7. `Phase.isClosed` pasa a `true`.
  8. Las actas y clasificaciones pasan a ser visibles en el portal público de Front-Office.
- **Excepciones:**
  - `PendingScoreSheetsException`: Si aún quedan planillas de vocales sin enviar.
  - `PhaseAlreadyClosedException`: Si la fase ya fue consolidada y cerrada.
  - `InvalidPhaseSequenceException`: Si se intenta cerrar una fase sin haber concluido la fase anterior.

---

## 5. Módulo de Archivo Histórico (Hitos 11, 19 y 20)

### Operación: `searchHistoricalArchive`
- **Signatura:** `Page<ArchiveGroupSummaryDto> searchHistoricalArchive(ArchiveSearchCriteria criteria, Pageable pageable)`
- **Hito trazable:** `FEAT-19 / FEAT-20: Buscador multi-criterio y fichas de archivo histórico`
- **Actor:** Anónimo / Ciudadanía (`PUBLIC_RESEARCHER`)
- **Descripción:** Consulta paginada del catálogo histórico de agrupaciones combinando múltiples filtros dinámicos sin exponer datos personales protegidos.
- **Precondiciones:**
  1. Ninguna restricción de autenticación (Front-Office público).
  2. `pageable` no es nulo y respeta el tamaño máximo por página (máximo 50 registros por consulta para protección de desempeño).
- **Postcondiciones:**
  1. Ejecuta una consulta basada en `JpaSpecification` aplicando filtros opcionales:
     - Año de la edición (`year`).
     - Modalidad (`modality`).
     - Nombre de la agrupación (`officialName` o `costumeTheme`).
     - Nombre de autor o director (`authorName`).
     - Categoría de premio obtenido (`awardCategory`).
  2. **Garantía RGPD:** Los DTOs devueltos excluyen de forma absoluta campos sensibles de las personas (`nationalId`, `phone`, `email`, `voiceNumber`).
  3. Devuelve los resultados paginados con metadatos de total de páginas y registros.
- **Excepciones:**
  - `InvalidPageSizeException`: Si el tamaño de página solicitado supera el límite permitido.
