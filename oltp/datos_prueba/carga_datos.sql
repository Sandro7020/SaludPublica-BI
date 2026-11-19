-- ============================================================================
-- OBSOLETO: cargador del esquema anterior a la Fase 1.
-- No funciona con el DDL extendido (INGRESO, POLIZA, FACTURA, etc.).
-- Usar en orden: 01_catalogos.sql, 02_maestros.sql y las fases siguientes.
-- ============================================================================
-- Datos de prueba para el esquema OLTP (PostgreSQL)
-- Esquema destino: "OLTP"
--
-- Contenido:
--   * 40 pacientes (PAC): los 26 de HISTORIAS_MEDICAS.csv / POLIZAS_DE_SEGUROS.csv
--     (cedulas 20364201-20364226) + 14 adicionales (20364227-20364240).
--     La fecha de nacimiento se deriva de la EDAD del CSV tomando 2014 como
--     anio de referencia (las historias fueron levantadas en 2014).
--   * Datos de prueba para el resto de las tablas del OLTP.
--
-- Notas de calidad de datos (se corrigen/omiten al cargar):
--   * POLIZAS_DE_SEGUROS.csv tiene espacios sobrantes y valores "NI" en
--     AMBULANCIA; el OLTP no posee tablas de polizas, por lo que ese archivo
--     solo se usa para incorporar las cedulas de los pacientes.
--   * HISTORIAS_MEDICAS.csv tiene campos vacios desde la cedula 20364215;
--     solo se usan CEDULA, EDAD y TIPO_SANGRE, que si estan completos.
-- ============================================================================

SET search_path TO "OLTP";

-- Limpieza para permitir re-ejecutar la carga sin violar FKs.
TRUNCATE TABLE
	"OLTP".OCUPA,
	"OLTP".REALIZA,
	"OLTP".PRACTICA,
	"OLTP".PRESCRIBE,
	"OLTP".APLICA,
	"OLTP".TRABAJA,
	"OLTP".TIENE,
	"OLTP".MEDICINA,
	"OLTP".TRATAMIENTO,
	"OLTP".DIAGN,
	"OLTP".INTERVENCION,
	"OLTP".CAMA,
	"OLTP".PERSONAL_SANITARIO,
	"OLTP".AREA,
	"OLTP".MEDICO,
	"OLTP".PAC,
	"OLTP".PROVEE,
	"OLTP".TIPO_PROVEE,
	"OLTP".CIUDAD,
	"OLTP".ESTADO,
	"OLTP".ESPECIALIDAD,
	"OLTP".SX,
	"OLTP".ESTADO_CIVIL
CASCADE;

-- ============================================================================
-- Catalogos: geografia
-- ============================================================================
INSERT INTO ESTADO (ID_ESTADO, NOMBRE) VALUES
	(1,  'AMAZONAS'),
	(2,  'ANZOATEGUI'),
	(3,  'APURE'),
	(4,  'ARAGUA'),
	(5,  'BARINAS'),
	(6,  'BOLIVAR'),
	(7,  'CARABOBO'),
	(8,  'COJEDES'),
	(9,  'DISTRITO CAPITAL'),
	(10, 'LARA'),
	(11, 'MIRANDA'),
	(12, 'SUCRE'),
	(13, 'VARGAS'),
	(14, 'YARACUY'),
	(15, 'ZULIA');

INSERT INTO CIUDAD (ID_CIUDAD, NOMBRE, ID_ESTADO) VALUES
	(1,  'PUERTO AYACUCHO',       1),
	(2,  'BARCELONA',             2),
	(3,  'SAN FERNANDO DE APURE', 3),
	(4,  'MARACAY',               4),
	(5,  'BARINAS',               5),
	(6,  'CIUDAD BOLIVAR',        6),
	(7,  'VALENCIA',              7),
	(8,  'SAN CARLOS',            8),
	(9,  'CARACAS',               9),
	(10, 'BARQUISIMETO',         10),
	(11, 'LOS TEQUES',           11),
	(12, 'CUMANA',               12),
	(13, 'LA GUAIRA',            13),
	(14, 'SAN FELIPE',           14),
	(15, 'MARACAIBO',            15);

-- ============================================================================
-- Catalogos: sexo y estado civil
-- ============================================================================
INSERT INTO SX (ID_SX, DESCRIP) VALUES
	(1, 'MASCULINO'),
	(2, 'FEMENINO');

INSERT INTO ESTADO_CIVIL (ID_ESTADO_CIVIL, DESCRIP) VALUES
	(1, 'SOLTERO'),
	(2, 'CASADO'),
	(3, 'DIVORCIADO'),
	(4, 'VIUDO'),
	(5, 'CONCUBINATO');

-- ============================================================================
-- Catalogos: especialidades (RN-01)
-- ============================================================================
INSERT INTO ESPECIALIDAD (ID_ESPECIALIDAD, DESCRIP) VALUES
	(1,  'CARDIOLOGIA'),
	(2,  'CIRUGIA'),
	(3,  'DERMATOLOGIA'),
	(4,  'ENDOCRINOLOGIA'),
	(5,  'GASTROENTEROLOGIA'),
	(6,  'NEUROLOGIA'),
	(7,  'PEDIATRIA'),
	(8,  'PSIQUIATRIA'),
	(9,  'RADIOTERAPIA'),
	(10, 'TRAUMATOLOGIA');

