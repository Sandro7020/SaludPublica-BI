# Plan de generación de datos de prueba

> **Estado:** Fases 1 a 5 completadas (DDL extendido, catálogos/maestros, pólizas, ingresos y servicios cargados). Fases 6 a 8 pendientes.
>
> **Documento relacionado:** [Cambios al OLTP](cambios_oltp.md)

## 1. Objetivo

Generar un conjunto de datos de prueba para el OLTP que:

- Cumpla el mínimo definido en el README.
- Cubra al menos 12 meses de servicios y facturación.
- Sea coherente entre pacientes, ingresos, camas, médicos, especialidades, pólizas y facturas.
- Permita ejecutar los procesos ETL y construir el modelo dimensional sin datos huérfanos ni contradicciones.
- Sea reproducible mediante un generador determinista.

## 2. Diagnóstico actual

### 2.1 Cumplimiento del mínimo

| Elemento | Mínimo | Actual en `oltp/datos_prueba/carga_datos.sql` | Estado |
|---|---:|---:|---|
| Pacientes | 30 | 40 (26 de los CSV + 14 adicionales) | ✅ |
| Médicos | 10 | 12 | ✅ |
| Áreas | 1 por especialidad (10) | 10 | ✅ |
| Personal sanitario | 10 | 12 | ✅ |
| Período | ≥12 meses | 2025-01-05 a 2025-05-13 (≈4,3 meses) | ❌ |
| Diagnósticos | 100 | 52 | ❌ faltan 48 |
| Prescripciones | 100 | 46 | ❌ faltan 54 |
| Intervenciones | 50 | 24 | ❌ faltan 26 |
| Facturas | 200 | 0 | ❌ no existen tablas ni datos |
| Hospitalizaciones | 40 | 33 | ❌ faltan 7 |

Los 26 pacientes de `HISTORIAS_MEDICAS.csv` y `POLIZAS_DE_SEGUROS.csv` están incluidos en `PAC` con las cédulas 20364201–20364226. Ese punto ya está resuelto.

### 2.2 Problemas de coherencia detectados

- **Servicios sin hospitalización:** 20364231, 20364232, 20364233, 20364235, 20364236, 20364237 y 20364239 tienen diagnósticos, prescripciones o intervenciones, pero no tienen una ocupación de cama asociada. Sus números de ingreso 5031–5039 no existen en `OCUPA`.
- **Hospitalizaciones activas vencidas:** 20364203, 20364220, 20364238 y 20364240 están marcadas `ACTIVA` aunque su período de internación ya terminó.
- **Área hospitalaria vs. diagnóstico:** 11 de 33 hospitalizaciones están en un área que no corresponde al diagnóstico principal. Ejemplos: 20364223 (artrosis) en Cardiología, 20364208/20364209 (psiquiatría) en Dermatología, 20364226 (migraña) en Cirugía.
- **Pediatría con adultos:** solo 20364240 tiene 16 años; 20364216 (33), 20364227 (35), 20364230 (26), 20364234 (19) y 20364238 (24) están en camas o tratamientos pediátricos.
- **Procedimientos fuera de especialidad:** el radioterapeuta 10000009 realiza extracción de tumor; el pediatra 10000007 realiza drenaje de absceso en un adulto; el cirujano 10000002 realiza cirugía de cataratas.
- **Un ingreso por paciente:** no hay reingresos ni múltiples admisiones por paciente.
- **Médico sin uso:** 10000012 no tiene ningún servicio asociado.
- **Tratamiento sin medicina:** `TRATAMIENTO 12` (manejo neurológico) no tiene medicina asociada en `APLICA`.
- **Distribución temporal:** todos los servicios están concentrados entre enero y mayo de 2025.

### 2.3 Problemas de calidad en las fuentes

