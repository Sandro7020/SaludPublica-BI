-- ============================================================================
-- Fase 3 - Polizas (PostgreSQL)
-- Esquema destino: "OLTP"
--
-- Contenido:
--   * Las 26 polizas de POLIZAS_DE_SEGUROS.csv, limpiadas.
--   * 8 polizas secundarias para ejercitar el caso principal + secundaria.
--   * 8 polizas principales para pacientes adicionales.
--   * Pacientes sin poliza: quedan como autopago.
--
-- Limpieza aplicada al CSV:
--   * 'NO ' / 'SI ' -> FALSE / TRUE.
--   * 'NI' en AMBULANCIA -> FALSE.
--   * COBERTURA '10.000' -> 10000 (monto en bolivares).
--   * Las 4 filas vacias del final se ignoran.
--   * Si un paciente solo tenia una poliza SECUNDARIA, se promueve a
--     PRINCIPAL. Asi todos los pacientes del CSV tienen una principal y se
--     respeta el maximo de una principal por paciente.
--
-- Fechas y cobertura:
--   * Todas las polizas estan vigentes durante el periodo 2025-11-01 a
--     2026-10-31; algunas tienen F_HASTA NULL (vigencia abierta).
--   * DIAS_COBERTURA es 0 cuando HOSPITALIZACION = FALSE. Cuando cubre
--     hospitalizacion toma valores 3, 5, 10, 15 o 30 para que algunas
--     internaciones tengan cobertura parcial (RN-14 / invariante 9).
--
-- Requiere: 01_catalogos.sql y 02_maestros.sql.
-- ============================================================================

SET search_path TO "OLTP";

TRUNCATE TABLE "OLTP".POLIZA CASCADE;