-- ============================================================================
-- Proveedores
-- ============================================================================
INSERT INTO TIPO_PROVEE (ID_TIPO, DESCRIP) VALUES
	(1, 'LABORATORIO FARMACEUTICO'),
	(2, 'DISTRIBUIDOR'),
	(3, 'FARMACIA');

INSERT INTO PROVEE (ID_PROVEE, NOMBRE, RIF, TELEFONO, FAX, ID_TIPO, ID_CIUDAD, DIRECCION) VALUES
	(1, 'LABORATORIOS FARMACIA CENTRAL', 'J-30123456-7', '0212-5550101', '0212-5550102', 1, 9,  'AV. PRINCIPAL, EDIF. CENTRAL, CARACAS'),
	(2, 'DISTRIBUIDORA MEDICA DEL CENTRO', 'J-30234567-8', '0241-5550201', '0241-5550202', 2, 7,  'CALLE SUCRE, GALPON 4, VALENCIA'),
	(3, 'FARMACIA LA SALUD', 'J-30345678-9', '0261-5550301', '0261-5550302', 3, 15, 'AV. BELLAVISTA, LOCAL 12, MARACAIBO'),
	(4, 'LABORATORIOS ANDINOS', 'J-30456789-0', '0271-5550401', '0271-5550402', 1, 14, 'CARRERA 5, ZONA INDUSTRIAL, SAN FELIPE'),
	(5, 'DISTRIBUIDORA ORIENTAL', 'J-30567890-1', '0285-5550501', '0285-5550502', 2, 2,  'AV. INTERCOMUNAL, GALPON 8, BARCELONA'),
	(6, 'FARMACIA SAN JOSE', 'J-30678901-2', '0212-5550601', '0212-5550602', 3, 9,  'CALLE REAL, LOCAL 3, CARACAS');

-- ============================================================================
-- Personal medico (RN-02 y RN-05)
-- ============================================================================
INSERT INTO MEDICO (CI_MEDICO, COD_COLEGIO_MEDICO, NOMBRE, APELLIDO, F_NACIMIENTO, F_CONTRATACION, ID_SX, ID_ESTADO_CIVIL, ID_ESPECIALIDAD, ID_CIUDAD) VALUES
	(10000001, 50001, 'CARLOS',    'RODRIGUEZ',   '1970-04-12', '2000-03-01', 1, 2,  1, 9),
	(10000002, 50002, 'ANA',       'MARTINEZ',    '1975-08-23', '2005-01-15', 2, 2,  2, 7),
	(10000003, 50003, 'LUIS',      'FERNANDEZ',   '1978-11-05', '2008-06-01', 1, 1,  3, 9),
	(10000004, 50004, 'GABRIELA',  'SANCHEZ',     '1980-02-18', '2010-09-01', 2, 2,  4, 10),
	(10000005, 50005, 'PEDRO',     'RAMIREZ',     '1972-06-30', '2002-04-01', 1, 2,  5, 11),
	(10000006, 50006, 'SOFIA',     'TORRES',      '1982-09-14', '2012-01-10', 2, 1,  6, 9),
	(10000007, 50007, 'MIGUEL',    'DIAZ',        '1976-12-02', '2006-08-15', 1, 2,  7, 4),
	(10000008, 50008, 'VALENTINA', 'RIVAS',       '1984-03-27', '2014-02-01', 2, 1,  8, 9),
	(10000009, 50009, 'JORGE',     'MORALES',     '1968-07-08', '1998-05-01', 1, 2,  9, 12),
	(10000010, 50010, 'DANIELA',   'ORTEGA',      '1981-10-19', '2011-03-01', 2, 1, 10, 7),
	(10000011, 50011, 'RICARDO',   'BLANCO',      '1985-01-25', '2015-07-01', 1, 1,  1, 9),
	(10000012, 50012, 'CARMEN',    'VEGA',        '1986-05-16', '2016-10-01', 2, 1,  7, 2);

-- Experiencia adicional en otras especialidades (RN-05)
INSERT INTO TIENE (CI_MEDICO, ID_ESPECIALIDAD, ANOS_EXPERIENCIA) VALUES
	(10000001,  4, 10),
	(10000002, 10, 12),
	(10000005,  2,  8),
	(10000007,  3,  5),
	(10000010,  2, 10),
	(10000011,  4,  6),
	(10000012, 10,  4);

-- ============================================================================
-- Areas (RN-02): un piso completo por especialidad y un jefe acorde
-- ============================================================================
INSERT INTO AREA (ID_AREA, ID_ESPECIALIDAD, CI_MEDICO_ENCARGADO, PISO, PASILLO) VALUES
	(1,  1, 10000001,  3, 4),
	(2,  2, 10000002,  4, 1),
	(3,  3, 10000003,  2, 2),
	(4,  4, 10000004,  5, 3),
	(5,  5, 10000005,  6, 1),
	(6,  6, 10000006,  7, 2),
	(7,  7, 10000007,  1, 1),
	(8,  8, 10000008,  8, 1),
	(9,  9, 10000009,  9, 1),
	(10, 10, 10000010, 10, 1);