- `POLIZAS_DE_SEGUROS.csv`: espacios sobrantes (`"NO "`), valor `NI` en ambulancia, cobertura con formato `10.000`, una sola póliza por paciente, sin fechas ni días de cobertura y sin pólizas para 20364227–20364240.
- `HISTORIAS_MEDICAS.csv`: campos clínicos vacíos desde 20364215; la carga actual solo usa cédula, edad y tipo de sangre; la edad se interpreta tomando 2014 como año de referencia; pesos y tensiones son repetitivos.
- `EPIDEMIOLOGIA.txt`: sin fecha/período; solo 7 de 15 estados; errores `FIEMBRE_AMARILLA`, `Chingunkunya`, `sucre`; separadores numéricos y de encabezado inconsistentes.

## 3. Decisiones adoptadas

| Tema | Decisión |
|---|---|
| Esquema | Extensión completa del OLTP: ingreso, pólizas, facturación, efectos secundarios y corrección de claves |
| Período | `2025-11-01` a `2026-10-31` |
| Fecha de corte | `2026-10-31` |
| Generación | Script Python determinista con semilla fija |
| Cobertura | Monto en bolívares, no porcentaje |
| Costos | Se reescalan para que la cobertura y el copago sean significativos |
| Facturación | Una factura por servicio |
| Datos existentes | Se regeneran las tablas transaccionales; no se parchea el bloque enero–mayo 2025 |
| Camas | Se mantienen las 26 actuales |
| Pacientes | Se mantienen 40; se reutilizan pacientes sintéticos para pediatría y otros perfiles |

## 4. Volumen objetivo

| Elemento | Objetivo |
|---|---:|
| Pacientes | 40 |
| Hospitalizaciones | 60 |
| Diagnósticos | 120 |
| Prescripciones | 120 |
| Intervenciones | 60 |
| Facturas | 300 |
| Efectos secundarios | 20 |
| Período | 12 meses |
| Facturas pagadas | ~60% |
| Facturas pendientes | ~25% |
| Facturas vencidas | ~15% |

La distribución mensual debe tener servicios y facturas en todos los meses del período. Se apunta a un promedio de 25 servicios por mes, con variaciones estacionales moderadas.

## 5. Costos y cobertura

Si `COBERTURA` es un monto en bolívares, los costos actuales son demasiado bajos: casi todos los servicios quedarían cubiertos al 100%. Por eso se reescalan los catálogos:

| Concepto | Rango propuesto |
|---|---:|
| Diagnóstico | 2.000 – 15.000 Bs |
| Tratamiento | 5.000 – 80.000 Bs |
| Intervención | 30.000 – 180.000 Bs |
| Costo diario de hospitalización | 1.200 – 4.000 Bs |
| Cobertura de póliza | 10.000 – 100.000 Bs |

Regla de facturación:

- Si la póliza está `APROBADA = SI` y cubre la categoría del servicio:
  - `monto_cubierto = min(costo_servicio, cobertura_poliza)`
- `monto_paciente = costo_servicio - monto_cubierto`
- Sin póliza, póliza no aprobada o categoría no cubierta:
  - `monto_cubierto = 0`
  - `monto_paciente = costo_servicio`

**Supuesto:** `COBERTURA` se interpreta como tope por servicio/evento, no como tope anual acumulado. Si se define como tope anual, el generador debe consumir la cobertura de cada póliza a lo largo del período.

## 6. Reglas de coherencia

Toda generación debe cumplir estas invariantes:

1. Todo diagnóstico, prescripción o intervención tiene un `NUMBER_INGRESO` válido en `INGRESO`.
2. El paciente del servicio coincide con el paciente del ingreso.
3. La fecha del servicio está dentro del período de internación.
4. El área del ingreso coincide con la especialidad del diagnóstico principal.
5. El médico tratante pertenece al área del ingreso y su especialidad es compatible con el servicio.
6. La edad y el sexo del paciente son compatibles con el diagnóstico, tratamiento o intervención.
7. Una cama no puede estar ocupada por dos pacientes en fechas superpuestas.
8. Un paciente no puede estar en dos camas simultáneamente.
9. `DIAS_CUBIERTOS_SEGURO` no puede superar los días de internación ni los días de cobertura de la póliza.
10. Cada factura corresponde a un servicio y tiene una sola línea de detalle.
11. `MONTO_CUBIERTO + MONTO_PACIENTE = MONTO_TOTAL`.
12. Una factura pagada tiene `F_PAGO` y `MONTO_PAGADO`; una pendiente o vencida no tiene fecha de pago.
13. No se repiten claves naturales de servicios dentro del mismo ingreso y fecha.
14. Todos los pacientes, médicos, áreas, camas, pólizas y aseguradoras referenciados existen.
15. Las hospitalizaciones marcadas `ACTIVA` son solo las que siguen internadas al `2026-10-31`.