-- ============================================================================
-- Polizas del CSV (20364201 - 20364226)
-- ============================================================================
INSERT INTO POLIZA (
	ID_POLIZA, CI_PAC, ID_ASEGURADORA, TITULAR, TIPO_POLIZA,
	HOSPITALIZACION, CIRUGIA, MATERNIDAD, RADIOGRAFIAS, EXAMENES, AMBULANCIA,
	COBERTURA, APROBADA, F_DESDE, F_HASTA, DIAS_COBERTURA
) VALUES
	-- 20364201 - QUALITAS
	(1,  20364201, 1, TRUE,  'PRINCIPAL', FALSE, TRUE,  TRUE,  FALSE, TRUE,  TRUE,  10000.00, TRUE,  '2025-01-01', '2026-12-31',  0),
	-- 20364202 - CONSTITUCION
	(2,  20364202, 2, FALSE, 'PRINCIPAL', TRUE,  FALSE, FALSE, TRUE,  FALSE, TRUE,  20000.00, TRUE,  '2025-01-01', '2026-12-31', 10),
	-- 20364203 - VENEZOLANA (SECUNDARIA del CSV, promovida)
	(3,  20364203, 3, FALSE, 'PRINCIPAL', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  30000.00, TRUE,  '2024-07-01', '2026-12-31',  5),
	-- 20364204 - MERCANTIL (SECUNDARIA del CSV, promovida)
	(4,  20364204, 4, FALSE, 'PRINCIPAL', FALSE, TRUE,  TRUE,  FALSE, FALSE, FALSE, 50000.00, FALSE, '2025-03-01', '2026-12-31',  0),
	-- 20364205 - CARACAS
	(5,  20364205, 5, FALSE, 'PRINCIPAL', TRUE,  TRUE,  FALSE, TRUE,  FALSE, FALSE, 60000.00, TRUE,  '2025-01-01', NULL,         15),
	-- 20364206 - SANITAS
	(6,  20364206, 6, TRUE,  'PRINCIPAL', FALSE, TRUE,  FALSE, FALSE, TRUE,  FALSE, 100000.00, TRUE, '2025-01-01', '2026-12-31',  0),
	-- 20364207 - RESCARVEN
	(7,  20364207, 7, TRUE,  'PRINCIPAL', FALSE, FALSE, FALSE, FALSE, TRUE,  TRUE,  10000.00, FALSE, '2024-10-01', '2026-12-31',  0),
	-- 20364208 - QUALITAS (SECUNDARIA del CSV, promovida)
	(8,  20364208, 1, TRUE,  'PRINCIPAL', TRUE,  FALSE, TRUE,  TRUE,  TRUE,  TRUE,  20000.00, TRUE,  '2025-01-01', '2026-12-31', 10),
	-- 20364209 - CONSTITUCION (SECUNDARIA del CSV, promovida)
	(9,  20364209, 2, FALSE, 'PRINCIPAL', TRUE,  FALSE, TRUE,  TRUE,  FALSE, FALSE, 30000.00, FALSE, '2025-01-01', '2027-06-30',  3),
	-- 20364210 - VENEZOLANA (SECUNDARIA del CSV, promovida)
	(10, 20364210, 3, TRUE,  'PRINCIPAL', TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, 50000.00, TRUE,  '2025-05-01', '2026-12-31', 15),
	-- 20364211 - MERCANTIL (SECUNDARIA del CSV, promovida)
	(11, 20364211, 4, FALSE, 'PRINCIPAL', TRUE,  FALSE, TRUE,  TRUE,  TRUE,  TRUE,  60000.00, FALSE, '2025-01-01', '2026-12-31', 30),
	-- 20364212 - CARACAS
	(12, 20364212, 5, TRUE,  'PRINCIPAL', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  100000.00, TRUE, '2024-01-01', NULL,         30),
	-- 20364213 - SANITAS
	(13, 20364213, 6, TRUE,  'PRINCIPAL', FALSE, TRUE,  TRUE,  FALSE, TRUE,  FALSE, 10000.00, TRUE,  '2025-01-01', '2026-12-31',  0),
	-- 20364214 - RESCARVEN (SECUNDARIA del CSV, promovida)
	(14, 20364214, 7, FALSE, 'PRINCIPAL', TRUE,  TRUE,  FALSE, TRUE,  TRUE,  FALSE, 20000.00, TRUE,  '2025-02-01', '2026-12-31', 10),
	-- 20364215 - QUALITAS
	(15, 20364215, 1, TRUE,  'PRINCIPAL', FALSE, TRUE,  TRUE,  TRUE,  FALSE, FALSE, 30000.00, FALSE, '2025-01-01', '2026-12-31',  0),
	-- 20364216 - CONSTITUCION
	(16, 20364216, 2, FALSE, 'PRINCIPAL', TRUE,  FALSE, TRUE,  TRUE,  TRUE,  TRUE,  50000.00, TRUE,  '2024-09-01', '2026-12-31', 15),
	-- 20364217 - VENEZOLANA (SECUNDARIA del CSV, promovida)
	(17, 20364217, 3, FALSE, 'PRINCIPAL', TRUE,  TRUE,  FALSE, FALSE, TRUE,  TRUE,  60000.00, FALSE, '2025-01-01', '2027-01-01',  5),
	-- 20364218 - MERCANTIL (SECUNDARIA del CSV, promovida)
	(18, 20364218, 4, FALSE, 'PRINCIPAL', FALSE, TRUE,  TRUE,  TRUE,  TRUE,  FALSE, 100000.00, TRUE, '2025-06-01', '2026-12-31',  0),
	-- 20364219 - CARACAS
	(19, 20364219, 5, FALSE, 'PRINCIPAL', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, 10000.00, FALSE, '2025-01-01', '2026-12-31', 10),
	-- 20364220 - SANITAS
	(20, 20364220, 6, TRUE,  'PRINCIPAL', FALSE, TRUE,  FALSE, TRUE,  FALSE, FALSE, 20000.00, TRUE,  '2024-11-01', '2026-12-31',  0),
	-- 20364221 - RESCARVEN
	(21, 20364221, 7, TRUE,  'PRINCIPAL', FALSE, FALSE, TRUE,  FALSE, TRUE,  TRUE,  30000.00, TRUE,  '2025-01-01', NULL,          0),
	-- 20364222 - QUALITAS (SECUNDARIA del CSV, promovida)
	(22, 20364222, 1, TRUE,  'PRINCIPAL', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  50000.00, TRUE,  '2025-03-01', '2026-12-31', 30),
	-- 20364223 - CONSTITUCION (SECUNDARIA del CSV, promovida)
	(23, 20364223, 2, FALSE, 'PRINCIPAL', TRUE,  TRUE,  FALSE, TRUE,  TRUE,  FALSE, 60000.00, FALSE, '2025-01-01', '2026-12-31', 15),
	-- 20364224 - VENEZOLANA (SECUNDARIA del CSV, promovida)
	(24, 20364224, 3, TRUE,  'PRINCIPAL', TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, 100000.00, TRUE, '2024-05-01', '2027-12-31', 10),
	-- 20364225 - MERCANTIL (SECUNDARIA del CSV, promovida)
	(25, 20364225, 4, FALSE, 'PRINCIPAL', TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, 10000.00, FALSE, '2025-01-01', '2026-12-31', 30),
	-- 20364226 - CARACAS
	(26, 20364226, 5, TRUE,  'PRINCIPAL', TRUE,  FALSE, FALSE, TRUE,  TRUE,  TRUE,  20000.00, TRUE,  '2025-07-01', '2026-12-31',  5);

