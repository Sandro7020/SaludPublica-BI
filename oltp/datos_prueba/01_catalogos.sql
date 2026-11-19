-- ============================================================================
-- Fase 2 - Catalogos (PostgreSQL)
-- Esquema destino: "OLTP"
--
-- Contenido:
--   * Geografia, sexo, estado civil y especialidades (RN-01).
--   * Proveedores, medicinas, tratamientos y su composicion (RN-07).
--   * Diagnosticos e intervenciones.
--   * Catalogos de facturacion: aseguradoras, tipos de servicio y estados.
--   * Costos reescalados a bolivares para que la cobertura de poliza y el
--     copago del paciente sean significativos.
--
-- Orden de ejecucion: 01_catalogos.sql -> 02_maestros.sql -> fases 3 a 7.
-- El TRUNCATE ... CASCADE limpia los datos dependientes para permitir
-- re-ejecutar la carga desde cero.
-- ============================================================================

SET search_path TO "OLTP";

TRUNCATE TABLE
	"OLTP".ESTADO,
	"OLTP".CIUDAD,
	"OLTP".SX,
	"OLTP".ESTADO_CIVIL,
	"OLTP".ESPECIALIDAD,
	"OLTP".TIPO_PROVEE,
	"OLTP".PROVEE,
	"OLTP".MEDICINA,
	"OLTP".TRATAMIENTO,
	"OLTP".APLICA,
	"OLTP".DIAGN,
	"OLTP".INTERVENCION,
	"OLTP".ASEGURADORA,
	"OLTP".TIPO_SERVICIO,
	"OLTP".ESTADO_FACTURA
CASCADE;

-- ============================================================================
-- Geografia
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
-- Sexo, estado civil y especialidades
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
-- Aseguradoras (RN-12 y RN-14)
-- Nombres normalizados a partir de POLIZAS_DE_SEGUROS.csv.
-- ============================================================================
INSERT INTO ASEGURADORA (ID_ASEGURADORA, NOMBRE, RIF, TELEFONO) VALUES
	(1, 'QUALITAS',    'J-30012345-6', '0212-5551001'),
	(2, 'CONSTITUCION','J-30023456-7', '0212-5551002'),
	(3, 'VENEZOLANA',  'J-30034567-8', '0212-5551003'),
	(4, 'MERCANTIL',   'J-30045678-9', '0212-5551004'),
	(5, 'CARACAS',     'J-30056789-0', '0212-5551005'),
	(6, 'SANITAS',     'J-30067890-1', '0212-5551006'),
	(7, 'RESCARVEN',   'J-30078901-2', '0212-5551007');

-- ============================================================================
-- Catalogos de facturacion (RN-11 y RN-13)
-- ============================================================================
INSERT INTO TIPO_SERVICIO (ID_TIPO_SERVICIO, DESCRIP, CATEGORIA_POLIZA) VALUES
	(1, 'DIAGNOSTICO', 'EXAMENES'),
	(2, 'TRATAMIENTO', 'HOSPITALIZACION'),
	(3, 'INTERVENCION', 'CIRUGIA');

INSERT INTO ESTADO_FACTURA (ID_ESTADO, DESCRIP) VALUES
	(1, 'PAGADA'),
	(2, 'PENDIENTE'),
	(3, 'VENCIDA');