-- Medicos asignados a su area de trabajo (RN-05)
INSERT INTO TRABAJA (ID_MEDICO, ID_AREA, F) VALUES
	(10000001,  1, '2024-01-15'),
	(10000011,  1, '2024-01-15'),
	(10000002,  2, '2024-01-15'),
	(10000003,  3, '2024-01-15'),
	(10000004,  4, '2024-01-15'),
	(10000005,  5, '2024-01-15'),
	(10000006,  6, '2024-01-15'),
	(10000007,  7, '2024-01-15'),
	(10000012,  7, '2024-02-01'),
	(10000008,  8, '2024-01-15'),
	(10000009,  9, '2024-01-15'),
	(10000010, 10, '2024-01-15');

-- ============================================================================
-- Camas (RN-03): 0304 = piso 3, pasillo 4 (area de Cardiologia)
-- ============================================================================
INSERT INTO CAMA (ID_NUMBER_CAMA, ID_AREA_HOSPITAL) VALUES
	(301,  1), (302,  1), (303,  1), (304,  1),
	(401,  2), (402,  2), (403,  2), (404,  2),
	(201,  3), (202,  3),
	(501,  4), (502,  4),
	(601,  5), (602,  5),
	(701,  6), (702,  6),
	(101,  7), (102,  7), (103,  7), (104,  7),
	(801,  8), (802,  8),
	(901,  9), (902,  9),
	(1001, 10), (1002, 10);

-- ============================================================================
-- Personal sanitario
-- ============================================================================
INSERT INTO PERSONAL_SANITARIO (CI_PERSONAL, NOMBRE, APELLIDO, FUNCION, ID_AREA) VALUES
	(15000001, 'MARIA',    'LOPEZ',    'ENFERMERA JEFE',   1),
	(15000002, 'JOSE',     'GARCIA',   'CAMILLERO',        1),
	(15000003, 'ELENA',    'PEREZ',    'INSTRUMENTISTA',   2),
	(15000004, 'RAMON',    'HERNANDEZ','ANESTESISTA',      2),
	(15000005, 'LUCIA',    'MORENO',   'ENFERMERA',        3),
	(15000006, 'PABLO',    'CASTRO',   'ENFERMERO',        4),
	(15000007, 'TERESA',   'RIOS',     'ENFERMERA',        5),
	(15000008, 'ANDRES',   'NAVAS',    'CAMILLERO',        6),
	(15000009, 'CARMEN',   'SOSA',     'ENFERMERA',        7),
	(15000010, 'FELIPE',   'MONTES',   'INSTRUMENTISTA',   8),
	(15000011, 'YOLANDA',  'CAMPOS',   'ANESTESISTA',      9),
	(15000012, 'ALBERTO',  'TAPIA',    'ENFERMERO',       10);

-- ============================================================================
-- Medicinas, tratamientos y su aplicacion
-- ============================================================================
INSERT INTO MEDICINA (ID_MEDICINA, NOMBRE, PRESENTACION, POSOLOGIA, EFECTOS_SECUNDARIOS, ID_PROVEE) VALUES
	(1,  'ACETAMINOFEN',        'TABLETA 500 MG',        '1 TABLETA CADA 8 HORAS',          'NAUSEAS, HEPATOTOXICIDAD',        1),
	(2,  'IBUPROFENO',          'TABLETA 400 MG',        '1 TABLETA CADA 8 HORAS',          'GASTRITIS, MAREOS',               2),
	(3,  'AMOXICILINA',         'CAPSULA 500 MG',        '1 CAPSULA CADA 8 HORAS POR 7 DIAS','DIARREA, RASH CUTANEO',           1),
	(4,  'LOSARTAN',            'TABLETA 50 MG',         '1 TABLETA CADA 12 HORAS',         'MAREO, HIPOTENSION',              3),
	(5,  'METFORMINA',          'TABLETA 850 MG',        '1 TABLETA CON CADA COMIDA',       'NAUSEAS, ACIDOSIS LACTICA',       1),
	(6,  'OMEPRAZOL',           'CAPSULA 20 MG',         '1 CAPSULA EN AYUNAS',             'CEFALEA, DIARREA',                2),
	(7,  'ATORVASTATINA',       'TABLETA 20 MG',         '1 TABLETA POR LA NOCHE',          'MIALGIA, ELEVACION DE TRANSAMINAS',4),
	(8,  'SALBUTAMOL',          'INHALADOR 100 MCG',     '2 INHALACIONES CADA 6 HORAS',     'TAQUICARDIA, TEMBLOR',            5),
	(9,  'DEXAMETASONA',        'AMPOLLA 4 MG',          '1 AMPOLLA CADA 12 HORAS',         'HIPERGLUCEMIA, INSOMNIO',         1),
	(10, 'INSULINA GLARGINA',   'PLUMA 100 UI/ML',       '10 UI SUBCUTANEA AL DIA',         'HIPOGLUCEMIA',                    3),
	(11, 'PARACETAMOL',         'JARABE 120 MG/5 ML',    '5 ML CADA 6 HORAS',               'NAUSEAS',                         5),
	(12, 'SERTRALINA',          'TABLETA 50 MG',         '1 TABLETA AL DIA',                'INSOMNIO, NAUSEAS',               2),
	(13, 'LEVOTIROXINA',        'TABLETA 50 MCG',        '1 TABLETA EN AYUNAS',             'PALPITACIONES',                   4),
	(14, 'DICLOFENAC',          'GEL 1%',                'APLICAR 3 VECES AL DIA',          'IRRITACION LOCAL',                6),
	(15, 'CIPROFLOXACINO',      'TABLETA 500 MG',        '1 TABLETA CADA 12 HORAS',         'TENDINITIS, NAUSEAS',             1);