## 7. Fases de generación

### Fase 0 — Convenciones

**Objetivo:** congelar reglas antes de generar datos.

**Actividades:**

- Fijar período `2025-11-01`–`2026-10-31` y fecha de corte `2026-10-31`.
- Definir rangos de identificadores: pacientes 20364201–20364240, ingresos 5001–5060, facturas 1–300.
- Definir la moneda, precisión decimal y regla de cobertura.
- Definir el mapeo servicio → categoría de póliza:
  - Diagnóstico → `EXAMENES` o `RADIOGRAFIAS`.
  - Tratamiento → `HOSPITALIZACION`.
  - Intervención → `CIRUGIA`.
- Documentar que `APLICA` sigue siendo la composición estándar medicina–tratamiento; la duración y dosis por paciente se guardan en `PRESCRIBE`.

**Salida:** sección de convenciones en este documento y en `docs/cambios_oltp.md`.

**Criterio de aceptación:** no quedan decisiones ambiguas sobre fechas, montos, cobertura o claves.

### Fase 1 — DDL extendido ✅

**Estado:** completada el 2026-11-19. `oltp/ddl/OLTP.sql` fue reescrito como fuente única del esquema.

**Objetivo:** agregar las entidades y columnas que faltan para representar las reglas de negocio.

**Actividades realizadas:**

- Se crearon `INGRESO`, `ASEGURADORA`, `POLIZA`, `TIPO_SERVICIO`, `ESTADO_FACTURA`, `FACTURA`, `FACTURA_DETALLE` y `EFECTO_SECUNDARIO_PACIENTE`.
- Se agregó `NUMBER_INGRESO` a `OCUPA`, `REALIZA`, `PRESCRIBE` y `PRACTICA`.
- Se agregaron `ID_REALIZA`, `ID_PRESCRIPCION` e `ID_PRACTICA` como claves sustitutas (`INTEGER GENERATED BY DEFAULT AS IDENTITY`).
- Se agregaron `F_INICIO`, `F_FIN`, `CANT_DIAS` y `DOSIS_DIARIA` a `PRESCRIBE`.
- Se agregó `ID_POLIZA` a `OCUPA`.
- Se corrigieron las PK y se agregaron restricciones e índices.
- Se usaron FKs compuestas para alinear paciente, ingreso, póliza y aseguradora.
- Se agregaron índices únicos parciales: una póliza principal por paciente y una factura por servicio.

**Verificación:**

- El DDL completo cargó dos veces seguidas sin errores sobre PostgreSQL 18.
- Resultado: 31 tablas y 48 claves foráneas.
- Smoke test transaccional: se rechazaron montos incoherentes, servicios con paciente distinto al ingreso, dos pólizas principales y detalles con dos servicios.

**Criterio de aceptación:** cumplido. El DDL carga sin errores y todas las FKs nuevas son válidas.

> **Nota:** hasta completar las Fases 2 a 7, `oltp/datos_prueba/carga_datos.sql` no es compatible con el DDL nuevo (no envía `NUMBER_INGRESO` y no llena las tablas de facturación). No debe ejecutarse contra este esquema.

**Detalle:** ver [Cambios al OLTP](cambios_oltp.md).

### Fase 2 — Catálogos y maestros ✅

**Estado:** completada el 2026-11-19.

**Objetivo:** dejar lista la base de entidades y ajustar los costos.

**Archivos creados:**

- `oltp/datos_prueba/01_catalogos.sql`
- `oltp/datos_prueba/02_maestros.sql`