-- ============================================================================
-- Medicinas
-- ============================================================================
INSERT INTO MEDICINA (ID_MEDICINA, NOMBRE, PRESENTACION, POSOLOGIA, EFECTOS_SECUNDARIOS, ID_PROVEE) VALUES
	(1,  'ACETAMINOFEN',        'TABLETA 500 MG',        '1 TABLETA CADA 8 HORAS',           'NAUSEAS, HEPATOTOXICIDAD',         1),
	(2,  'IBUPROFENO',          'TABLETA 400 MG',        '1 TABLETA CADA 8 HORAS',           'GASTRITIS, MAREOS',                2),
	(3,  'AMOXICILINA',         'CAPSULA 500 MG',        '1 CAPSULA CADA 8 HORAS POR 7 DIAS','DIARREA, RASH CUTANEO',            1),
	(4,  'LOSARTAN',            'TABLETA 50 MG',         '1 TABLETA CADA 12 HORAS',          'MAREO, HIPOTENSION',               3),
	(5,  'METFORMINA',          'TABLETA 850 MG',        '1 TABLETA CON CADA COMIDA',        'NAUSEAS, ACIDOSIS LACTICA',        1),
	(6,  'OMEPRAZOL',           'CAPSULA 20 MG',         '1 CAPSULA EN AYUNAS',              'CEFALEA, DIARREA',                 2),
	(7,  'ATORVASTATINA',       'TABLETA 20 MG',         '1 TABLETA POR LA NOCHE',           'MIALGIA, ELEVACION DE TRANSAMINAS',4),
	(8,  'SALBUTAMOL',          'INHALADOR 100 MCG',     '2 INHALACIONES CADA 6 HORAS',      'TAQUICARDIA, TEMBLOR',             5),
	(9,  'DEXAMETASONA',        'AMPOLLA 4 MG',          '1 AMPOLLA CADA 12 HORAS',          'HIPERGLUCEMIA, INSOMNIO',          1),
	(10, 'INSULINA GLARGINA',   'PLUMA 100 UI/ML',       '10 UI SUBCUTANEA AL DIA',          'HIPOGLUCEMIA',                     3),
	(11, 'PARACETAMOL',         'JARABE 120 MG/5 ML',    '5 ML CADA 6 HORAS',                'NAUSEAS',                          5),
	(12, 'SERTRALINA',          'TABLETA 50 MG',         '1 TABLETA AL DIA',                 'INSOMNIO, NAUSEAS',                2),
	(13, 'LEVOTIROXINA',        'TABLETA 50 MCG',        '1 TABLETA EN AYUNAS',              'PALPITACIONES',                    4),
	(14, 'DICLOFENAC',          'GEL 1%',                'APLICAR 3 VECES AL DIA',           'IRRITACION LOCAL',                 6),
	(15, 'CIPROFLOXACINO',      'TABLETA 500 MG',        '1 TABLETA CADA 12 HORAS',          'TENDINITIS, NAUSEAS',              1),
	(16, 'CARBAMAZEPINA',       'TABLETA 200 MG',        '1 TABLETA CADA 12 HORAS',          'MAREO, SOMNOLENCIA, RASH CUTANEO', 1);

-- ============================================================================
-- Tratamientos con costos en bolivares (rango 5.000 - 80.000)
-- ============================================================================
INSERT INTO TRATAMIENTO (ID_TRATAMIENTO, DESCRIP, COSTO) VALUES
	(1,  'CONTROL DE HIPERTENSION',        18000.00),
	(2,  'TERAPIA ANTIBIOTICA',            32000.00),
	(3,  'MANEJO DE DIABETES',             26000.00),
	(4,  'TERAPIA RESPIRATORIA',           24000.00),
	(5,  'TRATAMIENTO DERMATOLOGICO',      12000.00),
	(6,  'TERAPIA GASTROINTESTINAL',       20000.00),
	(7,  'MANEJO PSIQUIATRICO',            38000.00),
	(8,  'REHABILITACION TRAUMATOLOGICA',  45000.00),
	(9,  'TERAPIA ONCOLOGICA',             78000.00),
	(10, 'CONTROL PEDIATRICO',              9000.00),
	(11, 'TERAPIA ENDOCRINA',              21000.00),
	(12, 'MANEJO NEUROLOGICO',             42000.00);

-- Composicion estandar medicina - tratamiento (RN-07).
-- El tratamiento 12 ahora tiene una medicina asociada.
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
	(10, 3, 180, '2025-05-05', '2025-11-01'),
	(16, 12, 60, '2025-01-10', '2025-03-10');

