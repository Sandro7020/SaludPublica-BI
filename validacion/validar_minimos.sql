-- =====================================================================
-- Validación integral del OLTP - Fase 8
--
-- Comprueba:
--   A. Mínimos del conjunto de datos (README y plan de generación).
--   B. Reglas de coherencia entre ingresos, camas y servicios.
--   C. Coherencia de la facturación y de las pólizas.
--   D. Efectos secundarios (RN-08).
--   E. Cobertura del mapeo OLTP -> DWH (el ETL puede poblar las
--      tablas de hechos y las dimensiones sin inventar datos).
--
-- Uso:
--   psql -v ON_ERROR_STOP=1 -d <base> -f validacion/validar_minimos.sql
--
-- Si alguna validación falla, el script lanza una excepción, psql se
-- detiene por ON_ERROR_STOP y el código de salida es distinto de cero.
-- Si todas pasan, el script imprime el resumen final.
-- =====================================================================

\set ON_ERROR_STOP on
SET client_min_messages TO NOTICE;

-- Helper de aserción. Vive solo en el esquema temporal de la sesión.
CREATE OR REPLACE FUNCTION pg_temp.validar(cond BOOLEAN, mensaje TEXT)
RETURNS VOID AS $$
BEGIN
    IF cond IS NOT TRUE THEN
        RAISE EXCEPTION 'Validación fallida: %', mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- A. Mínimos del conjunto
-- =====================================================================
DO $$
DECLARE
    n_pacientes     bigint;
    n_medicos       bigint;
    n_areas         bigint;
    n_especialidades bigint;
    n_personal      bigint;
    n_camas         bigint;
    n_ingresos      bigint;
    n_realiza       bigint;
    n_prescribe     bigint;
    n_practica      bigint;
    n_facturas      bigint;
    fecha_min       date;
    fecha_max       date;
    n_meses         integer;
    primer_mes      date;
    ultimo_mes      date;
BEGIN
    RAISE NOTICE 'A. Mínimos del conjunto';

    SELECT count(*) INTO n_pacientes FROM "OLTP".PAC;
    PERFORM pg_temp.validar(
        n_pacientes >= 30,
        format('Pacientes: %s (mínimo 30)', n_pacientes)
    );

    SELECT count(*) INTO n_medicos FROM "OLTP".MEDICO;
    PERFORM pg_temp.validar(
        n_medicos >= 10,
        format('Médicos: %s (mínimo 10)', n_medicos)
    );

    SELECT count(*) INTO n_areas FROM "OLTP".AREA;
    PERFORM pg_temp.validar(n_areas = 10, format('Áreas: %s (deben ser 10)', n_areas));

    SELECT count(*) INTO n_especialidades FROM "OLTP".ESPECIALIDAD;
    PERFORM pg_temp.validar(
        (SELECT count(*) FROM (
            SELECT id_especialidad
            FROM "OLTP".AREA
            GROUP BY id_especialidad
            HAVING count(*) <> 1
        ) duplicadas) = 0,
        'Hay especialidades con más de un área o áreas repetidas'
    );
    PERFORM pg_temp.validar(
        (SELECT count(DISTINCT id_especialidad) FROM "OLTP".AREA) = n_especialidades,
        format(
            'Áreas por especialidad: %s áreas cubren %s especialidades',
            n_areas, n_especialidades
        )
    );

    SELECT count(*) INTO n_personal FROM "OLTP".PERSONAL_SANITARIO;
    PERFORM pg_temp.validar(
        n_personal >= 10,
        format('Personal sanitario: %s (mínimo 10)', n_personal)
    );

    SELECT count(*) INTO n_camas FROM "OLTP".CAMA;
    PERFORM pg_temp.validar(n_camas = 26, format('Camas: %s (deben ser 26)', n_camas));

    -- Período: fechas de hospitalización, servicios y emisión de facturas.
    -- Los vencimientos y pagos pueden caer después del corte y se validan
    -- por separado en la sección E.
    SELECT min(fecha), max(fecha)
    INTO fecha_min, fecha_max
    FROM (
        SELECT f_ingreso AS fecha FROM "OLTP".INGRESO
        UNION ALL
        SELECT f_alta FROM "OLTP".INGRESO WHERE f_alta IS NOT NULL
        UNION ALL
        SELECT f_inicio FROM "OLTP".OCUPA
        UNION ALL
        SELECT f_elaboracion FROM "OLTP".REALIZA
        UNION ALL
        SELECT f_elaboracion FROM "OLTP".PRESCRIBE
        UNION ALL
        SELECT f FROM "OLTP".PRACTICA
        UNION ALL
        SELECT f_emision FROM "OLTP".FACTURA
    ) fechas;

    PERFORM pg_temp.validar(
        fecha_min >= DATE '2025-11-01' AND fecha_max <= DATE '2026-10-31',
        format(
            'Período: fechas entre %s y %s; se esperaba 2025-11-01..2026-10-31',
            fecha_min, fecha_max
        )
    );

    SELECT
        count(DISTINCT date_trunc('month', fecha)),
        min(date_trunc('month', fecha))::date,
        max(date_trunc('month', fecha))::date
    INTO n_meses, primer_mes, ultimo_mes
    FROM (
        SELECT f_ingreso AS fecha FROM "OLTP".INGRESO
        UNION ALL
        SELECT f_elaboracion FROM "OLTP".REALIZA
        UNION ALL
        SELECT f_elaboracion FROM "OLTP".PRESCRIBE
        UNION ALL
        SELECT f FROM "OLTP".PRACTICA
        UNION ALL
        SELECT f_emision FROM "OLTP".FACTURA
    ) fechas;

    PERFORM pg_temp.validar(
        n_meses = 12 AND primer_mes = DATE '2025-11-01'
        AND ultimo_mes = DATE '2026-10-01',
        format(
            'Meses con datos: %s (%s..%s); se esperaban 12 meses consecutivos',
            n_meses, primer_mes, ultimo_mes
        )
    );

    SELECT count(*) INTO n_ingresos FROM "OLTP".INGRESO;
    PERFORM pg_temp.validar(
        n_ingresos >= 40,
        format('Hospitalizaciones: %s (mínimo 40)', n_ingresos)
    );

    SELECT count(*) INTO n_realiza FROM "OLTP".REALIZA;
    PERFORM pg_temp.validar(
        n_realiza >= 100,
        format('Diagnósticos: %s (mínimo 100)', n_realiza)
    );

    SELECT count(*) INTO n_prescribe FROM "OLTP".PRESCRIBE;
    PERFORM pg_temp.validar(
        n_prescribe >= 100,
        format('Prescripciones: %s (mínimo 100)', n_prescribe)
    );

    SELECT count(*) INTO n_practica FROM "OLTP".PRACTICA;
    PERFORM pg_temp.validar(
        n_practica >= 50,
        format('Intervenciones: %s (mínimo 50)', n_practica)
    );

    SELECT count(*) INTO n_facturas FROM "OLTP".FACTURA;
    PERFORM pg_temp.validar(
        n_facturas >= 200,
        format('Facturas: %s (mínimo 200)', n_facturas)
    );
