# Calidad de datos

> **Documento relacionado:** [Plan de generación de datos](plan_generacion_datos.md) · [Cambios al OLTP](cambios_oltp.md)
>
> **Estado:** cerrado en la Fase 8 (2026-11-21). El script [`validacion/validar_minimos.sql`](../validacion/validar_minimos.sql) verifica sobre la base cargada todas las condiciones que se describen aquí.

## 1. Alcance

El conjunto de datos de prueba se construyó a partir de cuatro fuentes:

| Fuente | Archivo | Uso |
|---|---|---|
| Modelo transaccional original | `oltp/ddl/OLTP.sql` | Esquema base; se extendió en la Fase 1 |
| Registro epidemiológico | `oltp/datos_prueba/EPIDEMIOLOGIA.txt` | `dwh.dim_registro_epidemiologico` (tabla aislada) |
| Historias médicas | `oltp/datos_prueba/HISTORIAS_MEDICAS.csv` | Datos clínicos de `dwh.dim_historia_medica` y parte de `dim_paciente` |
| Pólizas de seguro | `oltp/datos_prueba/POLIZAS_DE_SEGUROS.csv` | `OLTP.POLIZA` y `dwh.dim_poliza` |

Las tablas transaccionales (ingresos, ocupaciones, servicios, facturación y efectos secundarios) se regeneraron de forma determinista con `oltp/datos_prueba/generar_datos.py`. Los catálogos y maestros se cargaron con SQL curado (`01`–`03`).

## 2. Resumen de problemas y tratamiento

| # | Fuente | Problema | Tratamiento | Verificación |
|---|---|---|---|---|
| 1 | OLTP original | 7 servicios sin hospitalización (ingresos 5031–5039 inexistentes) | Se regeneraron todos los servicios a partir de ingresos reales | 0 servicios sin ingreso |
| 2 | OLTP original | 4 hospitalizaciones `ACTIVA` con internación terminada | Solo quedan `ACTIVA` las 4 estancias abiertas al corte | Estatus coherente con `F_ALTA` |
| 3 | OLTP original | 11 de 33 ingresos en un área incompatible con el diagnóstico | Cada paciente tiene área y diagnóstico principal fijos y compatibles | 0 médicos fuera del área del ingreso; jefes con la especialidad del área |
| 4 | OLTP original | Adultos en camas o tratamientos pediátricos | Se ajustaron las fechas de nacimiento de 20364227, 20364230, 20364234, 20364238 y 20364240 | 0 adultos internados en Pediatría |
| 5 | OLTP original | Procedimientos fuera de la especialidad del médico | El médico de cada servicio se asigna por área del ingreso | 0 servicios con médico fuera del área |
| 6 | OLTP original | Un solo ingreso por paciente | 25 pacientes con 1 ingreso, 10 con 2 y 5 con 3 | 60 ingresos, 0 solapamientos |
| 7 | OLTP original | Médico 10000012 sin servicios | Quedó activo en Pediatría y participa en la generación | 0 médicos sin área |
| 8 | OLTP original | Tratamiento 12 sin medicina en `APLICA` | Se agregó la medicina 16 (Carbamazepina) | 0 tratamientos usados sin medicina |
| 9 | OLTP original | Servicios concentrados entre enero y mayo de 2025 | Distribución en los 12 meses del período | 12 meses consecutivos con datos |
| 10 | `POLIZAS_DE_SEGUROS.csv` | 4 filas completamente vacías | Se ignoraron | 42 pólizas cargadas, 0 filas vacías |
| 11 | `POLIZAS_DE_SEGUROS.csv` | Espacios sobrantes (`"NO "`, `"SI "`) | Se normalizaron a booleanos | 0 valores de texto en columnas booleanas |
| 12 | `POLIZAS_DE_SEGUROS.csv` | `NI` en `AMBULANCIA` | Se interpretó como `FALSE` | 0 valores inválidos |
| 13 | `POLIZAS_DE_SEGUROS.csv` | Cobertura con formato `10.000` | Se convirtió a `10000.00` Bs | Montos entre 10.000 y 100.000 Bs |
| 14 | `POLIZAS_DE_SEGUROS.csv` | 13 pólizas `SECUNDARIA` eran la única del paciente | Se promovieron a `PRINCIPAL` | 0 pacientes con secundaria sin principal |
| 15 | `POLIZAS_DE_SEGUROS.csv` | Sin fechas ni días de cobertura | Se definieron `F_DESDE`, `F_HASTA` y `DIAS_COBERTURA` | 0 pólizas fuera del período de servicios |
| 16 | `POLIZAS_DE_SEGUROS.csv` | Una sola póliza por paciente; sin pólizas para 20364227–20364240 | Se agregaron 8 secundarias y 8 principales; 6 pacientes quedaron sin póliza (autopago) | 34 pacientes con póliza, 0 con más de una principal |
| 17 | `HISTORIAS_MEDICAS.csv` | Campos clínicos vacíos desde 20364215 | Se conservan como `NULL` en la dimensión de historia médica | Carga tolerante a nulos |
| 18 | `HISTORIAS_MEDICAS.csv` | La edad usa 2014 como año de referencia | Se usó solo cédula, edad y tipo de sangre para `PAC`; el resto queda en la dimensión | Fechas de nacimiento coherentes con la edad |
| 19 | `HISTORIAS_MEDICAS.csv` | Pesos y tensiones repetitivos | Se documentan como limitación; no se usan para reglas del OLTP | N/A |
| 20 | `EPIDEMIOLOGIA.txt` | Sin fecha ni período | Se carga en la tabla aislada `dim_registro_epidemiologico` | N/A (no interviene en hechos) |
| 21 | `EPIDEMIOLOGIA.txt` | Solo 7 estados | Se documenta como limitación de la fuente | N/A |
| 22 | `EPIDEMIOLOGIA.txt` | Errores `FIEMBRE_AMARILLA`, `Chingunkunya`, `sucre` | Se normalizan a `FIEBRE_AMARILLA`, `CHIKUNGUNYA`, `SUCRE` | N/A |
| 23 | `EPIDEMIOLOGIA.txt` | Separadores y encabezado inconsistentes | Se parsea por columnas y se normaliza el encabezado | N/A |