**Actividades realizadas:**

- Se mantuvieron geografía, sexo, estado civil, especialidades y proveedores.
- Se agregaron 7 aseguradoras normalizadas desde el CSV: `QUALITAS`, `CONSTITUCION`, `VENEZOLANA`, `MERCANTIL`, `CARACAS`, `SANITAS` y `RESCARVEN`.
- Se agregaron los catálogos `TIPO_SERVICIO` (`DIAGNOSTICO`, `TRATAMIENTO`, `INTERVENCION`) y `ESTADO_FACTURA` (`PAGADA`, `PENDIENTE`, `VENCIDA`).
- Se corrigió el tratamiento 12 (`MANEJO NEUROLOGICO`) agregando la medicina 16 (`CARBAMAZEPINA`) en `APLICA`.
- Se reescalaron los costos:
  - Diagnósticos: 3.500–15.000 Bs.
  - Tratamientos: 9.000–78.000 Bs.
- El costo diario de `OCUPA` y los costos de `PRACTICA` se asignan al generar esas filas en las Fases 4 y 5.
- Se mantuvieron 40 pacientes.
- Se ajustaron las fechas de nacimiento de 20364227, 20364230, 20364234, 20364238 y 20364240 para que tengan entre 10 y 17 años al corte; los cinco quedaron `SOLTERO`.
- Se mantuvieron los perfiles de maternidad, oncología y traumatología definidos en el plan.
- Se alinearon las funciones del personal sanitario con su área.
- Se mantuvieron las 26 camas actuales.
- El médico 10000012 quedó activo en el área de Pediatría.
- Los catálogos y maestros se cargan con SQL curado; el generador determinista se reserva para las fases transaccionales 4–6.
- En la Fase 4 se agregaron los diagnósticos 16–19 para cubrir Cirugía/Obstetricia y Radioterapia.
- En la Fase 5 se agregaron los diagnósticos 20–22 (angina, psoriasis e infección urinaria en el embarazo) y las intervenciones 11–15 (cateterismo, bomba de insulina, bloqueo nervioso, nebulización y electroconvulsivoterapia). El catálogo final tiene 22 diagnósticos y 15 intervenciones.

**Verificación:**

- 40 pacientes, 12 médicos, 10 áreas, 26 camas y 12 miembros del personal.
- 7 aseguradoras, 3 tipos de servicio y 3 estados de factura.
- 22 diagnósticos (15 originales + 4 de la Fase 4 + 3 de la Fase 5).
- 15 intervenciones (10 originales + 5 de la Fase 5).
- 0 jefes de área con especialidad distinta a la del área.
- 0 médicos sin área asignada.
- Todas las áreas tienen al menos 2 camas.
- El tratamiento 12 tiene una medicina asociada.
- Los scripts `01` y `02` se ejecutaron dos veces seguidas sin errores.

**Criterio de aceptación:** cumplido. Los conteos son correctos, los jefes de área coinciden con su especialidad y no hay FKs huérfanas.

### Fase 3 — Pólizas ✅

**Estado:** completada el 2026-11-19.

**Objetivo:** representar la cobertura real de los pacientes y ejercitar RN-14.

**Archivo creado:** `oltp/datos_prueba/03_polizas.sql`.

`ASEGURADORA` ya quedó cargada en la Fase 2; esta fase agrega únicamente las pólizas y reutiliza ese catálogo.

**Actividades realizadas:**

