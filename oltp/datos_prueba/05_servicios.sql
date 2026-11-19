-- ============================================================================
-- Fase 5 - Servicios clinicos (PostgreSQL)
-- Esquema destino: "OLTP"
--
-- Generado por oltp/datos_prueba/generar_datos.py.
-- No editar a mano: los cambios deben hacerse en el generador.
--
-- Contenido: 120 diagnosticos, 120 prescripciones y 60 intervenciones.
-- Cada ingreso tiene 2 diagnosticos, 2 prescripciones y 1 intervencion.
-- Las fechas quedan dentro de la internacion y los servicios usan
-- medicos y personal del area del ingreso.
--
-- Requiere: 01_catalogos.sql, 02_maestros.sql, 03_polizas.sql
--           y 04_ingresos_ocupaciones.sql.
-- ============================================================================

SET search_path TO "OLTP";

TRUNCATE TABLE "OLTP".FACTURA, "OLTP".REALIZA, "OLTP".PRESCRIBE, "OLTP".PRACTICA CASCADE;

-- ============================================================================
-- Diagnosticos realizados
-- ============================================================================
INSERT INTO REALIZA (CI_MEDICO, CI_PAC, ID_DIAGN, NUMBER_INGRESO, F_ELABORACION) VALUES
	(10000001, 20364201, 1, 5001, '2025-11-01'),  -- ingreso 5001 area 1
	(10000001, 20364201, 20, 5001, '2025-11-02'),  -- ingreso 5001 area 1
	(10000002, 20364208, 17, 5002, '2025-11-03'),  -- ingreso 5002 area 2
	(10000002, 20364208, 22, 5002, '2025-11-04'),  -- ingreso 5002 area 2
	(10000008, 20364214, 7, 5003, '2025-11-05'),  -- ingreso 5003 area 8
	(10000008, 20364214, 14, 5003, '2025-11-06'),  -- ingreso 5003 area 8
	(10000010, 20364221, 8, 5004, '2025-11-07'),  -- ingreso 5004 area 10
	(10000010, 20364221, 9, 5004, '2025-11-08'),  -- ingreso 5004 area 10
	(10000006, 20364231, 13, 5005, '2025-11-09'),  -- ingreso 5005 area 6
	(10000006, 20364231, 6, 5005, '2025-11-10'),  -- ingreso 5005 area 6
	(10000011, 20364201, 1, 5006, '2025-12-01'),  -- ingreso 5006 area 1
	(10000011, 20364201, 20, 5006, '2025-12-02'),  -- ingreso 5006 area 1
	(10000002, 20364208, 17, 5007, '2025-12-03'),  -- ingreso 5007 area 2
	(10000002, 20364208, 22, 5007, '2025-12-04'),  -- ingreso 5007 area 2
	(10000003, 20364215, 4, 5008, '2025-12-05'),  -- ingreso 5008 area 3
	(10000003, 20364215, 21, 5008, '2025-12-06'),  -- ingreso 5008 area 3
	(10000010, 20364222, 9, 5009, '2025-12-07'),  -- ingreso 5009 area 10
	(10000010, 20364222, 8, 5009, '2025-12-08'),  -- ingreso 5009 area 10
	(10000006, 20364232, 6, 5010, '2025-12-09'),  -- ingreso 5010 area 6
	(10000006, 20364232, 13, 5010, '2025-12-10'),  -- ingreso 5010 area 6
	(10000001, 20364201, 1, 5011, '2026-01-01'),  -- ingreso 5011 area 1
	(10000001, 20364201, 20, 5011, '2026-01-02'),  -- ingreso 5011 area 1
	(10000011, 20364209, 1, 5012, '2026-01-03'),  -- ingreso 5012 area 1
	(10000011, 20364209, 20, 5012, '2026-01-04'),  -- ingreso 5012 area 1
	(10000004, 20364216, 2, 5013, '2026-01-05'),  -- ingreso 5013 area 4
	(10000004, 20364216, 10, 5013, '2026-01-06'),  -- ingreso 5013 area 4
	(10000010, 20364223, 8, 5014, '2026-01-07'),  -- ingreso 5014 area 10
	(10000010, 20364223, 9, 5014, '2026-01-08'),  -- ingreso 5014 area 10
	(10000010, 20364233, 9, 5015, '2026-01-09'),  -- ingreso 5015 area 10
	(10000010, 20364233, 8, 5015, '2026-01-10'),  -- ingreso 5015 area 10
	(10000002, 20364202, 17, 5016, '2026-02-01'),  -- ingreso 5016 area 2
	(10000002, 20364202, 22, 5016, '2026-02-02'),  -- ingreso 5016 area 2
	(10000001, 20364209, 1, 5017, '2026-02-03'),  -- ingreso 5017 area 1
	(10000001, 20364209, 20, 5017, '2026-02-04'),  -- ingreso 5017 area 1
	(10000004, 20364216, 2, 5018, '2026-02-05'),  -- ingreso 5018 area 4
	(10000004, 20364216, 10, 5018, '2026-02-06'),  -- ingreso 5018 area 4
	(10000004, 20364224, 2, 5019, '2026-02-07'),  -- ingreso 5019 area 4
	(10000004, 20364224, 10, 5019, '2026-02-08'),  -- ingreso 5019 area 4
	(10000010, 20364233, 9, 5020, '2026-02-09'),  -- ingreso 5020 area 10
	(10000010, 20364233, 8, 5020, '2026-02-10'),  -- ingreso 5020 area 10
	(10000002, 20364202, 17, 5021, '2026-03-01'),  -- ingreso 5021 area 2
	(10000002, 20364202, 22, 5021, '2026-03-02'),  -- ingreso 5021 area 2
	(10000011, 20364209, 1, 5022, '2026-03-03'),  -- ingreso 5022 area 1
	(10000011, 20364209, 20, 5022, '2026-03-04'),  -- ingreso 5022 area 1
	(10000005, 20364217, 5, 5023, '2026-03-05'),  -- ingreso 5023 area 5
	(10000005, 20364217, 12, 5023, '2026-03-06'),  -- ingreso 5023 area 5
	(10000005, 20364225, 12, 5024, '2026-03-07'),  -- ingreso 5024 area 5
	(10000005, 20364225, 5, 5024, '2026-03-08'),  -- ingreso 5024 area 5
	(10000010, 20364233, 9, 5025, '2026-03-09'),  -- ingreso 5025 area 10
	(10000010, 20364233, 8, 5025, '2026-03-10'),  -- ingreso 5025 area 10
	(10000003, 20364203, 4, 5026, '2026-04-01'),  -- ingreso 5026 area 3
	(10000003, 20364203, 21, 5026, '2026-04-02'),  -- ingreso 5026 area 3
	(10000002, 20364210, 17, 5027, '2026-04-03'),  -- ingreso 5027 area 2
	(10000002, 20364210, 22, 5027, '2026-04-04'),  -- ingreso 5027 area 2
	(10000005, 20364217, 5, 5028, '2026-04-05'),  -- ingreso 5028 area 5
	(10000005, 20364217, 12, 5028, '2026-04-06'),  -- ingreso 5028 area 5
	(10000005, 20364225, 12, 5029, '2026-04-07'),  -- ingreso 5029 area 5
	(10000005, 20364225, 5, 5029, '2026-04-08'),  -- ingreso 5029 area 5
	(10000007, 20364234, 11, 5030, '2026-04-09'),  -- ingreso 5030 area 7
	(10000007, 20364234, 3, 5030, '2026-04-10'),  -- ingreso 5030 area 7
	(10000002, 20364204, 17, 5031, '2026-05-01'),  -- ingreso 5031 area 2
	(10000002, 20364204, 22, 5031, '2026-05-02'),  -- ingreso 5031 area 2
	(10000002, 20364210, 17, 5032, '2026-05-03'),  -- ingreso 5032 area 2
	(10000002, 20364210, 22, 5032, '2026-05-04'),  -- ingreso 5032 area 2
	(10000005, 20364217, 5, 5033, '2026-05-05'),  -- ingreso 5033 area 5
	(10000005, 20364217, 12, 5033, '2026-05-06'),  -- ingreso 5033 area 5
	(10000005, 20364225, 12, 5034, '2026-05-07'),  -- ingreso 5034 area 5
	(10000005, 20364225, 5, 5034, '2026-05-08'),  -- ingreso 5034 area 5
	(10000008, 20364235, 7, 5035, '2026-05-09'),  -- ingreso 5035 area 8
	(10000008, 20364235, 14, 5035, '2026-05-10'),  -- ingreso 5035 area 8
	(10000002, 20364204, 17, 5036, '2026-06-01'),  -- ingreso 5036 area 2
	(10000002, 20364204, 22, 5036, '2026-06-02'),  -- ingreso 5036 area 2
	(10000003, 20364211, 4, 5037, '2026-06-03'),  -- ingreso 5037 area 3
	(10000003, 20364211, 21, 5037, '2026-06-04'),  -- ingreso 5037 area 3
	(10000004, 20364218, 10, 5038, '2026-06-05'),  -- ingreso 5038 area 4
	(10000004, 20364218, 2, 5038, '2026-06-06'),  -- ingreso 5038 area 4
	(10000005, 20364226, 5, 5039, '2026-06-07'),  -- ingreso 5039 area 5
	(10000005, 20364226, 12, 5039, '2026-06-08'),  -- ingreso 5039 area 5
	(10000008, 20364236, 14, 5040, '2026-06-09'),  -- ingreso 5040 area 8
	(10000008, 20364236, 7, 5040, '2026-06-10'),  -- ingreso 5040 area 8
	(10000001, 20364205, 1, 5041, '2026-07-01'),  -- ingreso 5041 area 1
	(10000001, 20364205, 20, 5041, '2026-07-02'),  -- ingreso 5041 area 1
	(10000004, 20364212, 2, 5042, '2026-07-03'),  -- ingreso 5042 area 4
	(10000004, 20364212, 10, 5042, '2026-07-04'),  -- ingreso 5042 area 4
	(10000004, 20364218, 10, 5043, '2026-07-05'),  -- ingreso 5043 area 4
	(10000004, 20364218, 2, 5043, '2026-07-06'),  -- ingreso 5043 area 4
	(10000012, 20364227, 3, 5044, '2026-07-07'),  -- ingreso 5044 area 7
	(10000012, 20364227, 11, 5044, '2026-07-08'),  -- ingreso 5044 area 7
	(10000009, 20364237, 18, 5045, '2026-07-09'),  -- ingreso 5045 area 9
	(10000009, 20364237, 19, 5045, '2026-07-10'),  -- ingreso 5045 area 9
	(10000002, 20364206, 17, 5046, '2026-08-01'),  -- ingreso 5046 area 2
	(10000002, 20364206, 22, 5046, '2026-08-02'),  -- ingreso 5046 area 2
	(10000004, 20364212, 2, 5047, '2026-08-03'),  -- ingreso 5047 area 4
	(10000004, 20364212, 10, 5047, '2026-08-04'),  -- ingreso 5047 area 4
	(10000009, 20364219, 19, 5048, '2026-08-05'),  -- ingreso 5048 area 9
	(10000009, 20364219, 18, 5048, '2026-08-06'),  -- ingreso 5048 area 9
	(10000006, 20364228, 6, 5049, '2026-08-07'),  -- ingreso 5049 area 6
	(10000006, 20364228, 13, 5049, '2026-08-08'),  -- ingreso 5049 area 6
	(10000007, 20364238, 3, 5050, '2026-08-09'),  -- ingreso 5050 area 7
	(10000007, 20364238, 11, 5050, '2026-08-10'),  -- ingreso 5050 area 7
	(10000002, 20364206, 17, 5051, '2026-09-01'),  -- ingreso 5051 area 2
	(10000002, 20364206, 22, 5051, '2026-09-02'),  -- ingreso 5051 area 2
	(10000011, 20364213, 1, 5052, '2026-09-03'),  -- ingreso 5052 area 1
	(10000011, 20364213, 20, 5052, '2026-09-04'),  -- ingreso 5052 area 1
	(10000009, 20364220, 15, 5053, '2026-09-05'),  -- ingreso 5053 area 9
	(10000009, 20364220, 19, 5053, '2026-09-06'),  -- ingreso 5053 area 9
	(10000006, 20364229, 13, 5054, '2026-09-07'),  -- ingreso 5054 area 6
	(10000006, 20364229, 6, 5054, '2026-09-08'),  -- ingreso 5054 area 6
	(10000008, 20364239, 14, 5055, '2026-09-09'),  -- ingreso 5055 area 8
	(10000008, 20364239, 7, 5055, '2026-09-10'),  -- ingreso 5055 area 8
	(10000003, 20364207, 4, 5056, '2026-10-05'),  -- ingreso 5056 area 3
	(10000003, 20364207, 21, 5056, '2026-10-06'),  -- ingreso 5056 area 3
	(10000008, 20364214, 7, 5057, '2026-10-22'),  -- ingreso 5057 area 8
	(10000008, 20364214, 14, 5057, '2026-10-23'),  -- ingreso 5057 area 8
	(10000009, 20364220, 15, 5058, '2026-10-24'),  -- ingreso 5058 area 9
	(10000009, 20364220, 19, 5058, '2026-10-25'),  -- ingreso 5058 area 9
	(10000012, 20364230, 3, 5059, '2026-10-26'),  -- ingreso 5059 area 7
	(10000012, 20364230, 11, 5059, '2026-10-27'),  -- ingreso 5059 area 7
	(10000007, 20364240, 11, 5060, '2026-10-28'),  -- ingreso 5060 area 7
	(10000007, 20364240, 3, 5060, '2026-10-29');  -- ingreso 5060 area 7

