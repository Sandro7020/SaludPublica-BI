-- ============================================================================
-- Fase 4 - Ingresos y ocupaciones (PostgreSQL)
-- Esquema destino: "OLTP"
--
-- Generado por oltp/datos_prueba/generar_datos.py.
-- No editar a mano: los cambios deben hacerse en el generador.
--
-- Contenido: 60 ingresos, 60 ocupaciones y 4 estancias ACTIVA.
-- Los ingresos se distribuyen en los 12 meses del periodo.
-- Una cama no se repite en fechas superpuestas y un paciente no tiene
-- dos ingresos simultaneos.
--
-- Requiere: 01_catalogos.sql, 02_maestros.sql y 03_polizas.sql.
-- ============================================================================

SET search_path TO "OLTP";

TRUNCATE TABLE "OLTP".INGRESO CASCADE;

-- ============================================================================
-- Ingresos
-- ============================================================================
INSERT INTO INGRESO (NUMBER_INGRESO, CI_PAC, F_INGRESO, F_ALTA, ID_AREA) VALUES
	(5001, 20364201, '2025-11-01', '2025-11-03', 1),  -- 20364201 area 1 diag 1 medico 10000001
	(5002, 20364208, '2025-11-03', '2025-11-13', 2),  -- 20364208 area 2 diag 17 medico 10000002
	(5003, 20364214, '2025-11-05', '2025-11-13', 8),  -- 20364214 area 8 diag 7 medico 10000008
	(5004, 20364221, '2025-11-07', '2025-11-14', 10),  -- 20364221 area 10 diag 8 medico 10000010
	(5005, 20364231, '2025-11-09', '2025-11-18', 6),  -- 20364231 area 6 diag 13 medico 10000006
	(5006, 20364201, '2025-12-01', '2025-12-04', 1),  -- 20364201 area 1 diag 1 medico 10000011
	(5007, 20364208, '2025-12-03', '2025-12-05', 2),  -- 20364208 area 2 diag 17 medico 10000002
	(5008, 20364215, '2025-12-05', '2025-12-15', 3),  -- 20364215 area 3 diag 4 medico 10000003
	(5009, 20364222, '2025-12-07', '2025-12-16', 10),  -- 20364222 area 10 diag 9 medico 10000010
	(5010, 20364232, '2025-12-09', '2025-12-11', 6),  -- 20364232 area 6 diag 6 medico 10000006
	(5011, 20364201, '2026-01-01', '2026-01-05', 1),  -- 20364201 area 1 diag 1 medico 10000001
	(5012, 20364209, '2026-01-03', '2026-01-07', 1),  -- 20364209 area 1 diag 1 medico 10000011
	(5013, 20364216, '2026-01-05', '2026-01-08', 4),  -- 20364216 area 4 diag 2 medico 10000004
	(5014, 20364223, '2026-01-07', '2026-01-09', 10),  -- 20364223 area 10 diag 8 medico 10000010
	(5015, 20364233, '2026-01-09', '2026-01-13', 10),  -- 20364233 area 10 diag 9 medico 10000010
	(5016, 20364202, '2026-02-01', '2026-02-07', 2),  -- 20364202 area 2 diag 17 medico 10000002
	(5017, 20364209, '2026-02-03', '2026-02-08', 1),  -- 20364209 area 1 diag 1 medico 10000001
	(5018, 20364216, '2026-02-05', '2026-02-09', 4),  -- 20364216 area 4 diag 2 medico 10000004
	(5019, 20364224, '2026-02-07', '2026-02-11', 4),  -- 20364224 area 4 diag 2 medico 10000004
	(5020, 20364233, '2026-02-09', '2026-02-14', 10),  -- 20364233 area 10 diag 9 medico 10000010
	(5021, 20364202, '2026-03-01', '2026-03-08', 2),  -- 20364202 area 2 diag 17 medico 10000002
	(5022, 20364209, '2026-03-03', '2026-03-09', 1),  -- 20364209 area 1 diag 1 medico 10000011
	(5023, 20364217, '2026-03-05', '2026-03-11', 5),  -- 20364217 area 5 diag 5 medico 10000005
	(5024, 20364225, '2026-03-07', '2026-03-13', 5),  -- 20364225 area 5 diag 12 medico 10000005
	(5025, 20364233, '2026-03-09', '2026-03-15', 10),  -- 20364233 area 10 diag 9 medico 10000010
	(5026, 20364203, '2026-04-01', '2026-04-10', 3),  -- 20364203 area 3 diag 4 medico 10000003
	(5027, 20364210, '2026-04-03', '2026-04-11', 2),  -- 20364210 area 2 diag 17 medico 10000002
	(5028, 20364217, '2026-04-05', '2026-04-12', 5),  -- 20364217 area 5 diag 5 medico 10000005
	(5029, 20364225, '2026-04-07', '2026-04-14', 5),  -- 20364225 area 5 diag 12 medico 10000005
	(5030, 20364234, '2026-04-09', '2026-04-17', 7),  -- 20364234 area 7 diag 11 medico 10000007
	(5031, 20364204, '2026-05-01', '2026-05-03', 2),  -- 20364204 area 2 diag 17 medico 10000002
	(5032, 20364210, '2026-05-03', '2026-05-12', 2),  -- 20364210 area 2 diag 17 medico 10000002
	(5033, 20364217, '2026-05-05', '2026-05-13', 5),  -- 20364217 area 5 diag 5 medico 10000005
	(5034, 20364225, '2026-05-07', '2026-05-15', 5),  -- 20364225 area 5 diag 12 medico 10000005
	(5035, 20364235, '2026-05-09', '2026-05-19', 8),  -- 20364235 area 8 diag 7 medico 10000008
	(5036, 20364204, '2026-06-01', '2026-06-04', 2),  -- 20364204 area 2 diag 17 medico 10000002
	(5037, 20364211, '2026-06-03', '2026-06-05', 3),  -- 20364211 area 3 diag 4 medico 10000003
	(5038, 20364218, '2026-06-05', '2026-06-15', 4),  -- 20364218 area 4 diag 10 medico 10000004
	(5039, 20364226, '2026-06-07', '2026-06-17', 5),  -- 20364226 area 5 diag 5 medico 10000005
	(5040, 20364236, '2026-06-09', '2026-06-12', 8),  -- 20364236 area 8 diag 14 medico 10000008
	(5041, 20364205, '2026-07-01', '2026-07-06', 1),  -- 20364205 area 1 diag 1 medico 10000001
	(5042, 20364212, '2026-07-03', '2026-07-07', 4),  -- 20364212 area 4 diag 2 medico 10000004
	(5043, 20364218, '2026-07-05', '2026-07-07', 4),  -- 20364218 area 4 diag 10 medico 10000004
	(5044, 20364227, '2026-07-07', '2026-07-10', 7),  -- 20364227 area 7 diag 3 medico 10000012
	(5045, 20364237, '2026-07-09', '2026-07-14', 9),  -- 20364237 area 9 diag 18 medico 10000009
	(5046, 20364206, '2026-08-01', '2026-08-08', 2),  -- 20364206 area 2 diag 17 medico 10000002
	(5047, 20364212, '2026-08-03', '2026-08-08', 4),  -- 20364212 area 4 diag 2 medico 10000004
	(5048, 20364219, '2026-08-05', '2026-08-09', 9),  -- 20364219 area 9 diag 19 medico 10000009
	(5049, 20364228, '2026-08-07', '2026-08-12', 6),  -- 20364228 area 6 diag 6 medico 10000006
	(5050, 20364238, '2026-08-09', '2026-08-16', 7),  -- 20364238 area 7 diag 3 medico 10000007
	(5051, 20364206, '2026-09-01', '2026-09-09', 2),  -- 20364206 area 2 diag 17 medico 10000002
	(5052, 20364213, '2026-09-03', '2026-09-10', 1),  -- 20364213 area 1 diag 1 medico 10000011
	(5053, 20364220, '2026-09-05', '2026-09-11', 9),  -- 20364220 area 9 diag 15 medico 10000009
	(5054, 20364229, '2026-09-07', '2026-09-14', 6),  -- 20364229 area 6 diag 13 medico 10000006
	(5055, 20364239, '2026-09-09', '2026-09-18', 8),  -- 20364239 area 8 diag 14 medico 10000008
	(5056, 20364207, '2026-10-05', '2026-10-09', 3),  -- 20364207 area 3 diag 4 medico 10000003
	(5057, 20364214, '2026-10-22', NULL, 8),  -- 20364214 area 8 diag 7 medico 10000008
	(5058, 20364220, '2026-10-24', NULL, 9),  -- 20364220 area 9 diag 15 medico 10000009
	(5059, 20364230, '2026-10-26', NULL, 7),  -- 20364230 area 7 diag 3 medico 10000012
	(5060, 20364240, '2026-10-28', NULL, 7);  -- 20364240 area 7 diag 11 medico 10000007