- Se cargaron las 26 pólizas de `POLIZAS_DE_SEGUROS.csv` y se ignoraron las 4 filas vacías.
- Se normalizaron `'SI '` / `'NO '` a booleanos y `NI` a `FALSE` en `AMBULANCIA`.
- `COBERTURA` pasó de `10.000` a `10000.00`; todas quedaron entre 10.000 y 100.000 Bs.
- Las 13 pólizas que el CSV traía como `SECUNDARIA` y eran la única del paciente se promovieron a `PRINCIPAL`, para no dejar pacientes sin póliza principal.
- Se agregaron 8 pólizas secundarias a 20364201, 20364202, 20364204, 20364207, 20364213, 20364217, 20364220 y 20364226. Cada una usa una aseguradora distinta y cubre al menos una categoría que la principal no cubre.
- Se agregaron 8 pólizas principales a pacientes adicionales: 20364228, 20364229, 20364230, 20364232, 20364233, 20364235, 20364236 y 20364237.
- Quedaron 6 pacientes sin póliza (autopago): 20364227, 20364231, 20364234, 20364238, 20364239 y 20364240.
- Se definieron `F_DESDE`, `F_HASTA` y `DIAS_COBERTURA`. Todas las pólizas están vigentes durante el período; algunas tienen `F_HASTA NULL`.
- `DIAS_COBERTURA` es 0 cuando no cubre hospitalización y toma valores 3, 5, 10, 15 o 30 cuando sí la cubre.
- El script incluye un bloque `DO` de autovalidación y es reejecutable mediante `TRUNCATE ... CASCADE`.

**Verificación:**

- 42 pólizas: 34 principales y 8 secundarias.
- 34 pacientes con póliza (26 con una, 8 con dos) y 6 sin póliza.
- 0 pacientes con más de dos pólizas.
- 0 pacientes con más de una principal.
- 0 secundarias sin principal.
- 0 pólizas aprobadas sin categoría facturable.
- 0 pólizas fuera del período de servicios.
- 0 incoherencias entre `HOSPITALIZACION` y `DIAS_COBERTURA`.
- Las 8 secundarias usan una aseguradora distinta y complementan categorías de la principal.
- El script se ejecutó dos veces seguidas sin errores.

**Criterio de aceptación:** cumplido. Cada paciente tiene 0, 1 o 2 pólizas, como máximo una principal, no hay cédulas huérfanas y las aprobadas cubren al menos una categoría facturable.

### Fase 4 — Ingresos y ocupaciones ✅

**Estado:** completada el 2026-11-19.

**Objetivo:** generar la base de hospitalizaciones que soporta todos los servicios.

**Archivos creados:**

- `oltp/datos_prueba/generar_datos.py`
- `oltp/datos_prueba/04_ingresos_ocupaciones.sql`

**Actividades realizadas:**

- El generador determinista produce 60 ingresos numerados 5001–5060, distribuidos en 5 por mes durante los 12 meses.
- 25 pacientes tienen 1 ingreso, 10 tienen 2 y 5 tienen 3.
- Cada paciente tiene un área y un diagnóstico principal fijo; las 10 áreas quedaron cubiertas.
- Mapeo diagnóstico → área: 1→Cardiología; 2 y 10→Endocrinología; 3 y 11→Pediatría; 4→Dermatología; 5 y 12→Gastroenterología; 6 y 13→Neurología; 7 y 14→Psiquiatría; 8 y 9→Traumatología; 15, 18 y 19→Radioterapia; 16 y 17→Cirugía/Obstetricia.
- Se amplió `DIAGN` con 4 diagnósticos (16–19) para que Cirugía/Obstetricia y Radioterapia tengan diagnósticos compatibles: apendicitis aguda, embarazo a término, neoplasia de próstata y linfoma no Hodgkin.
- Las estancias duran entre 2 y 10 días.
- 56 ingresos quedaron `ALTA` y 4 quedaron `ACTIVA` al corte, con `F_ALTA` NULL y estancias iniciadas entre el 22 y el 28 de octubre de 2026; para las activas, `CANTIDAD_DIAS` son los días transcurridos hasta el corte (4–10).
- Cada ingreso tiene una sola ocupación; se usaron las 26 camas y no hay solapamientos de cama ni de paciente.
- La cama se elige entre las libres del área, priorizando la menos usada.
- La póliza efectiva de hospitalización es la principal si está aprobada y cubre hospitalización; si no, la secundaria. Si ninguna sirve, `ID_POLIZA` queda NULL y la cobertura es 0.
- `DIAS_CUBIERTOS_SEGURO` = `min(CANTIDAD_DIAS, DIAS_COBERTURA)` de la póliza efectiva.
- `COSTO_DIARIO` quedó entre 1.400 y 3.400 Bs, dentro del rango 1.200–4.000.
- El médico tratante se asigna por área y se registra en el generador para la Fase 5; el DDL de `INGRESO` no tiene columna de médico.
- El SQL incluye autovalidación y es reejecutable mediante `TRUNCATE ... CASCADE`.

