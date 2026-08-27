# ADR-0001: Lanzadores de modelo autocontenidos

- Estado: aceptado
- Fecha: 2026-08-07

## Contexto

Los lanzadores `.cmd` delegaban en `Start-Llm.ps1`, que combinaba valores de
runtime, modelo y perfil desde varios manifiestos. El diseño evitaba duplicación,
pero impedía conocer el comando efectivo inspeccionando el acceso directo de un
modelo. Modificar un perfil requería entender la precedencia de tres capas.

## Opciones consideradas

1. Mantener manifiestos heredados y el motor común. Optimiza DRY y cambios
   globales, pero conserva la opacidad.
2. Declarar todos los argumentos en cada `.cmd` y reutilizar un helper solo para
   proceso, PID y logs. Mejora visibilidad, pero mantiene una dependencia común.
3. Invocar `llama-server.exe` directamente desde cada `.cmd`. Maximiza
   transparencia y edición local a cambio de duplicación.

## Decisión

Adoptar la tercera opción. Cada perfil materializa runtime, modelo y todos sus
flags en un único `.cmd`. Los manifiestos se limitan a metadatos de catálogo,
descarga e integridad. `Test-Llm.ps1` valida los lanzadores, pero no participa
en la ejecución normal.

Se relaja deliberadamente DRY para la configuración de lanzamiento. Cada archivo
mantiene una única responsabilidad: describir y ejecutar un perfil observable.

## Consecuencias

- Un usuario puede inspeccionar y editar el comando efectivo en un solo archivo.
- Las rutas y valores no dependen de precedencia ni valores heredados.
- Los cambios globales deben aplicarse y validar todos los perfiles del catálogo.
- Se retiran el PID gestionado, el arranque en segundo plano y las
  sobrescrituras genéricas.
- La parada interactiva se realiza con `Ctrl+C`.
- Los nombres de grupo de argumentos son un contrato interno de
  `Test-Llm.ps1`.