-- ============================================================================
-- Ocupaciones
-- ============================================================================
INSERT INTO OCUPA (CI_PAC, ID_NUMBER_CAMA, F_INICIO, CANTIDAD_DIAS, DIAS_CUBIERTOS_SEGURO, COSTO_DIARIO, ESTATUS, NUMBER_INGRESO, ID_POLIZA) VALUES
	(20364201, 301, '2025-11-01', 2, 2, 2000.00, 'ALTA', 5001, 27),  -- ingreso 5001 cama 301
	(20364208, 401, '2025-11-03', 10, 10, 2800.00, 'ALTA', 5002, 8),  -- ingreso 5002 cama 401
	(20364214, 801, '2025-11-05', 8, 8, 2200.00, 'ALTA', 5003, 14),  -- ingreso 5003 cama 801
	(20364221, 1001, '2025-11-07', 7, 0, 2800.00, 'ALTA', 5004, NULL),  -- ingreso 5004 cama 1001
	(20364231, 701, '2025-11-09', 9, 0, 2400.00, 'ALTA', 5005, NULL),  -- ingreso 5005 cama 701
	(20364201, 302, '2025-12-01', 3, 3, 1800.00, 'ALTA', 5006, 27),  -- ingreso 5006 cama 302
	(20364208, 402, '2025-12-03', 2, 2, 2600.00, 'ALTA', 5007, 8),  -- ingreso 5007 cama 402
	(20364215, 201, '2025-12-05', 10, 0, 1400.00, 'ALTA', 5008, NULL),  -- ingreso 5008 cama 201
	(20364222, 1002, '2025-12-07', 9, 9, 2800.00, 'ALTA', 5009, 22),  -- ingreso 5009 cama 1002
	(20364232, 702, '2025-12-09', 2, 0, 2400.00, 'ALTA', 5010, NULL),  -- ingreso 5010 cama 702
	(20364201, 303, '2026-01-01', 4, 4, 1900.00, 'ALTA', 5011, 27),  -- ingreso 5011 cama 303
	(20364209, 304, '2026-01-03', 4, 0, 1800.00, 'ALTA', 5012, NULL),  -- ingreso 5012 cama 304
	(20364216, 501, '2026-01-05', 3, 3, 1700.00, 'ALTA', 5013, 16),  -- ingreso 5013 cama 501
	(20364223, 1001, '2026-01-07', 2, 0, 2800.00, 'ALTA', 5014, NULL),  -- ingreso 5014 cama 1001
	(20364233, 1002, '2026-01-09', 4, 4, 2800.00, 'ALTA', 5015, 39),  -- ingreso 5015 cama 1002
	(20364202, 403, '2026-02-01', 6, 6, 2700.00, 'ALTA', 5016, 2),  -- ingreso 5016 cama 403
	(20364209, 301, '2026-02-03', 5, 0, 1900.00, 'ALTA', 5017, NULL),  -- ingreso 5017 cama 301
	(20364216, 502, '2026-02-05', 4, 4, 1800.00, 'ALTA', 5018, 16),  -- ingreso 5018 cama 502
	(20364224, 501, '2026-02-07', 4, 4, 1700.00, 'ALTA', 5019, 24),  -- ingreso 5019 cama 501
	(20364233, 1001, '2026-02-09', 5, 5, 2900.00, 'ALTA', 5020, 39),  -- ingreso 5020 cama 1001
	(20364202, 404, '2026-03-01', 7, 7, 2800.00, 'ALTA', 5021, 2),  -- ingreso 5021 cama 404
	(20364209, 302, '2026-03-03', 6, 0, 2000.00, 'ALTA', 5022, NULL),  -- ingreso 5022 cama 302
	(20364217, 601, '2026-03-05', 6, 0, 2100.00, 'ALTA', 5023, NULL),  -- ingreso 5023 cama 601
	(20364225, 602, '2026-03-07', 6, 0, 2000.00, 'ALTA', 5024, NULL),  -- ingreso 5024 cama 602
	(20364233, 1002, '2026-03-09', 6, 6, 3000.00, 'ALTA', 5025, 39),  -- ingreso 5025 cama 1002
	(20364203, 202, '2026-04-01', 9, 5, 1600.00, 'ALTA', 5026, 3),  -- ingreso 5026 cama 202
	(20364210, 401, '2026-04-03', 8, 8, 2800.00, 'ALTA', 5027, 10),  -- ingreso 5027 cama 401
	(20364217, 601, '2026-04-05', 7, 0, 2200.00, 'ALTA', 5028, NULL),  -- ingreso 5028 cama 601
	(20364225, 602, '2026-04-07', 7, 0, 2100.00, 'ALTA', 5029, NULL),  -- ingreso 5029 cama 602
	(20364234, 101, '2026-04-09', 8, 0, 1800.00, 'ALTA', 5030, NULL),  -- ingreso 5030 cama 101
	(20364204, 402, '2026-05-01', 2, 2, 2800.00, 'ALTA', 5031, 29),  -- ingreso 5031 cama 402
	(20364210, 403, '2026-05-03', 9, 9, 2600.00, 'ALTA', 5032, 10),  -- ingreso 5032 cama 403
	(20364217, 601, '2026-05-05', 8, 0, 2000.00, 'ALTA', 5033, NULL),  -- ingreso 5033 cama 601
	(20364225, 602, '2026-05-07', 8, 0, 2200.00, 'ALTA', 5034, NULL),  -- ingreso 5034 cama 602
	(20364235, 802, '2026-05-09', 10, 0, 2400.00, 'ALTA', 5035, NULL),  -- ingreso 5035 cama 802
	(20364204, 404, '2026-06-01', 3, 3, 2600.00, 'ALTA', 5036, 29),  -- ingreso 5036 cama 404
	(20364211, 201, '2026-06-03', 2, 0, 1400.00, 'ALTA', 5037, NULL),  -- ingreso 5037 cama 201
	(20364218, 502, '2026-06-05', 10, 0, 1700.00, 'ALTA', 5038, NULL),  -- ingreso 5038 cama 502
	(20364226, 601, '2026-06-07', 10, 5, 2200.00, 'ALTA', 5039, 26),  -- ingreso 5039 cama 601
	(20364236, 801, '2026-06-09', 3, 3, 2400.00, 'ALTA', 5040, 41),  -- ingreso 5040 cama 801
	(20364205, 303, '2026-07-01', 5, 5, 1800.00, 'ALTA', 5041, 5),  -- ingreso 5041 cama 303
	(20364212, 501, '2026-07-03', 4, 4, 1700.00, 'ALTA', 5042, 12),  -- ingreso 5042 cama 501
	(20364218, 502, '2026-07-05', 2, 0, 1800.00, 'ALTA', 5043, NULL),  -- ingreso 5043 cama 502
	(20364227, 102, '2026-07-07', 3, 0, 1800.00, 'ALTA', 5044, NULL),  -- ingreso 5044 cama 102
	(20364237, 901, '2026-07-09', 5, 5, 3400.00, 'ALTA', 5045, 42),  -- ingreso 5045 cama 901
	(20364206, 401, '2026-08-01', 7, 0, 2600.00, 'ALTA', 5046, NULL),  -- ingreso 5046 cama 401
	(20364212, 501, '2026-08-03', 5, 5, 1800.00, 'ALTA', 5047, 12),  -- ingreso 5047 cama 501
	(20364219, 902, '2026-08-05', 4, 0, 3300.00, 'ALTA', 5048, NULL),  -- ingreso 5048 cama 902
	(20364228, 701, '2026-08-07', 5, 5, 2600.00, 'ALTA', 5049, 35),  -- ingreso 5049 cama 701
	(20364238, 103, '2026-08-09', 7, 0, 1800.00, 'ALTA', 5050, NULL),  -- ingreso 5050 cama 103
	(20364206, 402, '2026-09-01', 8, 0, 2700.00, 'ALTA', 5051, NULL),  -- ingreso 5051 cama 402
	(20364213, 304, '2026-09-03', 7, 7, 1900.00, 'ALTA', 5052, 31),  -- ingreso 5052 cama 304
	(20364220, 901, '2026-09-05', 6, 6, 3300.00, 'ALTA', 5053, 33),  -- ingreso 5053 cama 901
	(20364229, 702, '2026-09-07', 7, 7, 2600.00, 'ALTA', 5054, 36),  -- ingreso 5054 cama 702
	(20364239, 802, '2026-09-09', 9, 0, 2400.00, 'ALTA', 5055, NULL),  -- ingreso 5055 cama 802
	(20364207, 202, '2026-10-05', 4, 3, 1500.00, 'ALTA', 5056, 30),  -- ingreso 5056 cama 202
	(20364214, 801, '2026-10-22', 10, 10, 2400.00, 'ACTIVA', 5057, 14),  -- ingreso 5057 cama 801
	(20364220, 902, '2026-10-24', 8, 8, 3200.00, 'ACTIVA', 5058, 33),  -- ingreso 5058 cama 902
	(20364230, 104, '2026-10-26', 6, 6, 1800.00, 'ACTIVA', 5059, 37),  -- ingreso 5059 cama 104
	(20364240, 101, '2026-10-28', 4, 0, 1700.00, 'ACTIVA', 5060, NULL);  -- ingreso 5060 cama 101