-- ============================================================================
-- Polizas secundarias (8 pacientes)
-- Cada secundaria usa una aseguradora distinta de la principal y cubre al
-- menos una categoria que la principal no cubre. Las de los pacientes con
-- principal no aprobada quedan aprobadas para ejercitar el respaldo.
-- ============================================================================
INSERT INTO POLIZA (
	ID_POLIZA, CI_PAC, ID_ASEGURADORA, TITULAR, TIPO_POLIZA,
	HOSPITALIZACION, CIRUGIA, MATERNIDAD, RADIOGRAFIAS, EXAMENES, AMBULANCIA,
	COBERTURA, APROBADA, F_DESDE, F_HASTA, DIAS_COBERTURA
) VALUES
	-- 20364201: la principal no cubre hospitalizacion ni radiografias.
	(27, 20364201, 2, FALSE, 'SECUNDARIA', TRUE,  FALSE, FALSE, TRUE,  FALSE, FALSE, 40000.00, TRUE, '2025-01-01', '2026-12-31', 10),
	-- 20364202: la principal no cubre cirugia, maternidad ni examenes.
	(28, 20364202, 3, FALSE, 'SECUNDARIA', FALSE, TRUE,  TRUE,  FALSE, TRUE,  FALSE, 50000.00, TRUE, '2025-01-01', '2026-12-31',  0),
	-- 20364204: la principal no esta aprobada.
	(29, 20364204, 6, FALSE, 'SECUNDARIA', TRUE,  FALSE, FALSE, TRUE,  TRUE,  FALSE, 30000.00, TRUE, '2025-01-01', '2026-12-31',  5),
	-- 20364207: la principal no esta aprobada.
	(30, 20364207, 5, FALSE, 'SECUNDARIA', TRUE,  TRUE,  FALSE, TRUE,  FALSE, FALSE, 20000.00, TRUE, '2025-01-01', '2026-12-31',  3),
	-- 20364213: la principal no cubre hospitalizacion, radiografias ni ambulancia.
	(31, 20364213, 4, FALSE, 'SECUNDARIA', TRUE,  FALSE, FALSE, TRUE,  FALSE, TRUE,  40000.00, TRUE, '2025-01-01', '2026-12-31', 10),
	-- 20364217: la principal no esta aprobada.
	(32, 20364217, 1, FALSE, 'SECUNDARIA', FALSE, FALSE, TRUE,  TRUE,  FALSE, FALSE, 30000.00, TRUE, '2025-01-01', '2026-12-31',  0),
	-- 20364220: la principal no cubre hospitalizacion, maternidad ni examenes.
	(33, 20364220, 2, FALSE, 'SECUNDARIA', TRUE,  FALSE, TRUE,  FALSE, TRUE,  FALSE, 50000.00, TRUE, '2025-01-01', '2026-12-31', 15),
	-- 20364226: la principal no cubre cirugia ni maternidad.
	(34, 20364226, 1, FALSE, 'SECUNDARIA', FALSE, TRUE,  TRUE,  FALSE, FALSE, FALSE, 40000.00, TRUE, '2025-01-01', '2026-12-31',  0);

