# RF-01: Contrato de Operación - `registerUser`

* **Módulo:** Seguridad y Autenticación
* **Hito trazable:** `FEAT-02: Registro de usuarios y gestión de perfiles` (Hitos 1, 2, 3)
* **Servicio:** `SecurityService` (`com.aytocadiz.carnaval.service.SecurityService`)
* **Actor:** Usuario anónimo (`ANONYMOUS`)

---

## 1. Signatura
```java
UserProfileDto registerUser(UserRegistrationDto request);
```

---

## 2. Descripción
Registra un nuevo usuario en la plataforma validando identidad y asignando el rol base.

---

## 3. Precondiciones
1. `request.email` no existe previamente en la tabla `persons` / `users`.
2. `request.nationalId` (DNI/NIE) es válido según el algoritmo oficial español y no está duplicado.
3. `request.password` cumple con las políticas de complejidad (mínimo 8 caracteres, al menos una mayúscula, un dígito y un carácter especial).

---

## 4. Postcondiciones
1. Se crea y persiste una nueva entidad `Person` con el hash de contraseña generado mediante `BCryptPasswordEncoder`.
2. Se asigna automáticamente el rol por defecto `GROUP_REPRESENTATIVE` o `PUBLIC_RESEARCHER`.
3. Se emite un evento de dominio `UserRegisteredEvent` para notificación por correo.
4. Retorna el DTO `UserProfileDto` con el identificador generado sin exponer el hash de contraseña.

---

## 5. Excepciones
- `EmailAlreadyExistsException`: Si el correo electrónico ya está registrado.
- `InvalidNationalIdException`: Si el DNI/NIE es sintácticamente inválido o duplicado.
- `WeakPasswordException`: Si la contraseña no satisface la política de seguridad.