INSERT INTO TRATAMIENTO (ID_TRATAMIENTO, DESCRIP, COSTO) VALUES
	(1,  'CONTROL DE HIPERTENSION',        120.00),
	(2,  'TERAPIA ANTIBIOTICA',            250.00),
	(3,  'MANEJO DE DIABETES',             180.00),
	(4,  'TERAPIA RESPIRATORIA',           200.00),
	(5,  'TRATAMIENTO DERMATOLOGICO',       90.00),
	(6,  'TERAPIA GASTROINTESTINAL',       140.00),
	(7,  'MANEJO PSIQUIATRICO',            300.00),
	(8,  'REHABILITACION TRAUMATOLOGICA',  350.00),
	(9,  'TERAPIA ONCOLOGICA',             900.00),
	(10, 'CONTROL PEDIATRICO',              80.00),
	(11, 'TERAPIA ENDOCRINA',              160.00),
	(12, 'MANEJO NEUROLOGICO',             400.00);

INSERT INTO APLICA (ID_MEDICINA, ID_TRATAMIENTO, CANT_DIAS, F_INICIO, F_FIN) VALUES
	(4,  1,  30, '2025-01-05', '2025-02-04'),
	(3,  2,   7, '2025-01-12', '2025-01-19'),
	(5,  3,  90, '2025-01-06', '2025-04-06'),
	(8,  4,  15, '2025-02-20', '2025-03-07'),
	(9,  5,  10, '2025-02-01', '2025-02-11'),
	(6,  6,  21, '2025-02-10', '2025-03-03'),
	(12, 7,  60, '2025-03-01', '2025-04-30'),
	(2,  8,  20, '2025-03-10', '2025-03-30'),
	(9,  9,  45, '2025-03-05', '2025-04-19'),
	(11, 10,  5, '2025-04-07', '2025-04-12'),
	(13, 11, 120, '2025-04-03', '2025-08-01'),
	(14, 8,  14, '2025-04-15', '2025-04-29'),
	(1,  1,  10, '2025-05-01', '2025-05-11'),
	(15, 2,  10, '2025-05-03', '2025-05-13'),
	(10, 3, 180, '2025-05-05', '2025-11-01');

-- ============================================================================
-- Diagnosticos e intervenciones
-- ============================================================================
INSERT INTO DIAGN (ID_DIAGN, TIPO, NOMBRE, DESCRIP, COSTO) VALUES
	(1,  'CARDIOVASCULAR',  'HIPERTENSION ARTERIAL',       'TENSION ARTERIAL ELEVADA DE FORMA SOSTENIDA', 80.00),
	(2,  'ENDOCRINO',       'DIABETES MELLITUS TIPO 2',    'GLICEMIA EN AYUNAS POR ENCIMA DE 126 MG/DL',  90.00),
	(3,  'RESPIRATORIO',    'ASMA BRONQUIAL',              'OBSTRUCCION REVERSIBLE DE LA VIA AEREA',      70.00),
	(4,  'DERMATOLOGICO',   'DERMATITIS ATOPICA',          'INFLAMACION CRONICA DE LA PIEL',              60.00),
	(5,  'GASTROINTESTINAL','GASTRITIS AGUDA',             'INFLAMACION DE LA MUCOSA GASTRICA',           75.00),
	(6,  'NEUROLOGICO',     'MIGRANA',                     'CEFALEA RECURRENTE CON FOTOFOBIA',            85.00),
	(7,  'PSIQUIATRICO',    'DEPRESION MAYOR',             'TRASTORNO DEL ESTADO DE ANIMO PERSISTENTE',   95.00),
	(8,  'TRAUMATOLOGICO',  'FRACTURA DE FEMUR',           'SOLUCION DE CONTINUIDAD OSEA EN FEMUR',      150.00),
	(9,  'TRAUMATOLOGICO',  'ARTROSIS DE RODILLA',         'DEGENERACION DEL CARTILAGO ARTICULAR',       100.00),
	(10, 'ENDOCRINO',       'OBESIDAD',                    'INDICE DE MASA CORPORAL MAYOR A 30',           65.00),
	(11, 'RESPIRATORIO',    'RINOFARINGITIS',              'INFLAMACION DE VIAS AEREAS SUPERIORES',        55.00),
	(12, 'GASTROINTESTINAL','COLITIS ULCEROSA',            'INFLAMACION CRONICA DEL COLON',              110.00),
	(13, 'NEUROLOGICO',     'EPILEPSIA',                   'CRISIS CONVULSIVAS RECURRENTES',             120.00),
	(14, 'PSIQUIATRICO',    'ANSIEDAD GENERALIZADA',       'PREOCUPACION EXCESIVA Y PERSISTENTE',         90.00),
	(15, 'ONCOLOGICO',      'NEOPLASIA DE MAMA',           'TUMOR MALIGNO EN TEJIDO MAMARIO',            300.00);

INSERT INTO INTERVENCION (ID_INTERVENCION, DESCRIP, TIPO) VALUES
	(1,  'APENDICECTOMIA',          'CIRUGIA'),
	(2,  'COLECISTECTOMIA',         'CIRUGIA'),
	(3,  'CESAREA',                 'CIRUGIA'),
	(4,  'REDUCCION DE FRACTURA',   'TRAUMATOLOGIA'),
	(5,  'BIOPSIA DE PIEL',         'PROCEDIMIENTO'),
	(6,  'ENDOSCOPIA DIGESTIVA',    'PROCEDIMIENTO'),
	(7,  'CIRUGIA DE CATARATAS',    'CIRUGIA'),
	(8,  'EXTRACCION DE TUMOR',     'ONCOLOGIA'),
	(9,  'DRENAJE DE ABSCESO',      'PROCEDIMIENTO'),
	(10, 'ARTROSCOPIA',             'TRAUMATOLOGIA');