**Verificación:**

- 60 ingresos y 60 ocupaciones.
- 40 pacientes con ingreso; 25 con 1, 10 con 2 y 5 con 3.
- 5 ingresos por cada mes del período.
- Las 10 áreas usadas y las 26 camas usadas.
- 4 estancias `ACTIVA` al 2026-10-31; 56 `ALTA`.
- 0 solapamientos de cama.
- 0 pacientes en dos camas simultáneas.
- 0 ingresos fuera del período.
- 0 altas fuera del período.
- 0 estancias `ACTIVA` terminadas antes del corte.
- 0 incoherencias de paciente, área o cama.
- 0 coberturas mayores que los días de internación.
- 0 costos diarios fuera de rango.
- El generador produce siempre el mismo archivo y el script se ejecutó dos veces seguidas sin errores.

**Criterio de aceptación:** cumplido. Hay 60 hospitalizaciones, sin solapamientos, todas dentro del período, con área, cama y póliza coherentes; solo las 4 estancias abiertas al corte quedaron `ACTIVA`.

### Fase 5 — Servicios ✅

**Estado:** completada el 2026-11-19.

**Objetivo:** generar los servicios clínicos vinculados a cada ingreso.

**Archivos creados:**

- `oltp/datos_prueba/05_servicios.sql`
- `oltp/datos_prueba/generar_datos.py` (extendido con la Fase 5)

**Actividades realizadas:**

- El generador produce 120 diagnósticos (`REALIZA`), 120 prescripciones (`PRESCRIBE`) y 60 intervenciones (`PRACTICA`).
- Cada uno de los 60 ingresos tiene exactamente 2 diagnósticos, 2 prescripciones y 1 intervención.
- El primer diagnóstico es el diagnóstico principal del perfil del paciente; el segundo se elige del par compatible con el área. El primer tratamiento se deriva del diagnóstico principal y el segundo del área.
- Se agregaron los diagnósticos 20–22 y las intervenciones 11–15 para que las 10 áreas tengan servicios compatibles.
- Distribución de diagnósticos/prescripciones por área: Cardiología 16/16, Cirugía 20/20, Dermatología 8/8, Endocrinología 14/14, Gastroenterología 14/14, Neurología 8/8, Pediatría 10/10, Psiquiatría 10/10, Radioterapia 8/8 y Traumatología 12/12.
- Los servicios usan el médico tratante del área del ingreso y, en las intervenciones, personal sanitario del área.
- Fechas: el primer diagnóstico y la primera prescripción se registran el día del ingreso; el segundo diagnóstico, la segunda prescripción y la intervención se registran al día siguiente, o el último día disponible en estancias de 2 días.
- En las estancias `ACTIVA`, las fechas llegan como máximo al corte del `2026-10-31`.
- `PRESCRIBE` completa `F_ELABORACION`, `F_INICIO`, `F_FIN`, `CANT_DIAS` y `DOSIS_DIARIA`; la dosis sale de la posología de la medicina asociada al tratamiento en `APLICA`.
- `PRACTICA` completa `NUMBER_INGRESO`, riesgo, duración, gasto de equipos, costo y honorario del equipo. El costo quedó entre 3.500 y 56.000 Bs.
- Sexo y edad: las pacientes de Cirugía/Obstetricia usan diagnósticos obstétricos; Radioterapia usa neoplasia de mama solo en mujeres, próstata solo en hombres y linfoma en ambos; Pediatría solo tiene pacientes menores de 18 años.
- El SQL incluye autovalidación y es reejecutable; `TRUNCATE ... CASCADE` limpia los servicios y las facturas dependientes.