-- ============================================================================
-- Polizas principales para pacientes adicionales
-- 20364228, 20364229, 20364230 (pediatria), 20364232, 20364233
-- (traumatologia), 20364235, 20364236 y 20364237 (oncologia).
-- Los demas pacientes adicionales quedan como autopago.
-- ============================================================================
INSERT INTO POLIZA (
	ID_POLIZA, CI_PAC, ID_ASEGURADORA, TITULAR, TIPO_POLIZA,
	HOSPITALIZACION, CIRUGIA, MATERNIDAD, RADIOGRAFIAS, EXAMENES, AMBULANCIA,
	COBERTURA, APROBADA, F_DESDE, F_HASTA, DIAS_COBERTURA
) VALUES
	(35, 20364228, 1, TRUE,  'PRINCIPAL', TRUE,  FALSE, FALSE, TRUE,  TRUE,  FALSE, 30000.00, TRUE,  '2025-06-01', '2026-12-31',  5),
	(36, 20364229, 2, TRUE,  'PRINCIPAL', TRUE,  TRUE,  FALSE, FALSE, TRUE,  FALSE, 60000.00, TRUE,  '2025-01-01', '2026-12-31', 10),
	(37, 20364230, 3, TRUE,  'PRINCIPAL', TRUE,  FALSE, FALSE, TRUE,  TRUE,  TRUE,  40000.00, TRUE,  '2025-01-01', '2026-12-31', 15),
	(38, 20364232, 4, TRUE,  'PRINCIPAL', FALSE, TRUE,  TRUE,  FALSE, TRUE,  FALSE, 50000.00, TRUE,  '2025-01-01', '2026-12-31',  0),
	(39, 20364233, 5, TRUE,  'PRINCIPAL', TRUE,  TRUE,  FALSE, TRUE,  TRUE,  FALSE, 80000.00, TRUE,  '2025-01-01', '2026-12-31', 30),
	(40, 20364235, 6, TRUE,  'PRINCIPAL', TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, 20000.00, FALSE, '2025-01-01', '2026-12-31',  3),
	(41, 20364236, 7, TRUE,  'PRINCIPAL', TRUE,  FALSE, TRUE,  TRUE,  TRUE,  TRUE,  70000.00, TRUE,  '2025-01-01', '2026-12-31', 10),
	(42, 20364237, 1, TRUE,  'PRINCIPAL', TRUE,  TRUE,  FALSE, TRUE,  TRUE,  FALSE, 100000.00, TRUE, '2025-01-01', '2026-12-31', 30);

-- ============================================================================
-- Autovalidacion de la fase
-- ============================================================================
DO $$
DECLARE
	v_filas INTEGER;
BEGIN
	-- Un paciente puede tener como maximo 2 polizas.
	SELECT count(*) INTO v_filas
	FROM (
		SELECT CI_PAC FROM POLIZA GROUP BY CI_PAC HAVING count(*) > 2
	) x;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay pacientes con mas de 2 polizas: %', v_filas;
	END IF;

	-- Como maximo una poliza principal por paciente.
	SELECT count(*) INTO v_filas
	FROM (
		SELECT CI_PAC FROM POLIZA
		WHERE TIPO_POLIZA = 'PRINCIPAL'
		GROUP BY CI_PAC HAVING count(*) > 1
	) x;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay pacientes con mas de una poliza principal: %', v_filas;
	END IF;

	-- Toda poliza secundaria debe tener una principal del mismo paciente.
	SELECT count(*) INTO v_filas
	FROM POLIZA s
	WHERE s.TIPO_POLIZA = 'SECUNDARIA'
	  AND NOT EXISTS (
		SELECT 1 FROM POLIZA p
		WHERE p.CI_PAC = s.CI_PAC AND p.TIPO_POLIZA = 'PRINCIPAL'
	  );
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay polizas secundarias sin principal: %', v_filas;
	END IF;

	-- Las polizas aprobadas deben cubrir al menos una categoria facturable.
	SELECT count(*) INTO v_filas
	FROM POLIZA
	WHERE APROBADA
	  AND NOT (HOSPITALIZACION OR CIRUGIA OR EXAMENES OR RADIOGRAFIAS);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay polizas aprobadas sin categoria facturable: %', v_filas;
	END IF;

	-- Vigencia coherente y presente durante todo el periodo de servicios.
	SELECT count(*) INTO v_filas
	FROM POLIZA
	WHERE F_DESDE > DATE '2025-11-01'
	   OR (F_HASTA IS NOT NULL AND F_HASTA < DATE '2026-10-31');
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay polizas fuera del periodo de servicios: %', v_filas;
	END IF;

	-- DIAS_COBERTURA coherente con HOSPITALIZACION.
	SELECT count(*) INTO v_filas
	FROM POLIZA
	WHERE (HOSPITALIZACION AND DIAS_COBERTURA <= 0)
	   OR (NOT HOSPITALIZACION AND DIAS_COBERTURA <> 0);
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay DIAS_COBERTURA incoherentes: %', v_filas;
	END IF;

	-- Cobertura dentro del rango definido (10.000 - 100.000 Bs).
	SELECT count(*) INTO v_filas
	FROM POLIZA
	WHERE COBERTURA < 10000 OR COBERTURA > 100000;
	IF v_filas > 0 THEN
		RAISE EXCEPTION 'Hay coberturas fuera de rango: %', v_filas;
	END IF;
END;
$$;