-- ============================================================================
-- Pacientes (40)
--   * 20364201-20364226: cedulas de HISTORIAS_MEDICAS.csv y
--     POLIZAS_DE_SEGUROS.csv (tipo de sangre tomado del CSV).
--   * 20364227-20364240: pacientes adicionales de prueba.
-- ============================================================================
INSERT INTO PAC (CI_PAC, NOMBRE, APELLIDO, F_NACIMIENTO, TIPO_SANGRE, NACIONALIDAD, ID_ESTADO_CIVIL, ID_SX, ID_CIUDAD) VALUES
	(20364201, 'JOSE',      'PEREZ',      '1996-03-14', 'O+',  'VENEZOLANA', 1, 1,  1),
	(20364202, 'MARIA',     'GONZALEZ',   '1995-07-22', 'O-',  'VENEZOLANA', 2, 2,  2),
	(20364203, 'CARLOS',    'RODRIGUEZ',  '1994-11-05', 'AB+', 'VENEZOLANA', 1, 1,  3),
	(20364204, 'ANA',       'MARTINEZ',   '1993-01-30', 'AB-', 'VENEZOLANA', 2, 2,  4),
	(20364205, 'LUIS',      'FERNANDEZ',  '1992-06-18', 'O-',  'VENEZOLANA', 1, 1,  5),
	(20364206, 'GABRIELA',  'SANCHEZ',    '1991-09-09', 'B-',  'VENEZOLANA', 2, 2,  6),
	(20364207, 'PEDRO',     'RAMIREZ',    '1990-12-25', 'AB+', 'VENEZOLANA', 1, 1,  7),
	(20364208, 'SOFIA',     'TORRES',     '1989-04-11', 'AB-', 'VENEZOLANA', 3, 2,  8),
	(20364209, 'MIGUEL',    'DIAZ',       '1988-08-02', 'O-',  'VENEZOLANA', 2, 1,  9),
	(20364210, 'VALENTINA', 'RIVAS',      '1987-02-17', 'B-',  'VENEZOLANA', 1, 2, 10),
	(20364211, 'JORGE',     'MORALES',    '1986-05-28', 'B+',  'VENEZOLANA', 2, 1, 11),
	(20364212, 'DANIELA',   'ORTEGA',     '1985-10-03', 'AB+', 'VENEZOLANA', 1, 2, 12),
	(20364213, 'RICARDO',   'BLANCO',     '1984-07-19', 'AB-', 'VENEZOLANA', 2, 1,  1),
	(20364214, 'CARMEN',    'VEGA',       '1983-03-08', 'O-',  'VENEZOLANA', 3, 2,  2),
	(20364215, 'ANDRES',    'GUERRERO',   '1982-11-21', 'AB-', 'VENEZOLANA', 2, 1,  3),
	(20364216, 'PATRICIA',  'MENDOZA',    '1981-06-12', 'O-',  'VENEZOLANA', 1, 2,  4),
	(20364217, 'FERNANDO',  'CASTILLO',   '1980-01-26', 'B-',  'VENEZOLANA', 2, 1,  5),
	(20364218, 'ROSA',      'HERRERA',    '1979-09-14', 'B+',  'VENEZOLANA', 1, 2,  6),
	(20364219, 'EDUARDO',   'JIMENEZ',    '1978-04-07', 'AB+', 'VENEZOLANA', 2, 1,  7),
	(20364220, 'LUCIA',     'ROMERO',     '1977-12-30', 'AB-', 'VENEZOLANA', 3, 2,  8),
	(20364221, 'RAFAEL',    'SUAREZ',     '1976-08-16', 'O-',  'VENEZOLANA', 2, 1,  9),
	(20364222, 'ISABEL',    'CONTRERAS',  '1975-02-04', 'AB-', 'VENEZOLANA', 1, 2, 10),
	(20364223, 'MANUEL',    'AGUILAR',    '1974-05-24', 'O-',  'VENEZOLANA', 2, 1, 11),
	(20364224, 'PAULA',     'MEDINA',     '1973-10-10', 'B-',  'VENEZOLANA', 4, 2, 12),
	(20364225, 'DIEGO',     'PAREDES',    '1972-07-01', 'B+',  'VENEZOLANA', 2, 1,  1),
	(20364226, 'LAURA',     'SILVA',      '1971-03-20', 'O+',  'VENEZOLANA', 1, 2,  2),
	(20364227, 'HECTOR',    'PALACIOS',   '1990-09-12', 'A+',  'VENEZOLANA', 1, 1,  3),
	(20364228, 'TERESA',    'MOLINA',     '1982-08-27', 'A-',  'VENEZOLANA', 2, 2,  4),
	(20364229, 'ALBERTO',   'ROJAS',      '1968-01-19', 'O+',  'VENEZOLANA', 2, 1,  5),
	(20364230, 'NATALIA',   'ACOSTA',     '1999-05-06', 'B+',  'VENEZOLANA', 1, 2,  6),
	(20364231, 'GREGORIO',  'LEON',       '1959-11-11', 'AB+', 'VENEZOLANA', 4, 1,  7),
	(20364232, 'BEATRIZ',   'NAVARRO',    '1975-07-23', 'O-',  'VENEZOLANA', 2, 2,  8),
	(20364233, 'OSCAR',     'DELGADO',    '1985-12-02', 'A+',  'VENEZOLANA', 1, 1,  9),
	(20364234, 'MIRANDA',   'FIGUEROA',   '2006-04-17', 'O+',  'VENEZOLANA', 1, 2, 10),
	(20364235, 'JAVIER',    'CORDERO',    '1962-06-29', 'B-',  'VENEZOLANA', 2, 1, 11),
	(20364236, 'ADRIANA',   'PONCE',      '1979-02-08', 'AB-', 'VENEZOLANA', 3, 2, 12),
	(20364237, 'EMILIO',    'SALAZAR',    '1955-10-14', 'O+',  'VENEZOLANA', 4, 1,  1),
	(20364238, 'VERONICA',  'CABRERA',    '2001-08-31', 'A-',  'VENEZOLANA', 1, 2,  2),
	(20364239, 'NICOLAS',   'BRICENO',    '1987-04-25', 'B+',  'VENEZOLANA', 2, 1,  3),
	(20364240, 'JULIETA',   'MARCANO',    '2009-12-09', 'O-',  'VENEZOLANA', 2, 2,  4);