-- ============================================================================
-- Prescripciones
-- ============================================================================
INSERT INTO PRESCRIBE (CI_MEDICO, CI_PAC, ID_TRATAMIENTO, NUMBER_INGRESO, F_ELABORACION, F_INICIO, F_FIN, CANT_DIAS, DOSIS_DIARIA) VALUES
	(10000001, 20364201, 1, 5001, '2025-11-01', '2025-11-01', '2025-11-02', 2, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5001 area 1 tratamiento 1
	(10000001, 20364201, 1, 5001, '2025-11-02', '2025-11-02', '2025-11-02', 1, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5001 area 1 tratamiento 1
	(10000002, 20364208, 2, 5002, '2025-11-03', '2025-11-03', '2025-11-08', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5002 area 2 tratamiento 2
	(10000002, 20364208, 2, 5002, '2025-11-04', '2025-11-04', '2025-11-06', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5002 area 2 tratamiento 2
	(10000008, 20364214, 7, 5003, '2025-11-05', '2025-11-05', '2025-11-09', 5, '1 TABLETA AL DIA'),  -- ingreso 5003 area 8 tratamiento 7
	(10000008, 20364214, 7, 5003, '2025-11-06', '2025-11-06', '2025-11-11', 6, '1 TABLETA AL DIA'),  -- ingreso 5003 area 8 tratamiento 7
	(10000010, 20364221, 8, 5004, '2025-11-07', '2025-11-07', '2025-11-11', 5, '1 TABLETA CADA 8 HORAS'),  -- ingreso 5004 area 10 tratamiento 8
	(10000010, 20364221, 2, 5004, '2025-11-08', '2025-11-08', '2025-11-13', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5004 area 10 tratamiento 2
	(10000006, 20364231, 12, 5005, '2025-11-09', '2025-11-09', '2025-11-12', 4, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5005 area 6 tratamiento 12
	(10000006, 20364231, 12, 5005, '2025-11-10', '2025-11-10', '2025-11-14', 5, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5005 area 6 tratamiento 12
	(10000011, 20364201, 1, 5006, '2025-12-01', '2025-12-01', '2025-12-03', 3, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5006 area 1 tratamiento 1
	(10000011, 20364201, 1, 5006, '2025-12-02', '2025-12-02', '2025-12-03', 2, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5006 area 1 tratamiento 1
	(10000002, 20364208, 2, 5007, '2025-12-03', '2025-12-03', '2025-12-04', 2, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5007 area 2 tratamiento 2
	(10000002, 20364208, 2, 5007, '2025-12-04', '2025-12-04', '2025-12-04', 1, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5007 area 2 tratamiento 2
	(10000003, 20364215, 5, 5008, '2025-12-05', '2025-12-05', '2025-12-07', 3, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5008 area 3 tratamiento 5
	(10000003, 20364215, 2, 5008, '2025-12-06', '2025-12-06', '2025-12-09', 4, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5008 area 3 tratamiento 2
	(10000010, 20364222, 8, 5009, '2025-12-07', '2025-12-07', '2025-12-09', 3, '1 TABLETA CADA 8 HORAS'),  -- ingreso 5009 area 10 tratamiento 8
	(10000010, 20364222, 2, 5009, '2025-12-08', '2025-12-08', '2025-12-11', 4, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5009 area 10 tratamiento 2
	(10000006, 20364232, 12, 5010, '2025-12-09', '2025-12-09', '2025-12-10', 2, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5010 area 6 tratamiento 12
	(10000006, 20364232, 12, 5010, '2025-12-10', '2025-12-10', '2025-12-10', 1, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5010 area 6 tratamiento 12
	(10000001, 20364201, 1, 5011, '2026-01-01', '2026-01-01', '2026-01-04', 4, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5011 area 1 tratamiento 1
	(10000001, 20364201, 1, 5011, '2026-01-02', '2026-01-02', '2026-01-04', 3, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5011 area 1 tratamiento 1
	(10000011, 20364209, 1, 5012, '2026-01-03', '2026-01-03', '2026-01-06', 4, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5012 area 1 tratamiento 1
	(10000011, 20364209, 1, 5012, '2026-01-04', '2026-01-04', '2026-01-06', 3, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5012 area 1 tratamiento 1
	(10000004, 20364216, 3, 5013, '2026-01-05', '2026-01-05', '2026-01-07', 3, '1 TABLETA CON CADA COMIDA'),  -- ingreso 5013 area 4 tratamiento 3
	(10000004, 20364216, 11, 5013, '2026-01-06', '2026-01-06', '2026-01-07', 2, '1 TABLETA EN AYUNAS'),  -- ingreso 5013 area 4 tratamiento 11
	(10000010, 20364223, 8, 5014, '2026-01-07', '2026-01-07', '2026-01-08', 2, '1 TABLETA CADA 8 HORAS'),  -- ingreso 5014 area 10 tratamiento 8
	(10000010, 20364223, 2, 5014, '2026-01-08', '2026-01-08', '2026-01-08', 1, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5014 area 10 tratamiento 2
	(10000010, 20364233, 8, 5015, '2026-01-09', '2026-01-09', '2026-01-12', 4, '1 TABLETA CADA 8 HORAS'),  -- ingreso 5015 area 10 tratamiento 8
	(10000010, 20364233, 2, 5015, '2026-01-10', '2026-01-10', '2026-01-12', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5015 area 10 tratamiento 2
	(10000002, 20364202, 2, 5016, '2026-02-01', '2026-02-01', '2026-02-06', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5016 area 2 tratamiento 2
	(10000002, 20364202, 2, 5016, '2026-02-02', '2026-02-02', '2026-02-04', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5016 area 2 tratamiento 2
	(10000001, 20364209, 1, 5017, '2026-02-03', '2026-02-03', '2026-02-07', 5, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5017 area 1 tratamiento 1
	(10000001, 20364209, 1, 5017, '2026-02-04', '2026-02-04', '2026-02-06', 3, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5017 area 1 tratamiento 1
	(10000004, 20364216, 3, 5018, '2026-02-05', '2026-02-05', '2026-02-08', 4, '1 TABLETA CON CADA COMIDA'),  -- ingreso 5018 area 4 tratamiento 3
	(10000004, 20364216, 11, 5018, '2026-02-06', '2026-02-06', '2026-02-08', 3, '1 TABLETA EN AYUNAS'),  -- ingreso 5018 area 4 tratamiento 11
	(10000004, 20364224, 3, 5019, '2026-02-07', '2026-02-07', '2026-02-09', 3, '1 TABLETA CON CADA COMIDA'),  -- ingreso 5019 area 4 tratamiento 3
	(10000004, 20364224, 11, 5019, '2026-02-08', '2026-02-08', '2026-02-10', 3, '1 TABLETA EN AYUNAS'),  -- ingreso 5019 area 4 tratamiento 11
	(10000010, 20364233, 8, 5020, '2026-02-09', '2026-02-09', '2026-02-13', 5, '1 TABLETA CADA 8 HORAS'),  -- ingreso 5020 area 10 tratamiento 8
	(10000010, 20364233, 2, 5020, '2026-02-10', '2026-02-10', '2026-02-13', 4, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5020 area 10 tratamiento 2
	(10000002, 20364202, 2, 5021, '2026-03-01', '2026-03-01', '2026-03-03', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5021 area 2 tratamiento 2
	(10000002, 20364202, 2, 5021, '2026-03-02', '2026-03-02', '2026-03-05', 4, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5021 area 2 tratamiento 2
	(10000011, 20364209, 1, 5022, '2026-03-03', '2026-03-03', '2026-03-05', 3, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5022 area 1 tratamiento 1
	(10000011, 20364209, 1, 5022, '2026-03-04', '2026-03-04', '2026-03-07', 4, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5022 area 1 tratamiento 1
	(10000005, 20364217, 6, 5023, '2026-03-05', '2026-03-05', '2026-03-08', 4, '1 CAPSULA EN AYUNAS'),  -- ingreso 5023 area 5 tratamiento 6
	(10000005, 20364217, 2, 5023, '2026-03-06', '2026-03-06', '2026-03-10', 5, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5023 area 5 tratamiento 2
	(10000005, 20364225, 6, 5024, '2026-03-07', '2026-03-07', '2026-03-11', 5, '1 CAPSULA EN AYUNAS'),  -- ingreso 5024 area 5 tratamiento 6
	(10000005, 20364225, 2, 5024, '2026-03-08', '2026-03-08', '2026-03-12', 5, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5024 area 5 tratamiento 2
	(10000010, 20364233, 8, 5025, '2026-03-09', '2026-03-09', '2026-03-14', 6, '1 TABLETA CADA 8 HORAS'),  -- ingreso 5025 area 10 tratamiento 8
	(10000010, 20364233, 2, 5025, '2026-03-10', '2026-03-10', '2026-03-12', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5025 area 10 tratamiento 2
	(10000003, 20364203, 5, 5026, '2026-04-01', '2026-04-01', '2026-04-05', 5, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5026 area 3 tratamiento 5
	(10000003, 20364203, 2, 5026, '2026-04-02', '2026-04-02', '2026-04-07', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5026 area 3 tratamiento 2
	(10000002, 20364210, 2, 5027, '2026-04-03', '2026-04-03', '2026-04-07', 5, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5027 area 2 tratamiento 2
	(10000002, 20364210, 2, 5027, '2026-04-04', '2026-04-04', '2026-04-09', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5027 area 2 tratamiento 2
	(10000005, 20364217, 6, 5028, '2026-04-05', '2026-04-05', '2026-04-09', 5, '1 CAPSULA EN AYUNAS'),  -- ingreso 5028 area 5 tratamiento 6
	(10000005, 20364217, 2, 5028, '2026-04-06', '2026-04-06', '2026-04-11', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5028 area 5 tratamiento 2
	(10000005, 20364225, 6, 5029, '2026-04-07', '2026-04-07', '2026-04-12', 6, '1 CAPSULA EN AYUNAS'),  -- ingreso 5029 area 5 tratamiento 6
	(10000005, 20364225, 2, 5029, '2026-04-08', '2026-04-08', '2026-04-10', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5029 area 5 tratamiento 2
	(10000007, 20364234, 10, 5030, '2026-04-09', '2026-04-09', '2026-04-12', 4, '5 ML CADA 6 HORAS'),  -- ingreso 5030 area 7 tratamiento 10
	(10000007, 20364234, 4, 5030, '2026-04-10', '2026-04-10', '2026-04-14', 5, '2 INHALACIONES CADA 6 HORAS'),  -- ingreso 5030 area 7 tratamiento 4
	(10000002, 20364204, 2, 5031, '2026-05-01', '2026-05-01', '2026-05-02', 2, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5031 area 2 tratamiento 2
	(10000002, 20364204, 2, 5031, '2026-05-02', '2026-05-02', '2026-05-02', 1, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5031 area 2 tratamiento 2
	(10000002, 20364210, 2, 5032, '2026-05-03', '2026-05-03', '2026-05-08', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5032 area 2 tratamiento 2
	(10000002, 20364210, 2, 5032, '2026-05-04', '2026-05-04', '2026-05-06', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5032 area 2 tratamiento 2
	(10000005, 20364217, 6, 5033, '2026-05-05', '2026-05-05', '2026-05-10', 6, '1 CAPSULA EN AYUNAS'),  -- ingreso 5033 area 5 tratamiento 6
	(10000005, 20364217, 2, 5033, '2026-05-06', '2026-05-06', '2026-05-08', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5033 area 5 tratamiento 2
	(10000005, 20364225, 6, 5034, '2026-05-07', '2026-05-07', '2026-05-09', 3, '1 CAPSULA EN AYUNAS'),  -- ingreso 5034 area 5 tratamiento 6
	(10000005, 20364225, 2, 5034, '2026-05-08', '2026-05-08', '2026-05-11', 4, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5034 area 5 tratamiento 2
	(10000008, 20364235, 7, 5035, '2026-05-09', '2026-05-09', '2026-05-14', 6, '1 TABLETA AL DIA'),  -- ingreso 5035 area 8 tratamiento 7
	(10000008, 20364235, 7, 5035, '2026-05-10', '2026-05-10', '2026-05-12', 3, '1 TABLETA AL DIA'),  -- ingreso 5035 area 8 tratamiento 7
	(10000002, 20364204, 2, 5036, '2026-06-01', '2026-06-01', '2026-06-03', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5036 area 2 tratamiento 2
	(10000002, 20364204, 2, 5036, '2026-06-02', '2026-06-02', '2026-06-03', 2, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5036 area 2 tratamiento 2
	(10000003, 20364211, 5, 5037, '2026-06-03', '2026-06-03', '2026-06-04', 2, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5037 area 3 tratamiento 5
	(10000003, 20364211, 2, 5037, '2026-06-04', '2026-06-04', '2026-06-04', 1, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5037 area 3 tratamiento 2
	(10000004, 20364218, 11, 5038, '2026-06-05', '2026-06-05', '2026-06-08', 4, '1 TABLETA EN AYUNAS'),  -- ingreso 5038 area 4 tratamiento 11
	(10000004, 20364218, 3, 5038, '2026-06-06', '2026-06-06', '2026-06-10', 5, '1 TABLETA CON CADA COMIDA'),  -- ingreso 5038 area 4 tratamiento 3
	(10000005, 20364226, 6, 5039, '2026-06-07', '2026-06-07', '2026-06-11', 5, '1 CAPSULA EN AYUNAS'),  -- ingreso 5039 area 5 tratamiento 6
	(10000005, 20364226, 2, 5039, '2026-06-08', '2026-06-08', '2026-06-13', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5039 area 5 tratamiento 2
	(10000008, 20364236, 7, 5040, '2026-06-09', '2026-06-09', '2026-06-11', 3, '1 TABLETA AL DIA'),  -- ingreso 5040 area 8 tratamiento 7
	(10000008, 20364236, 7, 5040, '2026-06-10', '2026-06-10', '2026-06-11', 2, '1 TABLETA AL DIA'),  -- ingreso 5040 area 8 tratamiento 7
	(10000001, 20364205, 1, 5041, '2026-07-01', '2026-07-01', '2026-07-05', 5, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5041 area 1 tratamiento 1
	(10000001, 20364205, 1, 5041, '2026-07-02', '2026-07-02', '2026-07-04', 3, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5041 area 1 tratamiento 1
	(10000004, 20364212, 3, 5042, '2026-07-03', '2026-07-03', '2026-07-06', 4, '1 TABLETA CON CADA COMIDA'),  -- ingreso 5042 area 4 tratamiento 3
	(10000004, 20364212, 11, 5042, '2026-07-04', '2026-07-04', '2026-07-06', 3, '1 TABLETA EN AYUNAS'),  -- ingreso 5042 area 4 tratamiento 11
	(10000004, 20364218, 11, 5043, '2026-07-05', '2026-07-05', '2026-07-06', 2, '1 TABLETA EN AYUNAS'),  -- ingreso 5043 area 4 tratamiento 11
	(10000004, 20364218, 3, 5043, '2026-07-06', '2026-07-06', '2026-07-06', 1, '1 TABLETA CON CADA COMIDA'),  -- ingreso 5043 area 4 tratamiento 3
	(10000012, 20364227, 4, 5044, '2026-07-07', '2026-07-07', '2026-07-09', 3, '2 INHALACIONES CADA 6 HORAS'),  -- ingreso 5044 area 7 tratamiento 4
	(10000012, 20364227, 10, 5044, '2026-07-08', '2026-07-08', '2026-07-09', 2, '5 ML CADA 6 HORAS'),  -- ingreso 5044 area 7 tratamiento 10
	(10000009, 20364237, 9, 5045, '2026-07-09', '2026-07-09', '2026-07-13', 5, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5045 area 9 tratamiento 9
	(10000009, 20364237, 9, 5045, '2026-07-10', '2026-07-10', '2026-07-12', 3, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5045 area 9 tratamiento 9
	(10000002, 20364206, 2, 5046, '2026-08-01', '2026-08-01', '2026-08-04', 4, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5046 area 2 tratamiento 2
	(10000002, 20364206, 2, 5046, '2026-08-02', '2026-08-02', '2026-08-06', 5, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5046 area 2 tratamiento 2
	(10000004, 20364212, 3, 5047, '2026-08-03', '2026-08-03', '2026-08-05', 3, '1 TABLETA CON CADA COMIDA'),  -- ingreso 5047 area 4 tratamiento 3
	(10000004, 20364212, 11, 5047, '2026-08-04', '2026-08-04', '2026-08-07', 4, '1 TABLETA EN AYUNAS'),  -- ingreso 5047 area 4 tratamiento 11
	(10000009, 20364219, 9, 5048, '2026-08-05', '2026-08-05', '2026-08-07', 3, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5048 area 9 tratamiento 9
	(10000009, 20364219, 9, 5048, '2026-08-06', '2026-08-06', '2026-08-08', 3, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5048 area 9 tratamiento 9
	(10000006, 20364228, 12, 5049, '2026-08-07', '2026-08-07', '2026-08-11', 5, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5049 area 6 tratamiento 12
	(10000006, 20364228, 12, 5049, '2026-08-08', '2026-08-08', '2026-08-11', 4, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5049 area 6 tratamiento 12
	(10000007, 20364238, 4, 5050, '2026-08-09', '2026-08-09', '2026-08-12', 4, '2 INHALACIONES CADA 6 HORAS'),  -- ingreso 5050 area 7 tratamiento 4
	(10000007, 20364238, 10, 5050, '2026-08-10', '2026-08-10', '2026-08-14', 5, '5 ML CADA 6 HORAS'),  -- ingreso 5050 area 7 tratamiento 10
	(10000002, 20364206, 2, 5051, '2026-09-01', '2026-09-01', '2026-09-05', 5, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5051 area 2 tratamiento 2
	(10000002, 20364206, 2, 5051, '2026-09-02', '2026-09-02', '2026-09-07', 6, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5051 area 2 tratamiento 2
	(10000011, 20364213, 1, 5052, '2026-09-03', '2026-09-03', '2026-09-07', 5, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5052 area 1 tratamiento 1
	(10000011, 20364213, 1, 5052, '2026-09-04', '2026-09-04', '2026-09-09', 6, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5052 area 1 tratamiento 1
	(10000009, 20364220, 9, 5053, '2026-09-05', '2026-09-05', '2026-09-09', 5, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5053 area 9 tratamiento 9
	(10000009, 20364220, 9, 5053, '2026-09-06', '2026-09-06', '2026-09-10', 5, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5053 area 9 tratamiento 9
	(10000006, 20364229, 12, 5054, '2026-09-07', '2026-09-07', '2026-09-09', 3, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5054 area 6 tratamiento 12
	(10000006, 20364229, 12, 5054, '2026-09-08', '2026-09-08', '2026-09-11', 4, '1 TABLETA CADA 12 HORAS'),  -- ingreso 5054 area 6 tratamiento 12
	(10000008, 20364239, 7, 5055, '2026-09-09', '2026-09-09', '2026-09-14', 6, '1 TABLETA AL DIA'),  -- ingreso 5055 area 8 tratamiento 7
	(10000008, 20364239, 7, 5055, '2026-09-10', '2026-09-10', '2026-09-12', 3, '1 TABLETA AL DIA'),  -- ingreso 5055 area 8 tratamiento 7
	(10000003, 20364207, 5, 5056, '2026-10-05', '2026-10-05', '2026-10-07', 3, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5056 area 3 tratamiento 5
	(10000003, 20364207, 2, 5056, '2026-10-06', '2026-10-06', '2026-10-08', 3, '1 CAPSULA CADA 8 HORAS POR 7 DIAS'),  -- ingreso 5056 area 3 tratamiento 2
	(10000008, 20364214, 7, 5057, '2026-10-22', '2026-10-22', '2026-10-24', 3, '1 TABLETA AL DIA'),  -- ingreso 5057 area 8 tratamiento 7
	(10000008, 20364214, 7, 5057, '2026-10-23', '2026-10-23', '2026-10-26', 4, '1 TABLETA AL DIA'),  -- ingreso 5057 area 8 tratamiento 7
	(10000009, 20364220, 9, 5058, '2026-10-24', '2026-10-24', '2026-10-29', 6, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5058 area 9 tratamiento 9
	(10000009, 20364220, 9, 5058, '2026-10-25', '2026-10-25', '2026-10-27', 3, '1 AMPOLLA CADA 12 HORAS'),  -- ingreso 5058 area 9 tratamiento 9
	(10000012, 20364230, 4, 5059, '2026-10-26', '2026-10-26', '2026-10-30', 5, '2 INHALACIONES CADA 6 HORAS'),  -- ingreso 5059 area 7 tratamiento 4
	(10000012, 20364230, 10, 5059, '2026-10-27', '2026-10-27', '2026-10-31', 5, '5 ML CADA 6 HORAS'),  -- ingreso 5059 area 7 tratamiento 10
	(10000007, 20364240, 10, 5060, '2026-10-28', '2026-10-28', '2026-10-31', 4, '5 ML CADA 6 HORAS'),  -- ingreso 5060 area 7 tratamiento 10
	(10000007, 20364240, 4, 5060, '2026-10-29', '2026-10-29', '2026-10-31', 3, '2 INHALACIONES CADA 6 HORAS');  -- ingreso 5060 area 7 tratamiento 4

-- ============================================================================
-- Intervenciones
-- ============================================================================
INSERT INTO PRACTICA (CI_MEDICO, CI_PAC, ID_INTERVENCION, CI_PERSONAL_SANITARIO, F, RIESGO, DURACION, GASTO_EQUIPOS, COSTO, HONORARIO_EQUIPO, NUMBER_INGRESO) VALUES
	(10000001, 20364201, 11, 15000001, '2025-11-02', 'ALTO', 90, 6000.00, 40000.00, 8000.00, 5001),  -- ingreso 5001 area 1 intervencion 11
	(10000002, 20364208, 3, 15000003, '2025-11-04', 'ALTO', 60, 5400.00, 36000.00, 7200.00, 5002),  -- ingreso 5002 area 2 intervencion 3
	(10000008, 20364214, 15, 15000010, '2025-11-06', 'MEDIO', 60, 2700.00, 18000.00, 3600.00, 5003),  -- ingreso 5003 area 8 intervencion 15
	(10000010, 20364221, 4, 15000012, '2025-11-08', 'MEDIO', 90, 4350.00, 29000.00, 5800.00, 5004),  -- ingreso 5004 area 10 intervencion 4
	(10000006, 20364231, 13, 15000008, '2025-11-10', 'BAJO', 30, 1575.00, 10500.00, 2100.00, 5005),  -- ingreso 5005 area 6 intervencion 13
	(10000011, 20364201, 11, 15000001, '2025-12-02', 'ALTO', 90, 6150.00, 41000.00, 8200.00, 5006),  -- ingreso 5006 area 1 intervencion 11
	(10000002, 20364208, 3, 15000003, '2025-12-04', 'ALTO', 60, 5325.00, 35500.00, 7100.00, 5007),  -- ingreso 5007 area 2 intervencion 3
	(10000003, 20364215, 5, 15000005, '2025-12-06', 'BAJO', 30, 900.00, 6000.00, 1200.00, 5008),  -- ingreso 5008 area 3 intervencion 5
	(10000010, 20364222, 10, 15000012, '2025-12-08', 'MEDIO', 60, 3450.00, 23000.00, 4600.00, 5009),  -- ingreso 5009 area 10 intervencion 10
	(10000006, 20364232, 13, 15000008, '2025-12-10', 'BAJO', 30, 1575.00, 10500.00, 2100.00, 5010),  -- ingreso 5010 area 6 intervencion 13
	(10000001, 20364201, 11, 15000001, '2026-01-02', 'ALTO', 90, 6075.00, 40500.00, 8100.00, 5011),  -- ingreso 5011 area 1 intervencion 11
	(10000011, 20364209, 11, 15000001, '2026-01-04', 'ALTO', 90, 6075.00, 40500.00, 8100.00, 5012),  -- ingreso 5012 area 1 intervencion 11
	(10000004, 20364216, 12, 15000006, '2026-01-06', 'MEDIO', 45, 2250.00, 15000.00, 3000.00, 5013),  -- ingreso 5013 area 4 intervencion 12
	(10000010, 20364223, 4, 15000012, '2026-01-08', 'MEDIO', 90, 4350.00, 29000.00, 5800.00, 5014),  -- ingreso 5014 area 10 intervencion 4
	(10000010, 20364233, 10, 15000012, '2026-01-10', 'MEDIO', 60, 3375.00, 22500.00, 4500.00, 5015),  -- ingreso 5015 area 10 intervencion 10
	(10000002, 20364202, 3, 15000003, '2026-02-02', 'ALTO', 60, 5325.00, 35500.00, 7100.00, 5016),  -- ingreso 5016 area 2 intervencion 3
	(10000001, 20364209, 11, 15000001, '2026-02-04', 'ALTO', 90, 6000.00, 40000.00, 8000.00, 5017),  -- ingreso 5017 area 1 intervencion 11
	(10000004, 20364216, 12, 15000006, '2026-02-06', 'MEDIO', 45, 2400.00, 16000.00, 3200.00, 5018),  -- ingreso 5018 area 4 intervencion 12
	(10000004, 20364224, 12, 15000006, '2026-02-08', 'MEDIO', 45, 2400.00, 16000.00, 3200.00, 5019),  -- ingreso 5019 area 4 intervencion 12
	(10000010, 20364233, 10, 15000012, '2026-02-10', 'MEDIO', 60, 3300.00, 22000.00, 4400.00, 5020),  -- ingreso 5020 area 10 intervencion 10
	(10000002, 20364202, 3, 15000003, '2026-03-02', 'ALTO', 60, 5250.00, 35000.00, 7000.00, 5021),  -- ingreso 5021 area 2 intervencion 3
	(10000011, 20364209, 11, 15000001, '2026-03-04', 'ALTO', 90, 6150.00, 41000.00, 8200.00, 5022),  -- ingreso 5022 area 1 intervencion 11
	(10000005, 20364217, 6, 15000007, '2026-03-06', 'MEDIO', 45, 1950.00, 13000.00, 2600.00, 5023),  -- ingreso 5023 area 5 intervencion 6
	(10000005, 20364225, 6, 15000007, '2026-03-08', 'MEDIO', 45, 1950.00, 13000.00, 2600.00, 5024),  -- ingreso 5024 area 5 intervencion 6
	(10000010, 20364233, 10, 15000012, '2026-03-10', 'MEDIO', 60, 3450.00, 23000.00, 4600.00, 5025),  -- ingreso 5025 area 10 intervencion 10
	(10000003, 20364203, 5, 15000005, '2026-04-02', 'BAJO', 30, 900.00, 6000.00, 1200.00, 5026),  -- ingreso 5026 area 3 intervencion 5
	(10000002, 20364210, 3, 15000003, '2026-04-04', 'ALTO', 60, 5400.00, 36000.00, 7200.00, 5027),  -- ingreso 5027 area 2 intervencion 3
	(10000005, 20364217, 6, 15000007, '2026-04-06', 'MEDIO', 45, 1875.00, 12500.00, 2500.00, 5028),  -- ingreso 5028 area 5 intervencion 6
	(10000005, 20364225, 6, 15000007, '2026-04-08', 'MEDIO', 45, 1875.00, 12500.00, 2500.00, 5029),  -- ingreso 5029 area 5 intervencion 6
	(10000007, 20364234, 14, 15000009, '2026-04-10', 'BAJO', 20, 675.00, 4500.00, 900.00, 5030),  -- ingreso 5030 area 7 intervencion 14
	(10000002, 20364204, 3, 15000003, '2026-05-02', 'ALTO', 60, 5250.00, 35000.00, 7000.00, 5031),  -- ingreso 5031 area 2 intervencion 3
	(10000002, 20364210, 3, 15000003, '2026-05-04', 'ALTO', 60, 5325.00, 35500.00, 7100.00, 5032),  -- ingreso 5032 area 2 intervencion 3
	(10000005, 20364217, 6, 15000007, '2026-05-06', 'MEDIO', 45, 1800.00, 12000.00, 2400.00, 5033),  -- ingreso 5033 area 5 intervencion 6
	(10000005, 20364225, 6, 15000007, '2026-05-08', 'MEDIO', 45, 1800.00, 12000.00, 2400.00, 5034),  -- ingreso 5034 area 5 intervencion 6
	(10000008, 20364235, 15, 15000010, '2026-05-10', 'MEDIO', 60, 2850.00, 19000.00, 3800.00, 5035),  -- ingreso 5035 area 8 intervencion 15
	(10000002, 20364204, 3, 15000003, '2026-06-02', 'ALTO', 60, 5400.00, 36000.00, 7200.00, 5036),  -- ingreso 5036 area 2 intervencion 3
	(10000003, 20364211, 5, 15000005, '2026-06-04', 'BAJO', 30, 975.00, 6500.00, 1300.00, 5037),  -- ingreso 5037 area 3 intervencion 5
	(10000004, 20364218, 12, 15000006, '2026-06-06', 'MEDIO', 45, 2250.00, 15000.00, 3000.00, 5038),  -- ingreso 5038 area 4 intervencion 12
	(10000005, 20364226, 6, 15000007, '2026-06-08', 'MEDIO', 45, 1800.00, 12000.00, 2400.00, 5039),  -- ingreso 5039 area 5 intervencion 6
	(10000008, 20364236, 15, 15000010, '2026-06-10', 'MEDIO', 60, 2850.00, 19000.00, 3800.00, 5040),  -- ingreso 5040 area 8 intervencion 15
	(10000001, 20364205, 11, 15000001, '2026-07-02', 'ALTO', 90, 6150.00, 41000.00, 8200.00, 5041),  -- ingreso 5041 area 1 intervencion 11
	(10000004, 20364212, 12, 15000006, '2026-07-04', 'MEDIO', 45, 2325.00, 15500.00, 3100.00, 5042),  -- ingreso 5042 area 4 intervencion 12
	(10000004, 20364218, 12, 15000006, '2026-07-06', 'MEDIO', 45, 2400.00, 16000.00, 3200.00, 5043),  -- ingreso 5043 area 4 intervencion 12
	(10000012, 20364227, 14, 15000009, '2026-07-08', 'BAJO', 20, 525.00, 3500.00, 700.00, 5044),  -- ingreso 5044 area 7 intervencion 14
	(10000009, 20364237, 8, 15000011, '2026-07-10', 'ALTO', 180, 8400.00, 56000.00, 11200.00, 5045),  -- ingreso 5045 area 9 intervencion 8
	(10000002, 20364206, 3, 15000003, '2026-08-02', 'ALTO', 60, 5400.00, 36000.00, 7200.00, 5046),  -- ingreso 5046 area 2 intervencion 3
	(10000004, 20364212, 12, 15000006, '2026-08-04', 'MEDIO', 45, 2250.00, 15000.00, 3000.00, 5047),  -- ingreso 5047 area 4 intervencion 12
	(10000009, 20364219, 8, 15000011, '2026-08-06', 'ALTO', 180, 8400.00, 56000.00, 11200.00, 5048),  -- ingreso 5048 area 9 intervencion 8
	(10000006, 20364228, 13, 15000008, '2026-08-08', 'BAJO', 30, 1500.00, 10000.00, 2000.00, 5049),  -- ingreso 5049 area 6 intervencion 13
	(10000007, 20364238, 14, 15000009, '2026-08-10', 'BAJO', 20, 675.00, 4500.00, 900.00, 5050),  -- ingreso 5050 area 7 intervencion 14
	(10000002, 20364206, 3, 15000003, '2026-09-02', 'ALTO', 60, 5325.00, 35500.00, 7100.00, 5051),  -- ingreso 5051 area 2 intervencion 3
	(10000011, 20364213, 11, 15000001, '2026-09-04', 'ALTO', 90, 6000.00, 40000.00, 8000.00, 5052),  -- ingreso 5052 area 1 intervencion 11
	(10000009, 20364220, 8, 15000011, '2026-09-06', 'ALTO', 180, 8400.00, 56000.00, 11200.00, 5053),  -- ingreso 5053 area 9 intervencion 8
	(10000006, 20364229, 13, 15000008, '2026-09-08', 'BAJO', 30, 1500.00, 10000.00, 2000.00, 5054),  -- ingreso 5054 area 6 intervencion 13
	(10000008, 20364239, 15, 15000010, '2026-09-10', 'MEDIO', 60, 2850.00, 19000.00, 3800.00, 5055),  -- ingreso 5055 area 8 intervencion 15
	(10000003, 20364207, 5, 15000005, '2026-10-06', 'BAJO', 30, 975.00, 6500.00, 1300.00, 5056),  -- ingreso 5056 area 3 intervencion 5
	(10000008, 20364214, 15, 15000010, '2026-10-23', 'MEDIO', 60, 2700.00, 18000.00, 3600.00, 5057),  -- ingreso 5057 area 8 intervencion 15
	(10000009, 20364220, 8, 15000011, '2026-10-25', 'ALTO', 180, 8325.00, 55500.00, 11100.00, 5058),  -- ingreso 5058 area 9 intervencion 8
	(10000012, 20364230, 14, 15000009, '2026-10-27', 'BAJO', 20, 525.00, 3500.00, 700.00, 5059),  -- ingreso 5059 area 7 intervencion 14
	(10000007, 20364240, 14, 15000009, '2026-10-29', 'BAJO', 20, 675.00, 4500.00, 900.00, 5060);  -- ingreso 5060 area 7 intervencion 14

-- ============================================================================
-- Autovalidacion de la fase
-- ============================================================================
DO $$
DECLARE
	v_filas INTEGER;
BEGIN
	SELECT count(*) INTO v_filas FROM REALIZA;
	IF v_filas < 100 THEN
		RAISE EXCEPTION 'Se esperaban al menos 100 diagnosticos y hay %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM PRESCRIBE;
	IF v_filas < 100 THEN
		RAISE EXCEPTION 'Se esperaban al menos 100 prescripciones y hay %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM PRACTICA;
	IF v_filas < 50 THEN
		RAISE EXCEPTION 'Se esperaban al menos 50 intervenciones y hay %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM INGRESO i
	WHERE (SELECT count(*) FROM REALIZA r
	       WHERE r.NUMBER_INGRESO = i.NUMBER_INGRESO) <> 2;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay ingresos sin exactamente 2 diagnosticos: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM INGRESO i
	WHERE (SELECT count(*) FROM PRESCRIBE p
	       WHERE p.NUMBER_INGRESO = i.NUMBER_INGRESO) <> 2;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay ingresos sin exactamente 2 prescripciones: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM INGRESO i
	WHERE (SELECT count(*) FROM PRACTICA p
	       WHERE p.NUMBER_INGRESO = i.NUMBER_INGRESO) <> 1;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay ingresos sin exactamente 1 intervencion: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM REALIZA r JOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO
	WHERE r.F_ELABORACION < i.F_INGRESO
	   OR r.F_ELABORACION > COALESCE(i.F_ALTA - 1, DATE '2026-10-31');
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay diagnosticos fuera de la internacion: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRESCRIBE p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE p.F_ELABORACION IS NULL OR p.F_INICIO IS NULL OR p.F_FIN IS NULL
	   OR p.CANT_DIAS IS NULL OR p.DOSIS_DIARIA IS NULL
	   OR p.F_ELABORACION < i.F_INGRESO
	   OR p.F_ELABORACION > COALESCE(i.F_ALTA - 1, DATE '2026-10-31')
	   OR p.F_INICIO < i.F_INGRESO
	   OR p.F_FIN > COALESCE(i.F_ALTA - 1, DATE '2026-10-31')
	   OR p.F_FIN < p.F_INICIO
	   OR p.CANT_DIAS <> (p.F_FIN - p.F_INICIO) + 1;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay prescripciones incompletas o fuera de la internacion: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRACTICA p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE p.F IS NULL
	   OR p.F < i.F_INGRESO
	   OR p.F > COALESCE(i.F_ALTA - 1, DATE '2026-10-31')
	   OR p.COSTO IS NULL OR p.COSTO <= 0
	   OR p.GASTO_EQUIPOS IS NULL OR p.GASTO_EQUIPOS < 0
	   OR p.HONORARIO_EQUIPO IS NULL OR p.HONORARIO_EQUIPO < 0
	   OR p.GASTO_EQUIPOS + p.HONORARIO_EQUIPO > p.COSTO;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay intervenciones con fecha o montos invalidos: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM REALIZA r JOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO
	WHERE NOT EXISTS (
		SELECT 1 FROM TRABAJA t
		WHERE t.ID_MEDICO = r.CI_MEDICO
		  AND t.ID_AREA = i.ID_AREA
		  AND t.F <= i.F_INGRESO
	);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay diagnosticos con un medico ajeno al area: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRESCRIBE p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE NOT EXISTS (
		SELECT 1 FROM TRABAJA t
		WHERE t.ID_MEDICO = p.CI_MEDICO
		  AND t.ID_AREA = i.ID_AREA
		  AND t.F <= i.F_INGRESO
	);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay prescripciones con un medico ajeno al area: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRACTICA p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE NOT EXISTS (
		SELECT 1 FROM TRABAJA t
		WHERE t.ID_MEDICO = p.CI_MEDICO
		  AND t.ID_AREA = i.ID_AREA
		  AND t.F <= i.F_INGRESO
	);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay intervenciones con un medico ajeno al area: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM REALIZA r
	JOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO
	JOIN PAC pac ON pac.CI_PAC = r.CI_PAC
	WHERE NOT EXISTS (
		SELECT 1 FROM (VALUES
			(1, 1, NULL),
			(1, 20, NULL),
			(2, 17, 2),
			(2, 22, 2),
			(3, 4, NULL),
			(3, 21, NULL),
			(4, 2, NULL),
			(4, 10, NULL),
			(5, 5, NULL),
			(5, 12, NULL),
			(6, 6, NULL),
			(6, 13, NULL),
			(7, 3, NULL),
			(7, 11, NULL),
			(8, 7, NULL),
			(8, 14, NULL),
			(9, 15, 2),
			(9, 18, 1),
			(9, 19, NULL),
			(10, 8, NULL),
			(10, 9, NULL)
		) AS m(area, diagnostico, sexo)
		WHERE m.area = i.ID_AREA
		  AND m.diagnostico = r.ID_DIAGN
		  AND (m.sexo IS NULL OR m.sexo = pac.ID_SX)
	);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay diagnosticos incompatibles con el area o el sexo: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRESCRIBE p
	JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE NOT EXISTS (
		SELECT 1 FROM (VALUES
			(1, 1),
			(2, 2),
			(3, 2),
			(3, 5),
			(4, 3),
			(4, 11),
			(5, 2),
			(5, 6),
			(6, 12),
			(7, 4),
			(7, 10),
			(8, 7),
			(9, 9),
			(10, 2),
			(10, 8)
		) AS m(area, tratamiento)
		WHERE m.area = i.ID_AREA
		  AND m.tratamiento = p.ID_TRATAMIENTO
	);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay tratamientos incompatibles con el area: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRACTICA p
	JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE NOT EXISTS (
		SELECT 1 FROM (VALUES
			(1, 11),
			(2, 3),
			(3, 5),
			(4, 12),
			(5, 6),
			(6, 13),
			(7, 14),
			(8, 15),
			(9, 8),
			(10, 4),
			(10, 10)
		) AS m(area, intervencion)
		WHERE m.area = i.ID_AREA
		  AND m.intervencion = p.ID_INTERVENCION
	);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay intervenciones incompatibles con el area: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRACTICA p
	JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	JOIN PERSONAL_SANITARIO ps ON ps.CI_PERSONAL = p.CI_PERSONAL_SANITARIO
	WHERE ps.ID_AREA <> i.ID_AREA;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay intervenciones con personal de otra area: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM INGRESO i JOIN PAC p ON p.CI_PAC = i.CI_PAC
	WHERE i.ID_AREA = 7
	  AND p.F_NACIMIENTO <= (i.F_INGRESO - INTERVAL '18 years')::date;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay pacientes adultos en el area pediatrica: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM REALIZA r JOIN PAC p ON p.CI_PAC = r.CI_PAC
	WHERE (r.ID_DIAGN IN (15, 17, 22) AND p.ID_SX <> 2)
	   OR (r.ID_DIAGN = 18 AND p.ID_SX <> 1);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay diagnosticos con un sexo incompatible: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM (
		SELECT CI_MEDICO, CI_PAC, ID_DIAGN, NUMBER_INGRESO, F_ELABORACION
		FROM REALIZA
		GROUP BY 1, 2, 3, 4, 5
		HAVING count(*) > 1
	) d;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay diagnosticos duplicados: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM (
		SELECT CI_MEDICO, CI_PAC, ID_TRATAMIENTO, NUMBER_INGRESO, F_ELABORACION
		FROM PRESCRIBE
		GROUP BY 1, 2, 3, 4, 5
		HAVING count(*) > 1
	) d;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay prescripciones duplicadas: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM (
		SELECT CI_MEDICO, CI_PAC, ID_INTERVENCION, CI_PERSONAL_SANITARIO, F
		FROM PRACTICA
		GROUP BY 1, 2, 3, 4, 5
		HAVING count(*) > 1
	) d;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay intervenciones duplicadas: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM REALIZA r JOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO
	WHERE r.CI_PAC <> i.CI_PAC;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay diagnosticos con paciente incoherente: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRESCRIBE p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE p.CI_PAC <> i.CI_PAC;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay prescripciones con paciente incoherente: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM PRACTICA p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO
	WHERE p.CI_PAC <> i.CI_PAC;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay intervenciones con paciente incoherente: %', v_filas;
	END IF;
END;
$$;
