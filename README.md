# SaludPublica-BI
Implementación de solución de BI para el caso de estudio de salud pública. Scripts .sql, datos de prueba, procesos ETL, dashboard con indicadores

## Estructura de la entrega
| Carpeta | Contenido |
| --- | --- |
| /01_oltp | Scripts DDL y de datos de prueba; capturas de la implementación |
| /02_dwh | Scripts DDL del almacén (staging y modelo dimensional); capturas |
| /03_etl | Procesos ETL (proyectos, scripts o transformaciones), bitácoras y reporte de calidad |
| /04_validacion | Consultas de reconciliación y sus resultados |
| /05_dashboard | Archivo del dashboard (o enlace de acceso) y capturas de cada vista |

## Descripción del caso y reglas de negocio
| Código | Regla de negocio |
| --- | --- |
| RN-01 | Especialidades. El hospital cubre: Cardiología, Cirugía, Dermatología, Endocrinología, Gastroenterología, Neurología, Pediatría, Psiquiatría, Radioterapia y Traumatología. |
| RN-02 | Áreas. Cada área dispone de un piso completo y está destinada a una única especialidad. Cada área tiene un médico jefe cuya especialidad es la cubierta en el área. |
| RN-03 | Camas. Cada cama pertenece a un área, con su piso y pasillo (ej.: la cama 0304 está en el área de Cardiología, pasillo 4 del piso 3). |
| RN-04 | Hospitalización. Un paciente ocupa una cama durante un período. Se registran la cantidad de días, los días cubiertos por el seguro, el costo diario y el estatus. Se considera la póliza del paciente (afiliación, cobertura de hospitalización y cantidad de días). |
| RN-05 | Médicos. Un médico tiene una especialidad principal y, en un momento dado, trabaja en una sola área del hospital. Puede registrarse experiencia adicional en otras especialidades. |
| RN-06 | Diagnósticos. Un diagnóstico tiene nombre y tipo, lo realiza un médico en una fecha determinada y tiene un costo asociado. Un mismo paciente puede recibir múltiples diagnósticos y todos deben almacenarse, lo que permite conocer la proporción de diagnósticos que posee. |
| RN-07 | Tratamientos. Un tratamiento se compone de medicinas (con nombre, presentación, posología completa y laboratorio proveedor). Lo aplica un médico sobre un paciente en un período dado, dura una cantidad de días, se administra en dosis diarias y representa un costo adicional para el paciente. |
| RN-08 | Efectos secundarios. Debe llevarse un control estricto de los efectos secundarios que un tratamiento pueda tener sobre un paciente. |
| RN-09 | Intervenciones. Una intervención tiene tipo y descripción. La práctica de un médico (o un equipo de varios médicos) sobre un paciente, en compañía de uno o varios miembros del personal sanitario. Tiene un nivel de riesgo, una duración, un gasto del hospital por uso de equipos médicos, honorarios del equipo y un costo para el paciente; además se considera la cobertura de la póliza. |
| RN-10 | Número de ingreso. Para intervenciones, diagnósticos y tratamientos es de vital importancia registrar el número de ingreso del paciente. |
| RN-11 | Facturación. Es un proceso automático que hoy no está respaldado en ninguna fuente de datos. Cada vez que se realiza un diagnóstico, se prescribe un tratamiento o se practica una intervención (servicios con costo en bolívares para el paciente) se emite una factura que detalla el tipo de servicio cobrado (diagnóstico, tratamiento o intervención). |
| RN-12 | Cliente de la factura. El cliente puede ser una persona o una compañía de seguros. Se crea una fila cuando el hospital emite y envía la factura; si corresponde a un seguro, se registra la compañía aseguradora primaria a la que se reenvió. |
| RN-13 | Seguimiento de cobro. Se requiere saber qué facturas han sido pagadas y cuáles no, el tiempo que demoran en pagarse y el estado actual de las pendientes, para obtener la relación ingresos–egresos del hospital (ingresos: facturas cobradas; egresos: gastos asociados a los servicios, como equipos y honorarios). |
| RN-14 | Pólizas. Un paciente puede tener más de una póliza (principal y secundaria), con la misma aseguradora o con una distinta. |

## Fuentes de datos

El proyecto parte de cuatro fuentes. Los archivos se entregan junto con este enunciado.

| Fuente | Archivo | Contenido | Observaciones |
| --- | --- | --- | --- |
| Base de datos transaccional (OLTP) | OLTP.sql | ESQUEMARELACIONAL.sql 23 tablas: geografía (ESTADO, CIUDAD), proveedores (TIPO_PROVEE, PROVEE), catálogos (ESPECIALIDAD, SX, ESTADO_CIVIL), personal (MEDICO, TIENE, AREA, TRABAJA, PERSONAL_SANITARIO), hospitalización (CAMA, OCUPA, PAC), diagnósticos (DIAGN, REALIZA), tratamientos (MEDICINA, TRATAMIENTO, APLICA, PRESCRIBE) e intervenciones (INTERVENCION, PRACTICA). | Es el modelo de partida. |
| Registro epidemiológico (TXT) | EPIDEMIOLOGIA.txt | Registro nacional de eventos epidemiológicos por estado: ESTADO, CANT_HAB, ENFERMEDAD, CANT_CASOS, SIT_ACTUAL (ALARMA, EXITO, CONTROLADO). | El archivo no trae fecha ni período. El estado debe conformarse con la geografía del OLTP. |
| Historias médicas (CSV) | HISTORIAS_MEDICAS.csv | CEDULA, EDAD, PESO ACTUAL, PESO IDEAL, TENSION, TIPO_SANGRE, FUMADOR, HIPERTENSO, ARTRITIS, OSTEOPOROSIS, DIABETES, PROB. RESPIRATORIOS, FECHA. Separador: punto y coma. | Un paciente puede tener más de un registro. No cambian con el tiempo: cédula, tipo de sangre, hipertenso, artritis, osteoporosis y diabetes. |
| Pólizas de seguro (CSV) | POLIZAS_DE_SEGUROS.csv | POLIZAS_DE_SEGUROS.csv CEDULA, EMPRESA, TITULAR, TIPO_POLIZA (PRINCIPAL/SECUNDARIA), HOSPITALIZACION, CIRUGIA, MATERNIDAD, RADIOGRAFIAS, EXAMENES, AMBULANCIA, COBERTURA, APROBADA. Separador: punto y coma. | Un paciente puede tener más de un registro, con la misma aseguradora o con otra (póliza principal y secundaria). |

Calidad de los datos. Los archivos pueden contener inconsistencias (ortografía, formatos numéricos, espacios sobrantes, valores no válidos, datos faltantes, claves sin correspondencia con el OLTP). Detectarlas, documentarlas y tratarlas forma parte del trabajo y se evalúa.

## Mínimo de datos
| Elemento | Volumen mínimo orientativo |
| --- | --- |
| Pacientes | 30, incluyendo los de las historias médicas y las pólizas |
| Médicos , áreas y personal sanitario | 10 médicos; un área por cada especialidad; 10 miembros del personal sanitario |
| Período de datos | Al menos 12 meses de servicios y facturación |
| Servicios y facturas | Al menos 100 diagnósticos, 100 prescripciones, 50 intervenciones y 200 facturas (con facturas pagadas y pendientes) |
| Hospitalizaciones | Al menos 40 ocupaciones de cama |