**Verificación:**

- 120 diagnósticos, 120 prescripciones y 60 intervenciones.
- 60 ingresos, todos con exactamente 2 diagnósticos, 2 prescripciones y 1 intervención.
- 40 pacientes y 12 médicos con servicios; las 10 áreas tienen servicios.
- 21 diagnósticos distintos usados; 12 tratamientos distintos y 11 intervenciones distintas.
- 0 diagnósticos fuera de la internación.
- 0 prescripciones fuera de la internación o incompletas.
- 0 intervenciones fuera de la internación.
- 0 servicios con un médico ajeno al área del ingreso.
- 0 intervenciones con personal de otra área.
- 0 pacientes adultos en Pediatría.
- 0 diagnósticos con sexo incompatible.
- 0 duplicados de clave natural.
- 0 servicios con paciente incoherente respecto del ingreso.
- 0 intervenciones con gasto de equipos u honorarios mayores que el costo.
- El generador produce siempre los mismos archivos; `05` se ejecutó dos veces seguidas y la secuencia completa dos veces sin errores.

**Criterio de aceptación:** cumplido. Hay 120 diagnósticos, 120 prescripciones y 60 intervenciones; todos tienen ingreso válido, fechas dentro de la internación, médico y personal del área, servicios compatibles con la especialidad, la edad y el sexo, y ninguna clave natural duplicada.

### Fase 6 — Facturación

**Objetivo:** generar una factura por cada servicio y su seguimiento de cobro.

**Actividades:**

- Generar 300 facturas, una por servicio.
- Fecha de emisión = fecha del servicio.
- Fecha de vencimiento = emisión + 30 días.
- Monto total = costo del diagnóstico, tratamiento o intervención.
- Aplicar la cobertura de la póliza principal; si no cubre, intentar la secundaria.
- Registrar la aseguradora primaria efectivamente usada.
- Distribuir estados:
  - ~60% pagadas, con pago entre 5 y 90 días después de la emisión y `F_PAGO <= 2026-10-31`.
  - ~25% pendientes: impagas, emitidas entre agosto y octubre de 2026 (cobro reciente).
  - ~15% vencidas: impagas, emitidas antes de agosto de 2026 (mora mayor a 60 días).
- Si la fecha de pago calculada cae después del corte, la factura no se marca pagada: queda pendiente.
- Asegurar que las facturas pagadas tengan fecha y monto de pago.

**Salida:** `FACTURA` y `FACTURA_DETALLE` cargadas.

**Criterio de aceptación:** ≥200 facturas; una factura por servicio; `MONTO_CUBIERTO + MONTO_PACIENTE = MONTO_TOTAL`; las pagadas tienen `F_PAGO`; las pendientes/vencidas no; los estados y vencimientos son coherentes con el corte.

### Fase 7 — Efectos secundarios

**Objetivo:** cubrir RN-08.

**Actividades:**

- Generar 20 registros de efectos secundarios asociados a prescripciones.
- Fecha dentro del período de la prescripción.
- Descripción y gravedad (`LEVE`, `MODERADO`, `GRAVE`).

**Salida:** `EFECTO_SECUNDARIO_PACIENTE` cargada.

**Criterio de aceptación:** todos los efectos referencian una prescripción válida y una fecha coherente.

### Fase 8 — Validación y documentación

**Objetivo:** demostrar que el conjunto cumple el mínimo y las reglas.

**Actividades:**

- Crear `validacion/validar_minimos.sql` con conteos y aserciones.
- Crear `docs/calidad_datos.md` con los problemas de las fuentes y las decisiones de limpieza.
- Ejecutar la carga completa en PostgreSQL con `ON_ERROR_STOP`.
- Verificar que el ETL pueda poblar `fact_facturacion`, `fact_diagnostico`, `fact_tratamiento`, `fact_intervencion` y las dimensiones.
- Verificar que la carga sea reejecutable.

**Salida:** script de validación y documentación de calidad.

**Criterio de aceptación:** todas las validaciones pasan y el ETL no encuentra claves huérfanas.