-- ============================================================================
-- Hospitalizaciones (RN-04): 30 pacientes, camas reutilizadas en el tiempo
-- ============================================================================
INSERT INTO OCUPA (CI_PAC, ID_NUMBER_CAMA, F_INICIO, CANTIDAD_DIAS, DIAS_CUBIERTOS_SEGURO, COSTO_DIARIO, ESTATUS) VALUES
	(20364201,  301, '2025-01-05',  5,  3, 45.00, 'ALTA'),
	(20364202,  302, '2025-01-08',  4,  4, 45.00, 'ALTA'),
	(20364203,  303, '2025-02-10',  6,  2, 45.00, 'ACTIVA'),
	(20364204,  401, '2025-01-12',  3,  3, 60.00, 'ALTA'),
	(20364205,  402, '2025-01-15',  4,  2, 60.00, 'ALTA'),
	(20364206,  403, '2025-01-20',  2,  2, 60.00, 'ALTA'),
	(20364207,  404, '2025-01-22',  3,  1, 60.00, 'ALTA'),
	(20364208,  201, '2025-02-01',  2,  2, 30.00, 'ALTA'),
	(20364209,  202, '2025-02-03',  2,  0, 30.00, 'ALTA'),
	(20364210,  501, '2025-02-05',  4,  4, 35.00, 'ALTA'),
	(20364211,  502, '2025-02-07',  5,  3, 35.00, 'ALTA'),
	(20364212,  601, '2025-02-10',  3,  3, 40.00, 'ALTA'),
	(20364213,  602, '2025-02-12',  4,  2, 40.00, 'ALTA'),
	(20364214,  701, '2025-02-15',  3,  3, 50.00, 'ALTA'),
	(20364215,  702, '2025-02-17',  5,  4, 50.00, 'ALTA'),
	(20364216,  101, '2025-02-20',  2,  2, 25.00, 'ALTA'),
	(20364217,  801, '2025-03-01',  7,  5, 55.00, 'ALTA'),
	(20364218,  802, '2025-03-03',  6,  6, 55.00, 'ALTA'),
	(20364219,  901, '2025-03-05',  4,  2, 70.00, 'ALTA'),
	(20364220,  902, '2025-03-07',  5,  3, 70.00, 'ACTIVA'),
	(20364221, 1001, '2025-03-10',  6,  4, 65.00, 'ALTA'),
	(20364222, 1002, '2025-03-12',  4,  4, 65.00, 'ALTA'),
	(20364223,  301, '2025-03-15',  3,  2, 45.00, 'ALTA'),
	(20364224,  302, '2025-03-18',  2,  2, 45.00, 'ALTA'),
	(20364225,  401, '2025-03-20',  5,  3, 60.00, 'ALTA'),
	(20364226,  402, '2025-03-22',  4,  4, 60.00, 'ALTA'),
	(20364227,  303, '2025-04-01',  3,  1, 45.00, 'ALTA'),
	(20364228,  501, '2025-04-03',  4,  4, 35.00, 'ALTA'),
	(20364229,  601, '2025-04-05',  3,  2, 40.00, 'ALTA'),
	(20364230,  101, '2025-04-07',  2,  2, 25.00, 'ALTA'),
	(20364234,  102, '2025-04-17',  3,  3, 25.00, 'ALTA'),
	(20364238,  103, '2025-05-07',  4,  2, 25.00, 'ACTIVA'),
	(20364240,  104, '2025-05-12',  2,  2, 25.00, 'ACTIVA');

