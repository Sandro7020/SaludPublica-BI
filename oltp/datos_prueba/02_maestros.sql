-- ============================================================================
-- Fase 2 - Maestros (PostgreSQL)
-- Esquema destino: "OLTP"
--
-- Contenido:
--   * 12 medicos con su especialidad principal y experiencia adicional.
--   * 10 areas, una por especialidad, con jefe acorde (RN-01, RN-02).
--   * 26 camas distribuidas por area (RN-03).
--   * 12 miembros del personal sanitario con funciones acordes al area.
--   * 40 pacientes: los 26 de las fuentes y 14 adicionales.
--
-- Los pacientes sinteticos 20364227-20364240 se reutilizan ajustando su
-- fecha de nacimiento para cubrir pediatria, maternidad, oncologia y
-- traumatologia sin agregar pacientes.
--
-- Requiere: 01_catalogos.sql.
-- ============================================================================

SET search_path TO "OLTP";

TRUNCATE TABLE
	"OLTP".PAC,
	"OLTP".MEDICO,
	"OLTP".TIENE,
	"OLTP".AREA,
	"OLTP".TRABAJA,
	"OLTP".CAMA,
	"OLTP".PERSONAL_SANITARIO
CASCADE;

-- ============================================================================
-- Medicos (RN-05)
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
-- Areas (RN-02): un piso por especialidad y un jefe de la misma especialidad
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

-- Medicos asignados a su area de trabajo (RN-05).
-- El medico 10000012 (pediatria) queda activo en el area 7.
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
-- Camas (RN-03): 26 camas, al menos 2 por area
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
-- Personal sanitario: funciones acordes al area (RN-09)
-- ============================================================================
INSERT INTO PERSONAL_SANITARIO (CI_PERSONAL, NOMBRE, APELLIDO, FUNCION, ID_AREA) VALUES
	(15000001, 'MARIA',   'LOPEZ',     'ENFERMERA JEFE',        1),
	(15000002, 'JOSE',    'GARCIA',    'CAMILLERO',             1),
	(15000003, 'ELENA',   'PEREZ',     'INSTRUMENTISTA',        2),
	(15000004, 'RAMON',   'HERNANDEZ', 'ANESTESISTA',           2),
	(15000005, 'LUCIA',   'MORENO',    'ENFERMERA',             3),
	(15000006, 'PABLO',   'CASTRO',    'ENFERMERO',             4),
	(15000007, 'TERESA',  'RIOS',      'ENFERMERA',             5),
	(15000008, 'ANDRES',  'NAVAS',     'ENFERMERO',             6),
	(15000009, 'CARMEN',  'SOSA',      'ENFERMERA PEDIATRA',    7),
	(15000010, 'FELIPE',  'MONTES',    'ENFERMERO PSIQUIATRICO',8),
	(15000011, 'YOLANDA', 'CAMPOS',    'TECNICO EN RADIOTERAPIA',9),
	(15000012, 'ALBERTO', 'TAPIA',     'FISIOTERAPEUTA',       10);

-- ============================================================================
-- Pacientes (40)
--   * 20364201-20364226: cedulas de HISTORIAS_MEDICAS.csv y
--     POLIZAS_DE_SEGUROS.csv.
--   * 20364227-20364240: pacientes adicionales de prueba, con fechas
--     ajustadas para cubrir pediatria, maternidad y otros perfiles.
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
	(20364227, 'HECTOR',    'PALACIOS',   '2014-09-12', 'A+',  'VENEZOLANA', 1, 1,  3),
	(20364228, 'TERESA',    'MOLINA',     '1982-08-27', 'A-',  'VENEZOLANA', 2, 2,  4),
	(20364229, 'ALBERTO',   'ROJAS',      '1968-01-19', 'O+',  'VENEZOLANA', 2, 1,  5),
	(20364230, 'NATALIA',   'ACOSTA',     '2011-05-06', 'B+',  'VENEZOLANA', 1, 2,  6),
	(20364231, 'GREGORIO',  'LEON',       '1959-11-11', 'AB+', 'VENEZOLANA', 4, 1,  7),
	(20364232, 'BEATRIZ',   'NAVARRO',    '1975-07-23', 'O-',  'VENEZOLANA', 2, 2,  8),
	(20364233, 'OSCAR',     'DELGADO',    '1985-12-02', 'A+',  'VENEZOLANA', 1, 1,  9),
	(20364234, 'MIRANDA',   'FIGUEROA',   '2016-04-17', 'O+',  'VENEZOLANA', 1, 2, 10),
	(20364235, 'JAVIER',    'CORDERO',    '1962-06-29', 'B-',  'VENEZOLANA', 2, 1, 11),
	(20364236, 'ADRIANA',   'PONCE',      '1979-02-08', 'AB-', 'VENEZOLANA', 3, 2, 12),
	(20364237, 'EMILIO',    'SALAZAR',    '1955-10-14', 'O+',  'VENEZOLANA', 4, 1,  1),
	(20364238, 'VERONICA',  'CABRERA',    '2009-08-31', 'A-',  'VENEZOLANA', 1, 2,  2),
	(20364239, 'NICOLAS',   'BRICENO',    '1987-04-25', 'B+',  'VENEZOLANA', 2, 1,  3),
	(20364240, 'JULIETA',   'MARCANO',    '2013-12-09', 'O-',  'VENEZOLANA', 1, 2,  4);