## 8. Validaciones mínimas

El script de validación debe comprobar, como mínimo:

| Validación | Condición |
|---|---|
| Pacientes | `COUNT(PAC) >= 30` |
| Médicos | `COUNT(MEDICO) >= 10` |
| Áreas | `COUNT(AREA) = 10` y una por especialidad |
| Personal | `COUNT(PERSONAL_SANITARIO) >= 10` |
| Período | 12 meses calendario consecutivos (2025-11 a 2026-10); no exigir 365 días exactos |
| Diagnósticos | `COUNT(REALIZA) >= 100` |
| Prescripciones | `COUNT(PRESCRIBE) >= 100` |
| Intervenciones | `COUNT(PRACTICA) >= 50` |
| Facturas | `COUNT(FACTURA) >= 200` |
| Hospitalizaciones | `COUNT(INGRESO) >= 40` |
| Servicios sin ingreso | 0 filas |
| Fechas fuera de internación | 0 filas |
| Solapamientos de cama | 0 filas |
| Paciente en dos camas | 0 filas |
| Área vs. especialidad | 0 filas incompatibles |
| Facturas sin servicio | 0 filas |
| Diferencias de montos | 0 filas |
| Pagadas sin fecha de pago | 0 filas |
| Pendientes/vencidas con fecha de pago | 0 filas |
| Pólizas principales duplicadas | 0 pacientes con más de una principal |

## 9. Archivos previstos

La implementación generará o modificará:

- [x] `oltp/ddl/OLTP.sql` (Fase 1).
- [x] `oltp/datos_prueba/01_catalogos.sql` (Fase 2).
- [x] `oltp/datos_prueba/02_maestros.sql` (Fase 2).
- [x] `oltp/datos_prueba/generar_datos.py` (Fases 4–5; se extiende en la fase 6).
- [x] `oltp/datos_prueba/03_polizas.sql` (Fase 3).
- [x] `oltp/datos_prueba/04_ingresos_ocupaciones.sql` (Fase 4).
- [x] `oltp/datos_prueba/05_servicios.sql` (Fase 5).
- [ ] `oltp/datos_prueba/06_facturacion.sql`.
- [ ] `oltp/datos_prueba/07_efectos_secundarios.sql`.
- [ ] `validacion/validar_minimos.sql`.
- [ ] `docs/calidad_datos.md`.

El generador puede emitir un único `carga_datos.sql` con secciones equivalentes; la separación por fases es para poder validar paso a paso.

## 10. Supuestos y riesgos

- **Cobertura por servicio:** se asume tope por servicio/evento. Si se define como tope anual, hay que acumular consumo por póliza.
- **Una factura por servicio:** no se agrupan servicios en una misma factura.
- **Póliza principal y secundaria:** se usa la principal; la secundaria solo si la principal no está aprobada o no cubre la categoría. La factura registra la aseguradora primaria usada.
- **Hospitalización no facturada:** RN-11 solo menciona diagnósticos, tratamientos e intervenciones. El costo diario queda en `OCUPA` para análisis.
- **Sin servicios ambulatorios:** todos los servicios tienen ingreso.
- **Equipos de intervención:** los datos de prueba usan un médico y un miembro del personal por práctica. La extensión para equipos múltiples queda documentada como mejora opcional.
- **Pacientes sintéticos:** se cambian fechas de nacimiento de 20364227–20364240 para cubrir pediatría y otros perfiles; no se agregan pacientes.
- **Camas:** se mantienen las 26 actuales.
- **Datos históricos:** las historias médicas siguen siendo de 2014; no se reinterpretan como parte del período de servicios.

## 11. Próximo paso

Las Fases 1 a 5 ya están implementadas. El siguiente paso es la **Fase 6 — Facturación**: generar 300 facturas (una por servicio), aplicar la cobertura de la póliza efectiva y distribuir los estados pagada, pendiente y vencida con fechas coherentes con el corte del `2026-10-31`. Después se avanza en el orden de las fases, validando cada una antes de pasar a la siguiente.