-- ============================================================================
-- Autovalidacion de la fase
-- ============================================================================
DO $$
DECLARE
	v_filas INTEGER;
BEGIN
	SELECT count(*) INTO v_filas FROM INGRESO;
	IF v_filas < 40 THEN
		RAISE EXCEPTION 'Se esperaban al menos 40 ingresos y hay %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM INGRESO i
	LEFT JOIN OCUPA o ON o.NUMBER_INGRESO = i.NUMBER_INGRESO
	WHERE o.NUMBER_INGRESO IS NULL;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay ingresos sin ocupacion: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM INGRESO
	WHERE F_INGRESO < DATE '2025-11-01' OR F_INGRESO > DATE '2026-10-31';
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay ingresos fuera del periodo: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM INGRESO
	WHERE F_ALTA IS NOT NULL AND (F_ALTA < F_INGRESO OR F_ALTA > DATE '2026-10-31');
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay altas fuera del periodo: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA o
	JOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO
	WHERE o.ESTATUS = 'ACTIVA' AND i.F_ALTA IS NOT NULL;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay estancias ACTIVA con fecha de alta: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA o
	JOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO
	WHERE o.ESTATUS = 'ALTA' AND i.F_ALTA IS NULL;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay estancias ALTA sin fecha de alta: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA
	WHERE CANTIDAD_DIAS <= 0
	   OR DIAS_CUBIERTOS_SEGURO < 0
	   OR DIAS_CUBIERTOS_SEGURO > CANTIDAD_DIAS;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay dias de ocupacion o cobertura invalidos: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA
	WHERE COSTO_DIARIO < 1200 OR COSTO_DIARIO > 4000;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay costos diarios fuera de rango: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA o
	JOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO
	JOIN CAMA c ON c.ID_NUMBER_CAMA = o.ID_NUMBER_CAMA
	WHERE o.CI_PAC <> i.CI_PAC OR c.ID_AREA_HOSPITAL <> i.ID_AREA;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay ocupaciones con paciente o area incoherente: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA o
	JOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO
	WHERE o.F_INICIO <> i.F_INGRESO;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay ocupaciones que no inician el dia del ingreso: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM OCUPA a JOIN OCUPA b
	  ON a.ID_NUMBER_CAMA = b.ID_NUMBER_CAMA
	 AND a.NUMBER_INGRESO < b.NUMBER_INGRESO
	 AND a.F_INICIO < b.F_INICIO + b.CANTIDAD_DIAS::integer
	 AND b.F_INICIO < a.F_INICIO + a.CANTIDAD_DIAS::integer;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay solapamientos de cama: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas
	FROM OCUPA a JOIN OCUPA b
	  ON a.CI_PAC = b.CI_PAC
	 AND a.NUMBER_INGRESO < b.NUMBER_INGRESO
	 AND a.F_INICIO < b.F_INICIO + b.CANTIDAD_DIAS::integer
	 AND b.F_INICIO < a.F_INICIO + a.CANTIDAD_DIAS::integer;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay pacientes en dos camas a la vez: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA
	WHERE ESTATUS = 'ACTIVA'
	  AND F_INICIO + CANTIDAD_DIAS::integer <= DATE '2026-10-31';
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay estancias ACTIVA terminadas antes del corte: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA o
	JOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO
	WHERE o.ESTATUS = 'ALTA'
	  AND i.F_ALTA <> o.F_INICIO + o.CANTIDAD_DIAS::integer;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay altas que no coinciden con la ocupacion: %', v_filas;
	END IF;

	SELECT count(*) INTO v_filas FROM OCUPA o
	LEFT JOIN POLIZA p ON p.ID_POLIZA = o.ID_POLIZA AND p.CI_PAC = o.CI_PAC
	WHERE o.ID_POLIZA IS NOT NULL AND p.ID_POLIZA IS NULL;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay polizas de ocupacion que no pertenecen al paciente: %', v_filas;
	END IF;
END;
$$;