-- ============================================================================
-- Diagnosticos realizados (RN-06, RN-10)
-- El numero de ingreso coincide con el usado en PRESCRIBE/PRACTICA.
-- ============================================================================
INSERT INTO REALIZA (CI_MEDICO, CI_PAC, ID_DIAGN, NUMBER_INGRESO, F_ELABORACION) VALUES
	(10000001, 20364201,  1, 5001, '2025-01-05'),
	(10000004, 20364201,  2, 5001, '2025-01-06'),
	(10000001, 20364202,  1, 5002, '2025-01-08'),
	(10000011, 20364202,  3, 5002, '2025-01-09'),
	(10000001, 20364203,  1, 5003, '2025-02-10'),
	(10000004, 20364203,  2, 5003, '2025-02-11'),
	(10000001, 20364204,  1, 5004, '2025-01-12'),
	(10000004, 20364205,  2, 5005, '2025-01-15'),
	(10000003, 20364206,  4, 5006, '2025-01-20'),
	(10000003, 20364207,  4, 5007, '2025-01-22'),
	(10000008, 20364207, 14, 5007, '2025-01-23'),
	(10000008, 20364208,  7, 5008, '2025-02-01'),
	(10000008, 20364209, 14, 5009, '2025-02-03'),
	(10000004, 20364210,  2, 5010, '2025-02-05'),
	(10000004, 20364211, 10, 5011, '2025-02-07'),
	(10000005, 20364212,  5, 5012, '2025-02-10'),
	(10000004, 20364212,  2, 5012, '2025-02-11'),
	(10000005, 20364213, 12, 5013, '2025-02-12'),
	(10000006, 20364214,  6, 5014, '2025-02-15'),
	(10000008, 20364214,  7, 5014, '2025-02-16'),
	(10000006, 20364215, 13, 5015, '2025-02-17'),
	(10000007, 20364216, 11, 5016, '2025-02-20'),
	(10000008, 20364217,  7, 5017, '2025-03-01'),
	(10000008, 20364218, 14, 5018, '2025-03-03'),
	(10000009, 20364219, 15, 5019, '2025-03-05'),
	(10000009, 20364220, 15, 5020, '2025-03-07'),
	(10000010, 20364221,  8, 5021, '2025-03-10'),
	(10000002, 20364221,  8, 5021, '2025-03-11'),
	(10000010, 20364222,  9, 5022, '2025-03-12'),
	(10000010, 20364223,  9, 5023, '2025-03-15'),
	(10000005, 20364224,  5, 5024, '2025-03-18'),
	(10000005, 20364225, 12, 5025, '2025-03-20'),
	(10000001, 20364225,  1, 5025, '2025-03-21'),
	(10000006, 20364226,  6, 5026, '2025-03-22'),
	(10000007, 20364227, 11, 5027, '2025-04-01'),
	(10000004, 20364228, 10, 5028, '2025-04-03'),
	(10000005, 20364229,  5, 5029, '2025-04-05'),
	(10000007, 20364230,  3, 5030, '2025-04-07'),
	(10000007, 20364230, 11, 5030, '2025-04-08'),
	(10000001, 20364231,  1, 5031, '2025-04-10'),
	(10000003, 20364232,  4, 5032, '2025-04-12'),
	(10000010, 20364233,  8, 5033, '2025-04-15'),
	(10000007, 20364234,  3, 5034, '2025-04-17'),
	(10000007, 20364234, 11, 5034, '2025-04-18'),
	(10000001, 20364235,  1, 5035, '2025-05-01'),
	(10000004, 20364236,  2, 5036, '2025-05-03'),
	(10000009, 20364237, 15, 5037, '2025-05-05'),
	(10000001, 20364237,  1, 5037, '2025-05-06'),
	(10000007, 20364238, 11, 5038, '2025-05-07'),
	(10000006, 20364239, 13, 5039, '2025-05-10'),
	(10000007, 20364240,  3, 5040, '2025-05-12'),
	(10000007, 20364240, 11, 5040, '2025-05-13');

-- ============================================================================
-- Prescripciones de tratamiento (RN-07, RN-10)
-- ============================================================================
INSERT INTO PRESCRIBE (CI_MEDICO, CI_PAC, ID_TRATAMIENTO, NUMBER_INGRESO, F_ELABORACION) VALUES
	(10000001, 20364201,  1, 5001, '2025-01-05'),
	(10000004, 20364201,  3, 5001, '2025-01-06'),
	(10000001, 20364202,  1, 5002, '2025-01-08'),
	(10000001, 20364203,  1, 5003, '2025-02-10'),
	(10000001, 20364204,  1, 5004, '2025-01-12'),
	(10000004, 20364205,  3, 5005, '2025-01-15'),
	(10000003, 20364206,  5, 5006, '2025-01-20'),
	(10000003, 20364207,  5, 5007, '2025-01-22'),
	(10000008, 20364208,  7, 5008, '2025-02-01'),
	(10000008, 20364209,  7, 5009, '2025-02-03'),
	(10000004, 20364210,  3, 5010, '2025-02-05'),
	(10000004, 20364211, 11, 5011, '2025-02-07'),
	(10000005, 20364212,  6, 5012, '2025-02-10'),
	(10000004, 20364212,  3, 5012, '2025-02-11'),
	(10000005, 20364213,  6, 5013, '2025-02-12'),
	(10000006, 20364214, 12, 5014, '2025-02-15'),
	(10000006, 20364215, 12, 5015, '2025-02-17'),
	(10000007, 20364216, 10, 5016, '2025-02-20'),
	(10000008, 20364217,  7, 5017, '2025-03-01'),
	(10000008, 20364218,  7, 5018, '2025-03-03'),
	(10000009, 20364219,  9, 5019, '2025-03-05'),
	(10000009, 20364220,  9, 5020, '2025-03-07'),
	(10000010, 20364221,  8, 5021, '2025-03-10'),
	(10000002, 20364221,  8, 5021, '2025-03-11'),
	(10000010, 20364222,  8, 5022, '2025-03-12'),
	(10000010, 20364223,  8, 5023, '2025-03-15'),
	(10000005, 20364224,  6, 5024, '2025-03-18'),
	(10000005, 20364225, 12, 5025, '2025-03-20'),
	(10000001, 20364225,  1, 5025, '2025-03-21'),
	(10000006, 20364226, 12, 5026, '2025-03-22'),
	(10000007, 20364227, 10, 5027, '2025-04-01'),
	(10000004, 20364228, 11, 5028, '2025-04-03'),
	(10000005, 20364229,  6, 5029, '2025-04-05'),
	(10000007, 20364230,  4, 5030, '2025-04-07'),
	(10000007, 20364230, 10, 5030, '2025-04-08'),
	(10000001, 20364231,  1, 5031, '2025-04-10'),
	(10000003, 20364232,  5, 5032, '2025-04-12'),
	(10000010, 20364233,  8, 5033, '2025-04-15'),
	(10000007, 20364234,  4, 5034, '2025-04-17'),
	(10000001, 20364235,  1, 5035, '2025-05-01'),
	(10000004, 20364236,  3, 5036, '2025-05-03'),
	(10000009, 20364237,  9, 5037, '2025-05-05'),
	(10000001, 20364237,  1, 5037, '2025-05-06'),
	(10000007, 20364238,  4, 5038, '2025-05-07'),
	(10000006, 20364239, 12, 5039, '2025-05-10'),
	(10000007, 20364240,  4, 5040, '2025-05-12');