## 3. Detalle por fuente

### 3.1 OLTP original

El esquema de partida cumplía el mínimo de pacientes, médicos, áreas, personal y camas, pero no el de período, servicios ni facturación. Además tenía problemas de coherencia:

- Servicios sin ingreso: 20364231, 20364232, 20364233, 20364235, 20364236, 20364237 y 20364239 no tenían ocupación de cama.
- Estancias `ACTIVA` vencidas: 20364203, 20364220, 20364238 y 20364240.
- Área incompatible con el diagnóstico: 11 de 33 ingresos (por ejemplo, artrosis en Cardiología o psiquiatría en Dermatología).
- Pediatría con adultos: 20364216, 20364227, 20364230, 20364234 y 20364238.
- Procedimientos fuera de especialidad: radioterapia haciendo extracción de tumor, pediatría con drenaje de absceso en un adulto, cirugía con cataratas.
- Un único ingreso por paciente y un médico sin uso.
- Tratamiento 12 sin medicina asociada.
- Servicios concentrados entre enero y mayo de 2025.

**Decisión:** no se parcheó el bloque histórico. Se regeneraron las tablas transaccionales completas sobre el período `2025-11-01`–`2026-10-31`, conservando catálogos, maestros, áreas, camas y pacientes.

### 3.2 `POLIZAS_DE_SEGUROS.csv`

- **Filas vacías:** las 4 últimas filas solo contienen separadores `;`.
- **Booleanos sucios:** `"SI "`, `"NO "`, `"SI"`, `"NO"` y `NI`.
- **Formato numérico:** `COBERTURA` usa punto de miles (`10.000`, `100.000`).
- **Tipo de póliza:** 13 pacientes tenían solo una póliza marcada `SECUNDARIA`.
- **Cobertura incompleta:** el archivo no trae fechas, días de cobertura ni pólizas para todos los pacientes.

**Tratamiento aplicado:**