END;
$$;

-- =====================================================================
-- B. Ingresos, ocupaciones y servicios
-- =====================================================================
DO $$
DECLARE
    n bigint;
BEGIN
    RAISE NOTICE 'B. Ingresos, ocupaciones y servicios';

    -- Todos los servicios pertenecen a un ingreso y al paciente del ingreso.
    SELECT count(*) INTO n
    FROM "OLTP".REALIZA r
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".INGRESO i
        WHERE i.number_ingreso = r.number_ingreso
    );
    PERFORM pg_temp.validar(n = 0, format('Diagnósticos sin ingreso: %s', n));

    SELECT count(*) INTO n
    FROM "OLTP".PRESCRIBE p
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".INGRESO i
        WHERE i.number_ingreso = p.number_ingreso
    );
    PERFORM pg_temp.validar(n = 0, format('Prescripciones sin ingreso: %s', n));

    SELECT count(*) INTO n
    FROM "OLTP".PRACTICA pr
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".INGRESO i
        WHERE i.number_ingreso = pr.number_ingreso
    );
    PERFORM pg_temp.validar(n = 0, format('Intervenciones sin ingreso: %s', n));

    SELECT count(*) INTO n
    FROM "OLTP".REALIZA r
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE r.ci_pac <> i.ci_pac;
    PERFORM pg_temp.validar(
        n = 0, format('Diagnósticos con paciente distinto al ingreso: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".PRESCRIBE p
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE p.ci_pac <> i.ci_pac;
    PERFORM pg_temp.validar(
        n = 0, format('Prescripciones con paciente distinto al ingreso: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".PRACTICA pr
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE pr.ci_pac <> i.ci_pac;
    PERFORM pg_temp.validar(
        n = 0, format('Intervenciones con paciente distinto al ingreso: %s', n)
    );

    -- Fechas de servicio dentro del período de internación. Para las
    -- estancias activas el límite superior es la fecha de corte.
    SELECT count(*) INTO n
    FROM "OLTP".REALIZA r
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE r.f_elaboracion < i.f_ingreso
       OR r.f_elaboracion > coalesce(i.f_alta, DATE '2026-10-31');
    PERFORM pg_temp.validar(
        n = 0, format('Diagnósticos fuera del período de internación: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".PRESCRIBE p
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE p.f_elaboracion < i.f_ingreso
       OR p.f_elaboracion > coalesce(i.f_alta, DATE '2026-10-31');
    PERFORM pg_temp.validar(
        n = 0, format('Prescripciones fuera del período de internación: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".PRACTICA pr
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE pr.f < i.f_ingreso
       OR pr.f > coalesce(i.f_alta, DATE '2026-10-31');
    PERFORM pg_temp.validar(
        n = 0, format('Intervenciones fuera del período de internación: %s', n)
    );

    -- El período prescrito no excede la estancia (último día = alta - 1).
    SELECT count(*) INTO n
    FROM "OLTP".PRESCRIBE p
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE p.f_inicio < i.f_ingreso
       OR p.f_fin > coalesce(i.f_alta - 1, DATE '2026-10-31');
    PERFORM pg_temp.validar(
        n = 0, format('Prescripciones que exceden la internación: %s', n)
    );

    -- Una cama no puede estar ocupada por dos ingresos en fechas superpuestas.
    WITH ocupaciones AS (
        SELECT
            o.number_ingreso,
            o.ci_pac,
            o.id_number_cama,
            o.f_inicio,
            o.f_inicio + (o.cantidad_dias::int - 1) AS f_fin
        FROM "OLTP".OCUPA o
    )
    SELECT count(*) INTO n
    FROM ocupaciones a
    JOIN ocupaciones b
      ON a.id_number_cama = b.id_number_cama
     AND a.number_ingreso < b.number_ingreso
    WHERE a.f_inicio <= b.f_fin
      AND b.f_inicio <= a.f_fin;
    PERFORM pg_temp.validar(n = 0, format('Solapamientos de cama: %s', n));

    -- Un paciente no puede ocupar dos camas simultáneamente.
    WITH ocupaciones AS (
        SELECT
            o.number_ingreso,
            o.ci_pac,
            o.id_number_cama,
            o.f_inicio,
            o.f_inicio + (o.cantidad_dias::int - 1) AS f_fin
        FROM "OLTP".OCUPA o
    )
    SELECT count(*) INTO n
    FROM ocupaciones a
    JOIN ocupaciones b
      ON a.ci_pac = b.ci_pac
     AND a.id_number_cama <> b.id_number_cama
    WHERE a.f_inicio <= b.f_fin
      AND b.f_inicio <= a.f_fin;
    PERFORM pg_temp.validar(
        n = 0, format('Pacientes en dos camas simultáneas: %s', n)
    );

    -- La cama pertenece al área del ingreso.
    SELECT count(*) INTO n
    FROM "OLTP".OCUPA o
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    JOIN "OLTP".CAMA c ON c.id_number_cama = o.id_number_cama
    WHERE c.id_area_hospital <> i.id_area;
    PERFORM pg_temp.validar(
        n = 0, format('Ocupaciones en camas de otra área: %s', n)
    );

    -- El jefe del área tiene la especialidad del área.
    SELECT count(*) INTO n
    FROM "OLTP".AREA a
    JOIN "OLTP".MEDICO m ON m.ci_medico = a.ci_medico_encargado
    WHERE m.id_especialidad <> a.id_especialidad;
    PERFORM pg_temp.validar(
        n = 0, format('Jefes de área con especialidad distinta: %s', n)
    );

    -- El médico de cada servicio trabaja en el área del ingreso.
    SELECT count(*) INTO n
    FROM (
        SELECT i.id_area, r.ci_medico
        FROM "OLTP".REALIZA r
        JOIN "OLTP".INGRESO i USING (number_ingreso)
        UNION ALL
        SELECT i.id_area, p.ci_medico
        FROM "OLTP".PRESCRIBE p
        JOIN "OLTP".INGRESO i USING (number_ingreso)
        UNION ALL
        SELECT i.id_area, pr.ci_medico
        FROM "OLTP".PRACTICA pr
        JOIN "OLTP".INGRESO i USING (number_ingreso)
    ) s
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".TRABAJA t
        WHERE t.id_medico = s.ci_medico
          AND t.id_area = s.id_area
    );
    PERFORM pg_temp.validar(
        n = 0, format('Servicios con médico fuera del área del ingreso: %s', n)
    );

    -- En Pediatría solo hay pacientes menores de 18 años al ingreso.
    SELECT count(*) INTO n
    FROM "OLTP".INGRESO i
    JOIN "OLTP".PAC pa USING (ci_pac)
    JOIN "OLTP".AREA a USING (id_area)
    JOIN "OLTP".ESPECIALIDAD e USING (id_especialidad)
    WHERE e.descrip = 'PEDIATRIA'
      AND pa.f_nacimiento <= i.f_ingreso - INTERVAL '18 years';
    PERFORM pg_temp.validar(
        n = 0, format('Adultos internados en Pediatría: %s', n)
    );

    -- Estatus de la ocupación coherente con el alta del ingreso.
    SELECT count(*) INTO n
    FROM "OLTP".OCUPA o
    JOIN "OLTP".INGRESO i USING (number_ingreso)
    WHERE (o.estatus = 'ACTIVA') <> (i.f_alta IS NULL);
    PERFORM pg_temp.validar(
        n = 0, format('Estatus de ocupación incoherente con el alta: %s', n)
    );

    -- Las estancias activas terminan en la fecha de corte.
    SELECT count(*) INTO n
    FROM "OLTP".OCUPA o
    WHERE o.estatus = 'ACTIVA'
      AND o.f_inicio + (o.cantidad_dias::int - 1) <> DATE '2026-10-31';
    PERFORM pg_temp.validar(
        n = 0, format('Estancias ACTIVA que no terminan en el corte: %s', n)
    );

    -- Días cubiertos por el seguro dentro de los días de estancia y de
    -- los días de cobertura de la póliza.
    SELECT count(*) INTO n
    FROM "OLTP".OCUPA o
    LEFT JOIN "OLTP".POLIZA p ON p.id_poliza = o.id_poliza
    WHERE (o.id_poliza IS NULL AND o.dias_cubiertos_seguro <> 0)
       OR (o.id_poliza IS NOT NULL AND o.dias_cubiertos_seguro > p.dias_cobertura);
    PERFORM pg_temp.validar(
        n = 0, format('Días cubiertos por seguro inconsistentes: %s', n)
    );

    -- Fechas del detalle de factura iguales a la fecha del servicio.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA_DETALLE d
    LEFT JOIN "OLTP".REALIZA r ON r.id_realiza = d.id_realiza
    LEFT JOIN "OLTP".PRESCRIBE p ON p.id_prescripcion = d.id_prescripcion
    LEFT JOIN "OLTP".PRACTICA pr ON pr.id_practica = d.id_practica
    WHERE d.f_servicio <> coalesce(r.f_elaboracion, p.f_elaboracion, pr.f);
    PERFORM pg_temp.validar(
        n = 0, format('Detalles con fecha distinta al servicio: %s', n)
    );

    -- Servicios clínicos completos para el ETL.
    SELECT count(*) INTO n FROM "OLTP".PRESCRIBE
    WHERE dosis_diaria IS NULL OR cant_dias IS NULL
       OR f_inicio IS NULL OR f_fin IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Prescripciones sin dosis, días o fechas: %s', n)
    );
END;
$$;

-- =====================================================================
-- C. Facturación y pólizas
-- =====================================================================
DO $$
DECLARE
    n bigint;
BEGIN
    RAISE NOTICE 'C. Facturación y pólizas';

    -- Cada factura tiene exactamente una línea de detalle.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA f
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".FACTURA_DETALLE d
        WHERE d.id_factura = f.id_factura
    );
    PERFORM pg_temp.validar(n = 0, format('Facturas sin detalle: %s', n));

    SELECT count(*) INTO n
    FROM (
        SELECT id_factura
        FROM "OLTP".FACTURA_DETALLE
        GROUP BY id_factura
        HAVING count(*) <> 1
    ) d;
    PERFORM pg_temp.validar(
        n = 0, format('Facturas con más de un detalle: %s', n)
    );

    -- Cada servicio se factura una sola vez y todos los servicios se facturan.
    SELECT count(*) INTO n
    FROM (
        SELECT id_realiza FROM "OLTP".FACTURA_DETALLE
        WHERE id_realiza IS NOT NULL
        GROUP BY id_realiza HAVING count(*) > 1
        UNION ALL
        SELECT id_prescripcion FROM "OLTP".FACTURA_DETALLE
        WHERE id_prescripcion IS NOT NULL
        GROUP BY id_prescripcion HAVING count(*) > 1
        UNION ALL
        SELECT id_practica FROM "OLTP".FACTURA_DETALLE
        WHERE id_practica IS NOT NULL
        GROUP BY id_practica HAVING count(*) > 1
    ) repetidos;
    PERFORM pg_temp.validar(
        n = 0, format('Servicios facturados más de una vez: %s', n)
    );

    SELECT count(*) INTO n
    FROM (
        SELECT r.id_realiza FROM "OLTP".REALIZA r
        WHERE NOT EXISTS (
            SELECT 1 FROM "OLTP".FACTURA_DETALLE d
            WHERE d.id_realiza = r.id_realiza
        )
        UNION ALL
        SELECT p.id_prescripcion FROM "OLTP".PRESCRIBE p
        WHERE NOT EXISTS (
            SELECT 1 FROM "OLTP".FACTURA_DETALLE d
            WHERE d.id_prescripcion = p.id_prescripcion
        )
        UNION ALL
        SELECT pr.id_practica FROM "OLTP".PRACTICA pr
        WHERE NOT EXISTS (
            SELECT 1 FROM "OLTP".FACTURA_DETALLE d
            WHERE d.id_practica = pr.id_practica
        )
    ) sin_factura;
    PERFORM pg_temp.validar(
        n = 0, format('Servicios sin factura: %s', n)
    );

    -- Cada detalle referencia exactamente un servicio.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA_DETALLE
    WHERE (CASE WHEN id_realiza IS NOT NULL THEN 1 ELSE 0 END
         + CASE WHEN id_prescripcion IS NOT NULL THEN 1 ELSE 0 END
         + CASE WHEN id_practica IS NOT NULL THEN 1 ELSE 0 END) <> 1;
    PERFORM pg_temp.validar(
        n = 0, format('Detalles sin exactamente un servicio: %s', n)
    );

    -- Montos: total = suma del detalle y cubierto + paciente = total.
    SELECT count(*) INTO n
    FROM (
        SELECT f.id_factura
        FROM "OLTP".FACTURA f
        JOIN "OLTP".FACTURA_DETALLE d USING (id_factura)
        GROUP BY f.id_factura, f.monto_total
        HAVING f.monto_total <> sum(d.monto)
    ) diferencias;
    PERFORM pg_temp.validar(
        n = 0, format('Facturas con total distinto a su detalle: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".FACTURA
    WHERE monto_cubierto + monto_paciente <> monto_total;
    PERFORM pg_temp.validar(
        n = 0, format('Facturas con montos incoherentes: %s', n)
    );

    -- El monto del detalle coincide con el costo del catálogo del servicio.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA_DETALLE d
    LEFT JOIN "OLTP".REALIZA r ON r.id_realiza = d.id_realiza
    LEFT JOIN "OLTP".DIAGN dg ON dg.id_diagn = r.id_diagn
    LEFT JOIN "OLTP".PRESCRIBE p ON p.id_prescripcion = d.id_prescripcion
    LEFT JOIN "OLTP".TRATAMIENTO tr ON tr.id_tratamiento = p.id_tratamiento
    LEFT JOIN "OLTP".PRACTICA pr ON pr.id_practica = d.id_practica
    WHERE d.monto <> round(coalesce(dg.costo, tr.costo, pr.costo)::numeric, 2);
    PERFORM pg_temp.validar(
        n = 0, format('Detalles con monto distinto al costo: %s', n)
    );

    -- La cobertura no supera el monto del servicio ni la cobertura de la póliza.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA f
    JOIN "OLTP".POLIZA p ON p.id_poliza = f.id_poliza
    WHERE f.monto_cubierto > p.cobertura;
    PERFORM pg_temp.validar(
        n = 0, format('Facturas cubiertas por encima de la póliza: %s', n)
    );

    -- La póliza usada está aprobada, vigente en la fecha del servicio y
    -- cubre la categoría facturada.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA f
    JOIN "OLTP".FACTURA_DETALLE d USING (id_factura)
    JOIN "OLTP".TIPO_SERVICIO t USING (id_tipo_servicio)
    JOIN "OLTP".POLIZA p ON p.id_poliza = f.id_poliza
    WHERE f.monto_cubierto > 0
      AND NOT (
          p.aprobada
          AND p.f_desde <= d.f_servicio
          AND (p.f_hasta IS NULL OR p.f_hasta >= d.f_servicio)
          AND CASE t.categoria_poliza
                  WHEN 'EXAMENES' THEN p.examenes
                  WHEN 'RADIOGRAFIAS' THEN p.radiografias
                  WHEN 'HOSPITALIZACION' THEN p.hospitalizacion
                  WHEN 'CIRUGIA' THEN p.cirugia
              END
      );
    PERFORM pg_temp.validar(
        n = 0, format('Facturas con póliza que no cubre el servicio: %s', n)
    );

    -- Tipo de cliente coherente con la cobertura.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA
    WHERE (tipo_cliente = 'PACIENTE'
           AND (monto_cubierto <> 0 OR id_poliza IS NOT NULL
                OR id_aseguradora IS NOT NULL))
       OR (tipo_cliente = 'ASEGURADORA'
           AND (monto_cubierto <= 0 OR id_poliza IS NULL
                OR id_aseguradora IS NULL));
    PERFORM pg_temp.validar(
        n = 0, format('Facturas con tipo de cliente incoherente: %s', n)
    );

    -- Pólizas principales duplicadas.
    SELECT count(*) INTO n
    FROM (
        SELECT ci_pac
        FROM "OLTP".POLIZA
        WHERE tipo_poliza = 'PRINCIPAL'
        GROUP BY ci_pac
        HAVING count(*) > 1
    ) duplicadas;
    PERFORM pg_temp.validar(
        n = 0, format('Pacientes con más de una póliza principal: %s', n)
    );

    -- Estados y fechas de pago.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA f
    JOIN "OLTP".ESTADO_FACTURA e USING (id_estado)
    WHERE e.descrip = 'PAGADA'
      AND (f.f_pago IS NULL OR f.monto_pagado IS NULL);
    PERFORM pg_temp.validar(
        n = 0, format('Facturas pagadas sin fecha o monto de pago: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".FACTURA f
    JOIN "OLTP".ESTADO_FACTURA e USING (id_estado)
    WHERE e.descrip IN ('PENDIENTE', 'VENCIDA')
      AND (f.f_pago IS NOT NULL OR f.monto_pagado IS NOT NULL);
    PERFORM pg_temp.validar(
        n = 0, format('Facturas pendientes/vencidas con pago: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".FACTURA f
    JOIN "OLTP".ESTADO_FACTURA e USING (id_estado)
    WHERE e.descrip = 'VENCIDA'
      AND f.f_vencimiento >= DATE '2026-10-31';
    PERFORM pg_temp.validar(
        n = 0, format('Facturas vencidas sin mora al corte: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".FACTURA
    WHERE f_pago IS NOT NULL AND f_pago > DATE '2026-10-31';
    PERFORM pg_temp.validar(
        n = 0, format('Pagos posteriores a la fecha de corte: %s', n)
    );

    -- Fecha de vencimiento posterior a la emisión.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA
    WHERE f_vencimiento < f_emision;
    PERFORM pg_temp.validar(
        n = 0, format('Facturas con vencimiento anterior a la emisión: %s', n)
    );
END;
$$;

-- =====================================================================
-- D. Efectos secundarios (RN-08)
-- =====================================================================
DO $$
DECLARE
    n bigint;
BEGIN
    RAISE NOTICE 'D. Efectos secundarios';

    SELECT count(*) INTO n FROM "OLTP".EFECTO_SECUNDARIO_PACIENTE;
    PERFORM pg_temp.validar(n = 20, format('Efectos secundarios: %s (deben ser 20)', n));

    SELECT count(*) INTO n
    FROM "OLTP".EFECTO_SECUNDARIO_PACIENTE e
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".PRESCRIBE p
        WHERE p.id_prescripcion = e.id_prescripcion
    );
    PERFORM pg_temp.validar(
        n = 0, format('Efectos con prescripción inexistente: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".EFECTO_SECUNDARIO_PACIENTE e
    JOIN "OLTP".PRESCRIBE p USING (id_prescripcion)
    WHERE e.fecha < p.f_inicio OR e.fecha > p.f_fin;
    PERFORM pg_temp.validar(
        n = 0, format('Efectos fuera del período de la prescripción: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".EFECTO_SECUNDARIO_PACIENTE
    WHERE btrim(descripcion) = ''
       OR gravedad NOT IN ('LEVE', 'MODERADO', 'GRAVE');
    PERFORM pg_temp.validar(
        n = 0, format('Efectos sin descripción o con gravedad inválida: %s', n)
    );

    SELECT count(*) INTO n
    FROM (
        SELECT id_prescripcion
        FROM "OLTP".EFECTO_SECUNDARIO_PACIENTE
        GROUP BY id_prescripcion
        HAVING count(*) > 1
    ) repetidas;
    PERFORM pg_temp.validar(
        n = 0, format('Prescripciones con más de un efecto: %s', n)
    );

    SELECT count(*) INTO n
    FROM (
        SELECT a.id_area
        FROM "OLTP".AREA a
        LEFT JOIN "OLTP".INGRESO i USING (id_area)
        LEFT JOIN "OLTP".PRESCRIBE p USING (number_ingreso)
        LEFT JOIN "OLTP".EFECTO_SECUNDARIO_PACIENTE e USING (id_prescripcion)
        GROUP BY a.id_area
        HAVING count(e.id_efecto) <> 2
    ) areas_incompletas;
    PERFORM pg_temp.validar(
        n = 0, format('Áreas que no tienen exactamente 2 efectos: %s', n)
    );
END;
$$;

-- =====================================================================
-- E. Cobertura del mapeo OLTP -> DWH
-- =====================================================================
DO $$
DECLARE
    n bigint;
BEGIN
    RAISE NOTICE 'E. Cobertura del mapeo OLTP -> DWH';

    -- dim_tiempo: todas las fechas requeridas caen en el rango soportado.
    -- Los vencimientos pueden llegar hasta 30 días después del corte.
    SELECT count(*) INTO n
    FROM (
        SELECT f_ingreso AS fecha FROM "OLTP".INGRESO
        UNION ALL
        SELECT f_alta FROM "OLTP".INGRESO WHERE f_alta IS NOT NULL
        UNION ALL
        SELECT f_inicio FROM "OLTP".OCUPA
        UNION ALL
        SELECT f_elaboracion FROM "OLTP".REALIZA
        UNION ALL
        SELECT f_elaboracion FROM "OLTP".PRESCRIBE
        UNION ALL
        SELECT f_inicio FROM "OLTP".PRESCRIBE
        UNION ALL
        SELECT f_fin FROM "OLTP".PRESCRIBE
        UNION ALL
        SELECT f FROM "OLTP".PRACTICA
        UNION ALL
        SELECT f_emision FROM "OLTP".FACTURA
        UNION ALL
        SELECT f_vencimiento FROM "OLTP".FACTURA
        UNION ALL
        SELECT f_pago FROM "OLTP".FACTURA WHERE f_pago IS NOT NULL
        UNION ALL
        SELECT fecha FROM "OLTP".EFECTO_SECUNDARIO_PACIENTE
    ) fechas
    WHERE fecha < DATE '2025-11-01' OR fecha > DATE '2026-11-30';
    PERFORM pg_temp.validar(
        n = 0, format('Fechas fuera del rango de dim_tiempo: %s', n)
    );

    -- dim_poliza
    SELECT count(*) INTO n
    FROM "OLTP".POLIZA p
    JOIN "OLTP".ASEGURADORA a USING (id_aseguradora)
    WHERE a.nombre IS NULL
       OR p.tipo_poliza IS NULL
       OR p.hospitalizacion IS NULL
       OR p.cirugia IS NULL
       OR p.maternidad IS NULL
       OR p.radiografias IS NULL
       OR p.examenes IS NULL
       OR p.ambulancia IS NULL
       OR p.cobertura IS NULL
       OR p.aprobada IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Pólizas incompletas para dim_poliza: %s', n)
    );

    -- dim_estado_factura y dim_tipo_servicio
    SELECT count(*) INTO n
    FROM "OLTP".ESTADO_FACTURA
    WHERE descrip IN ('PAGADA', 'PENDIENTE', 'VENCIDA');
    PERFORM pg_temp.validar(
        n = 3, format('Estados de factura: %s (deben ser 3)', n)
    );

    SELECT count(*) INTO n FROM "OLTP".TIPO_SERVICIO;
    PERFORM pg_temp.validar(
        n = 3, format('Tipos de servicio: %s (deben ser 3)', n)
    );

    -- dim_paciente
    SELECT count(*) INTO n
    FROM "OLTP".PAC
    WHERE ci_pac IS NULL OR nombre IS NULL OR apellido IS NULL
       OR f_nacimiento IS NULL OR tipo_sangre IS NULL
       OR nacionalidad IS NULL OR id_estado_civil IS NULL
       OR id_sx IS NULL OR id_ciudad IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Pacientes incompletos para dim_paciente: %s', n)
    );

    -- dim_medico (incluye área, piso y pasillo desde TRABAJA y AREA)
    SELECT count(*) INTO n
    FROM "OLTP".MEDICO m
    WHERE m.cod_colegio_medico IS NULL OR m.nombre IS NULL
       OR m.apellido IS NULL OR m.f_nacimiento IS NULL
       OR m.f_contratacion IS NULL OR m.id_sx IS NULL
       OR m.id_estado_civil IS NULL OR m.id_especialidad IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM "OLTP".TRABAJA t
           JOIN "OLTP".AREA a USING (id_area)
           WHERE t.id_medico = m.ci_medico
       );
    PERFORM pg_temp.validar(
        n = 0, format('Médicos incompletos para dim_medico: %s', n)
    );

    -- dim_personal_sanit: los datos de sexo y estado civil no existen en el
    -- OLTP, se documenta como limitación en docs/calidad_datos.md.
    SELECT count(*) INTO n
    FROM "OLTP".PERSONAL_SANITARIO
    WHERE ci_personal IS NULL OR nombre IS NULL OR apellido IS NULL
       OR funcion IS NULL OR id_area IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Personal incompleto para dim_personal_sanit: %s', n)
    );

    -- dim_riesgo
    SELECT count(*) INTO n
    FROM "OLTP".PRACTICA
    WHERE riesgo IS NULL OR riesgo NOT IN ('BAJO', 'MEDIO', 'ALTO');
    PERFORM pg_temp.validar(
        n = 0, format('Intervenciones con riesgo inválido: %s', n)
    );
    SELECT count(DISTINCT riesgo) INTO n FROM "OLTP".PRACTICA;
    PERFORM pg_temp.validar(
        n = 3, format('Niveles de riesgo usados: %s (deben ser 3)', n)
    );

    -- dim_intervencion, dim_diagnostico y dim_tratamiento
    SELECT count(*) INTO n
    FROM "OLTP".INTERVENCION
    WHERE descrip IS NULL OR tipo IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Intervenciones incompletas para dim_intervencion: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".DIAGN
    WHERE nombre IS NULL OR costo IS NULL OR costo < 0;
    PERFORM pg_temp.validar(
        n = 0, format('Diagnósticos incompletos para dim_diagnostico: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".TRATAMIENTO
    WHERE descrip IS NULL OR costo IS NULL OR costo < 0;
    PERFORM pg_temp.validar(
        n = 0, format('Tratamientos incompletos para dim_tratamiento: %s', n)
    );

    -- dim_proveedor y dim_medicamento
    SELECT count(*) INTO n
    FROM "OLTP".PROVEE p
    WHERE p.nombre IS NULL OR p.rif IS NULL OR p.telefono IS NULL
       OR p.direccion IS NULL OR p.id_tipo IS NULL OR p.id_ciudad IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Proveedores incompletos para dim_proveedor: %s', n)
    );

    SELECT count(*) INTO n
    FROM "OLTP".MEDICINA m
    WHERE m.nombre IS NULL OR m.presentacion IS NULL
       OR m.posologia IS NULL OR m.efectos_secundarios IS NULL
       OR m.id_provee IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Medicinas incompletas para dim_medicamento: %s', n)
    );

    -- fact_facturacion: claves de dimensión resolubles para cada factura.
    SELECT count(*) INTO n
    FROM "OLTP".FACTURA f
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".FACTURA_DETALLE d
        WHERE d.id_factura = f.id_factura
    )
    OR NOT EXISTS (
        SELECT 1 FROM "OLTP".OCUPA o
        WHERE o.number_ingreso = f.number_ingreso
    )
    OR f.f_emision IS NULL
    OR f.id_estado IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Facturas sin claves para fact_facturacion: %s', n)
    );

    -- fact_diagnostico
    SELECT count(*) INTO n
    FROM "OLTP".REALIZA
    WHERE ci_medico IS NULL OR ci_pac IS NULL OR id_diagn IS NULL
       OR f_elaboracion IS NULL OR number_ingreso IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Diagnósticos sin claves para fact_diagnostico: %s', n)
    );

    -- fact_tratamiento: además, cada tratamiento usado tiene medicina.
    SELECT count(*) INTO n
    FROM "OLTP".PRESCRIBE
    WHERE ci_medico IS NULL OR ci_pac IS NULL OR id_tratamiento IS NULL
       OR f_elaboracion IS NULL OR f_inicio IS NULL OR f_fin IS NULL
       OR number_ingreso IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Prescripciones sin claves para fact_tratamiento: %s', n)
    );

    SELECT count(*) INTO n
    FROM (
        SELECT DISTINCT id_tratamiento FROM "OLTP".PRESCRIBE
    ) p
    WHERE NOT EXISTS (
        SELECT 1 FROM "OLTP".APLICA a
        WHERE a.id_tratamiento = p.id_tratamiento
    );
    PERFORM pg_temp.validar(
        n = 0, format('Tratamientos usados sin medicina: %s', n)
    );

    -- fact_intervencion
    SELECT count(*) INTO n
    FROM "OLTP".PRACTICA
    WHERE ci_medico IS NULL OR ci_pac IS NULL OR id_intervencion IS NULL
       OR ci_personal_sanitario IS NULL OR f IS NULL
       OR riesgo IS NULL OR number_ingreso IS NULL;
    PERFORM pg_temp.validar(
        n = 0, format('Intervenciones sin claves para fact_intervencion: %s', n)
    );

    -- Cada ingreso debe tener una sola ocupación para derivar cama y días.
    SELECT count(*) INTO n
    FROM (
        SELECT number_ingreso
        FROM "OLTP".OCUPA
        GROUP BY number_ingreso
        HAVING count(*) <> 1
    ) o;
    PERFORM pg_temp.validar(
        n = 0, format('Ingresos sin exactamente una ocupación: %s', n)
    );
END;
$$;

-- =====================================================================
-- Resumen (solo se alcanza si todas las validaciones pasaron)
-- =====================================================================
DO $$
BEGIN
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TODAS LAS VALIDACIONES PASARON';
    RAISE NOTICE '====================================================';
END;
$$;

SELECT orden, elemento, valor, referencia
FROM (
    SELECT 1 AS orden, 'Pacientes' AS elemento,
           count(*)::text AS valor, '>= 30' AS referencia
    FROM "OLTP".PAC
    UNION ALL
    SELECT 2, 'Médicos', count(*)::text, '>= 10' FROM "OLTP".MEDICO
    UNION ALL
    SELECT 3, 'Áreas', count(*)::text, '= 10' FROM "OLTP".AREA
    UNION ALL
    SELECT 4, 'Especialidades', count(*)::text, '= 10' FROM "OLTP".ESPECIALIDAD
    UNION ALL
    SELECT 5, 'Personal sanitario', count(*)::text, '>= 10'
    FROM "OLTP".PERSONAL_SANITARIO
    UNION ALL
    SELECT 6, 'Camas', count(*)::text, '= 26' FROM "OLTP".CAMA
    UNION ALL
    SELECT 7, 'Hospitalizaciones', count(*)::text, '>= 40' FROM "OLTP".INGRESO
    UNION ALL
    SELECT 8, 'Diagnósticos', count(*)::text, '>= 100' FROM "OLTP".REALIZA
    UNION ALL
    SELECT 9, 'Prescripciones', count(*)::text, '>= 100' FROM "OLTP".PRESCRIBE
    UNION ALL
    SELECT 10, 'Intervenciones', count(*)::text, '>= 50' FROM "OLTP".PRACTICA
    UNION ALL
    SELECT 11, 'Facturas', count(*)::text, '>= 200' FROM "OLTP".FACTURA
    UNION ALL
    SELECT 12, 'Detalles de factura', count(*)::text, '= facturas'
    FROM "OLTP".FACTURA_DETALLE
    UNION ALL
    SELECT 13, 'Pólizas', count(*)::text, 'informativo' FROM "OLTP".POLIZA
    UNION ALL
    SELECT 14, 'Efectos secundarios', count(*)::text, '= 20'
    FROM "OLTP".EFECTO_SECUNDARIO_PACIENTE
    UNION ALL
    SELECT 15, 'Facturas pagadas', count(*)::text, 'informativo'
    FROM "OLTP".FACTURA f JOIN "OLTP".ESTADO_FACTURA e USING (id_estado)
    WHERE e.descrip = 'PAGADA'
    UNION ALL
    SELECT 16, 'Facturas pendientes', count(*)::text, 'informativo'
    FROM "OLTP".FACTURA f JOIN "OLTP".ESTADO_FACTURA e USING (id_estado)
    WHERE e.descrip = 'PENDIENTE'
    UNION ALL
    SELECT 17, 'Facturas vencidas', count(*)::text, 'informativo'
    FROM "OLTP".FACTURA f JOIN "OLTP".ESTADO_FACTURA e USING (id_estado)
    WHERE e.descrip = 'VENCIDA'
) resumen
ORDER BY orden;