-- ============================================================================
-- Practicas / intervenciones (RN-09): medico o equipo, personal sanitario,
-- riesgo, duracion, gastos, honorarios y costo.
-- ============================================================================
INSERT INTO PRACTICA (CI_MEDICO, CI_PAC, ID_INTERVENCION, CI_PERSONAL_SANITARIO, F, RIESGO, DURACION, GASTO_EQUIPOS, COSTO, HONORARIO_EQUIPO) VALUES
	(10000002, 20364204,  2, 15000003, '2025-01-13', 'ALTO',   120, 900.00, 1800.00, 700.00),
	(10000002, 20364211,  1, 15000003, '2025-02-08', 'MEDIO',   90, 700.00, 1400.00, 550.00),
	(10000002, 20364225,  1, 15000004, '2025-03-21', 'MEDIO',   90, 700.00, 1400.00, 550.00),
	(10000002, 20364239,  1, 15000003, '2025-05-11', 'BAJO',    75, 600.00, 1200.00, 450.00),
	(10000002, 20364236,  3, 15000004, '2025-05-04', 'ALTO',   150, 950.00, 2100.00, 800.00),
	(10000002, 20364231,  7, 15000003, '2025-04-11', 'MEDIO',   60, 500.00, 1100.00, 400.00),
	(10000002, 20364235,  7, 15000004, '2025-05-02', 'MEDIO',   60, 500.00, 1100.00, 400.00),
	(10000002, 20364237,  7, 15000003, '2025-05-06', 'ALTO',    70, 550.00, 1150.00, 420.00),
	(10000002, 20364229,  9, 15000003, '2025-04-06', 'BAJO',    45, 300.00,  650.00, 250.00),
	(10000003, 20364206,  5, 15000005, '2025-01-21', 'BAJO',    30, 150.00,  400.00, 180.00),
	(10000003, 20364207,  5, 15000005, '2025-01-23', 'BAJO',    30, 150.00,  400.00, 180.00),
	(10000003, 20364234,  5, 15000005, '2025-04-18', 'BAJO',    30, 150.00,  400.00, 180.00),
	(10000003, 20364238,  5, 15000005, '2025-05-08', 'BAJO',    30, 150.00,  400.00, 180.00),
	(10000005, 20364213,  6, 15000007, '2025-02-13', 'MEDIO',   45, 450.00,  900.00, 320.00),
	(10000005, 20364224,  6, 15000007, '2025-03-19', 'MEDIO',   45, 450.00,  900.00, 320.00),
	(10000005, 20364229,  6, 15000007, '2025-04-06', 'BAJO',    40, 400.00,  850.00, 300.00),
	(10000009, 20364219,  8, 15000011, '2025-03-06', 'ALTO',   180, 2000.00, 4500.00, 1600.00),
	(10000009, 20364220,  8, 15000011, '2025-03-08', 'ALTO',   180, 2000.00, 4500.00, 1600.00),
	(10000009, 20364237,  8, 15000011, '2025-05-06', 'ALTO',   200, 2200.00, 4800.00, 1700.00),
	(10000010, 20364221,  4, 15000002, '2025-03-11', 'ALTO',   120, 850.00, 1900.00, 750.00),
	(10000010, 20364222, 10, 15000002, '2025-03-13', 'MEDIO',   60, 400.00,  950.00, 350.00),
	(10000010, 20364223, 10, 15000002, '2025-03-16', 'MEDIO',   60, 400.00,  950.00, 350.00),
	(10000010, 20364233, 10, 15000002, '2025-04-16', 'BAJO',    55, 380.00,  900.00, 330.00),
	(10000007, 20364230,  9, 15000009, '2025-04-08', 'BAJO',    30, 200.00,  500.00, 200.00);