1. Se normalizaron booleanos y se convirtió `NI` a `FALSE`.
2. Se interpretó `COBERTURA` como monto en bolívares.
3. Las 13 pólizas únicas `SECUNDARIA` se promovieron a `PRINCIPAL`.
4. Se agregaron 8 pólizas secundarias a 20364201, 20364202, 20364204, 20364207, 20364213, 20364217, 20364220 y 20364226, cada una con una aseguradora distinta y cubriendo categorías que la principal no cubre.
5. Se agregaron 8 pólizas principales a 20364228, 20364229, 20364230, 20364232, 20364233, 20364235, 20364236 y 20364237.
6. Se definieron `F_DESDE`, `F_HASTA` y `DIAS_COBERTURA`. `DIAS_COBERTURA` es 0 cuando la póliza no cubre hospitalización y toma valores 3, 5, 10, 15 o 30 cuando sí la cubre.
7. Los 6 pacientes sin póliza (20364227, 20364231, 20364234, 20364238, 20364239 y 20364240) se facturan como autopago.

**Resultado:** 42 pólizas (34 principales y 8 secundarias), 34 pacientes con póliza y 6 sin póliza.

### 3.3 `HISTORIAS_MEDICAS.csv`

- 26 registros, uno por cédula (20364201–20364226).
- La columna `EDAD` se calculó tomando 2014 como año de referencia, no la fecha de atención.
- Los campos `PESO ACTUAL`, `PESO IDEAL`, `TENSION`, `FUMADOR`, `HIPERTENSO`, `ARTRITIS`, `OSTEOPOROSIS`, `DIABETES`, `PROB. RESPIRATORIOS` y `FECHA` están vacíos desde la cédula 20364215.
- Los pesos son una secuencia artificial (123–148) y las tensiones se repiten entre un conjunto reducido de patrones.

**Tratamiento aplicado:** para `OLTP.PAC` se usaron cédula, edad y tipo de sangre. Las fechas de nacimiento se recalcularon para que la edad sea coherente con el período de servicios y con los perfiles pediátricos, de maternidad y de oncología. Los campos clínicos quedan disponibles para `dwh.dim_historia_medica`; los vacíos se cargan como `NULL`.

### 3.4 `EPIDEMIOLOGIA.txt`

- El archivo no tiene fecha ni período; solo una foto de casos.
- Contiene solo 7 estados (Amazonas, Anzoátegui, Apure, Sucre, Vargas, Yaracuy y Zulia).
- Errores de escritura: `FIEMBRE_AMARILLA`, `Chingunkunya` (dos veces) y `sucre` en minúsculas.
- `Asma` y `EBOLA` conviven con distinto uso de mayúsculas.
- El encabezado mezcla tabulaciones y espacios; `CANT_HAB` usa punto de miles.

**Tratamiento aplicado:** se normalizan los nombres de estado y enfermedad (`FIEBRE_AMARILLA`, `CHIKUNGUNYA`, `SUCRE`), se convierte `CANT_HAB` a número y se carga en `dwh.dim_registro_epidemiologico`, que es una tabla aislada y no participa de las consultas de hechos. La ausencia de fecha se documenta como limitación: no se puede asociar a un período de análisis.

## 4. Decisiones de limpieza globales

| Tema | Decisión |
|---|---|
| Período | `2025-11-01` a `2026-10-31`; corte `2026-10-31` |
| Moneda | Bolívares (Bs), dos decimales |
| Cobertura | Tope por servicio/evento: `MONTO_CUBIERTO = LEAST(COBERTURA, MONTO_TOTAL)` |
| Póliza efectiva | Principal aprobada y vigente que cubra la categoría; si no, secundaria; si no, autopago |
| Facturación | Una factura por servicio y una línea de detalle por factura |
| Hospitalización | No se factura; su costo diario queda en `OCUPA` |
| Servicios | Todos tienen ingreso; no se generan servicios ambulatorios |
| Efectos secundarios | 20, dos por área, con fecha dentro de la prescripción y gravedad `LEVE`/`MODERADO`/`GRAVE` |
| Reejecución | Cada script trunca o recrea sus tablas; el generador es determinista |

## 5. Limitaciones conocidas

Estas limitaciones no impiden cumplir el mínimo ni poblar el modelo dimensional, pero deben tenerse presentes al interpretar los indicadores:

1. **Historias médicas de 2014.** No se reinterpretan como parte del período de servicios; se usan solo como atributos clínicos del paciente.
2. **Epidemiología sin período.** `dim_registro_epidemiologico` queda aislada y sin vínculo temporal con los hechos.
3. **Cobertura por servicio.** No se modela un tope anual acumulado; si se necesitara, habría que consumir la cobertura a lo largo del período.
4. **Fechas de póliza inferidas.** El CSV no las trae; se definieron para que las pólizas estén vigentes durante el período.
5. **`dim_personal_sanit`.** El OLTP no guarda sexo ni estado civil del personal sanitario; esas columnas quedarán `NULL` en el ETL.
6. **`dim_paciente`.** Las condiciones `hipertenso`, `artritis`, `osteoporosis` y `diabetes` provienen de `HISTORIAS_MEDICAS.csv`, no del OLTP.
7. **Equipos de intervención.** Cada práctica tiene un médico y un miembro del personal sanitario; el DWH solo soporta un personal secundario.
8. **Vencimientos posteriores al corte.** Las facturas pendientes pueden vencer hasta 30 días después del `2026-10-31` (`2026-11-28` como máximo), por lo que `dim_tiempo` debe cubrir ese rango.
9. **Pagos parciales.** `MONTO_PAGADO` puede ser menor que `MONTO_TOTAL`; nunca lo supera. Las facturas pendientes y vencidas no tienen fecha ni monto de pago.

## 6. Verificación

La validación integral se ejecuta con:

```bash
psql -v ON_ERROR_STOP=1 -d <base> -f validacion/validar_minimos.sql
```

El script comprueba mínimos, coherencia de ingresos y camas, facturación, pólizas, efectos secundarios y la resolubilidad de las claves que necesita el ETL. Si una condición falla, lanza una excepción y `psql` termina con código 3. Si todo pasa, imprime el resumen.

Resultado sobre la base cargada con el DDL y las fases `01`–`07`:

| Elemento | Valor | Referencia |
|---|---:|---|
| Pacientes | 40 | ≥ 30 |
| Médicos | 12 | ≥ 10 |
| Áreas / especialidades | 10 / 10 | = 10 |
| Personal sanitario | 12 | ≥ 10 |
| Camas | 26 | = 26 |
| Hospitalizaciones | 60 | ≥ 40 |
| Diagnósticos | 120 | ≥ 100 |
| Prescripciones | 120 | ≥ 100 |
| Intervenciones | 60 | ≥ 50 |
| Facturas / detalles | 300 / 300 | ≥ 200 |
| Pólizas | 42 | informativo |
| Efectos secundarios | 20 | = 20 |
| Facturas pagadas / pendientes / vencidas | 180 / 75 / 45 | informativo |

Verificaciones con resultado 0 filas:

- Servicios sin ingreso, con paciente distinto al del ingreso o fuera del período de internación.
- Solapamientos de cama y pacientes en dos camas simultáneas.
- Ocupaciones en camas de otra área y médicos fuera del área del ingreso.
- Jefes de área con especialidad distinta y adultos internados en Pediatría.
- Estatus de ocupación incoherente con el alta y estancias `ACTIVA` que no terminan en el corte.
- Días cubiertos por el seguro por encima de la estancia o de la póliza.
- Facturas sin detalle, con más de un detalle o con servicios facturados dos veces.
- Servicios sin factura y detalles sin exactamente un servicio.
- Diferencias entre el total de la factura y su detalle, o entre el detalle y el costo del catálogo.
- Coberturas por encima de la póliza o con póliza no aprobada, no vigente o que no cubre la categoría.
- Facturas con tipo de cliente incoherente y pacientes con más de una póliza principal.
- Facturas pagadas sin fecha/monto de pago, pendientes o vencidas con pago, y pagos posteriores al corte.
- Efectos fuera del período de la prescripción, sin descripción, con gravedad inválida o repetidos por prescripción.
- Áreas que no tienen exactamente dos efectos secundarios.
- Fechas fuera del rango de `dim_tiempo` y orígenes incompletos para las dimensiones y los hechos.