-- ============================================================================
-- Diagnosticos con costos en bolivares (rango 2.000 - 15.000)
-- ============================================================================
INSERT INTO DIAGN (ID_DIAGN, TIPO, NOMBRE, DESCRIP, COSTO) VALUES
	(1,  'CARDIOVASCULAR',  'HIPERTENSION ARTERIAL',       'TENSION ARTERIAL ELEVADA DE FORMA SOSTENIDA',  6000.00),
	(2,  'ENDOCRINO',       'DIABETES MELLITUS TIPO 2',    'GLICEMIA EN AYUNAS POR ENCIMA DE 126 MG/DL',   7000.00),
	(3,  'RESPIRATORIO',    'ASMA BRONQUIAL',              'OBSTRUCCION REVERSIBLE DE LA VIA AEREA',       5000.00),
	(4,  'DERMATOLOGICO',   'DERMATITIS ATOPICA',          'INFLAMACION CRONICA DE LA PIEL',               4500.00),
	(5,  'GASTROINTESTINAL','GASTRITIS AGUDA',             'INFLAMACION DE LA MUCOSA GASTRICA',            5500.00),
	(6,  'NEUROLOGICO',     'MIGRANA',                     'CEFALEA RECURRENTE CON FOTOFOBIA',             6500.00),
	(7,  'PSIQUIATRICO',    'DEPRESION MAYOR',             'TRASTORNO DEL ESTADO DE ANIMO PERSISTENTE',    8000.00),
	(8,  'TRAUMATOLOGICO',  'FRACTURA DE FEMUR',           'SOLUCION DE CONTINUIDAD OSEA EN FEMUR',       12000.00),
	(9,  'TRAUMATOLOGICO',  'ARTROSIS DE RODILLA',         'DEGENERACION DEL CARTILAGO ARTICULAR',         9500.00),
	(10, 'ENDOCRINO',       'OBESIDAD',                    'INDICE DE MASA CORPORAL MAYOR A 30',           4000.00),
	(11, 'RESPIRATORIO',    'RINOFARINGITIS',              'INFLAMACION DE VIAS AEREAS SUPERIORES',        3500.00),
	(12, 'GASTROINTESTINAL','COLITIS ULCEROSA',            'INFLAMACION CRONICA DEL COLON',                9000.00),
	(13, 'NEUROLOGICO',     'EPILEPSIA',                   'CRISIS CONVULSIVAS RECURRENTES',               11000.00),
	(14, 'PSIQUIATRICO',    'ANSIEDAD GENERALIZADA',       'PREOCUPACION EXCESIVA Y PERSISTENTE',          7500.00),
	(15, 'ONCOLOGICO',      'NEOPLASIA DE MAMA',           'TUMOR MALIGNO EN TEJIDO MAMARIO',             15000.00),
	-- Diagnosticos adicionales para las areas de Cirugia/Obstetricia y
	-- Radioterapia (Fase 4). Se mantiene el rango de costo 2.000-15.000 Bs.
	(16, 'QUIRURGICO',      'APENDICITIS AGUDA',           'INFLAMACION AGUDA DEL APENDICE',              12000.00),
	(17, 'OBSTETRICO',      'EMBARAZO A TERMINO',          'GESTACION A TERMINO PARA ATENCION DEL PARTO',   9000.00),
	(18, 'ONCOLOGICO',      'NEOPLASIA DE PROSTATA',       'TUMOR MALIGNO EN GLANDULA PROSTATICA',        15000.00),
	(19, 'ONCOLOGICO',      'LINFOMA NO HODGKIN',          'PROLIFERACION MALIGNA DE LINFOCITOS',         14000.00),
	-- Diagnosticos adicionales de la Fase 5 para que Cardiologia y Dermatologia
	-- tengan dos diagnosticos compatibles por ingreso.
	(20, 'CARDIOVASCULAR',  'ANGINA DE PECHO ESTABLE',     'DOLOR TORACICO POR ISQUEMIA MIOCARDICA',       8500.00),
	(21, 'DERMATOLOGICO',   'PSORIASIS',                   'PLACAS ESCAMOSAS E INFLAMADAS EN LA PIEL',     9500.00),
	(22, 'OBSTETRICO',      'INFECCION URINARIA',          'INFECCION DE VIAS URINARIAS EN EL EMBARAZO',   6000.00);

-- ============================================================================
-- Intervenciones
-- ============================================================================
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
	(10, 'ARTROSCOPIA',             'TRAUMATOLOGIA'),
	-- Intervenciones adicionales de la Fase 5 para las areas que no tenian
	-- una intervencion compatible (Cardiologia, Endocrinologia, Neurologia,
	-- Pediatria y Psiquiatria).
	(11, 'CATETERISMO CARDIACO',          'CARDIOVASCULAR'),
	(12, 'COLOCACION DE BOMBA DE INSULINA','ENDOCRINOLOGIA'),
	(13, 'BLOQUEO NERVIOSO',              'NEUROLOGIA'),
	(14, 'NEBULIZACION',                  'PEDIATRIA'),
	(15, 'TERAPIA ELECTROCONVULSIVA',     'PSIQUIATRIA');
