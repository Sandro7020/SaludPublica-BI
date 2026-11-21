#!/usr/bin/env python3
"""Generador determinista de los datos transaccionales del OLTP.

Fase 4: ingresos hospitalarios y ocupacion de camas.
Fase 5: diagnosticos, prescripciones e intervenciones.
Fase 6: facturacion de los servicios y seguimiento de cobro.
Fase 7: efectos secundarios de las prescripciones.

El generador no depende de la base de datos: usa los identificadores y
perfiles definidos en las fases 1 a 3 y escribe el SQL de carga. Con la
misma version del script siempre produce los mismos archivos.

Uso:
    python3 oltp/datos_prueba/generar_datos.py
    python3 oltp/datos_prueba/generar_datos.py --solo-fase 4 --out /tmp/04.sql
    python3 oltp/datos_prueba/generar_datos.py --solo-fase 5 --out-servicios /tmp/05.sql
    python3 oltp/datos_prueba/generar_datos.py --solo-fase 6 --out-facturacion /tmp/06.sql
    python3 oltp/datos_prueba/generar_datos.py --solo-fase 7 --out-efectos /tmp/07.sql
"""

from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from datetime import date, timedelta
from pathlib import Path

PERIODO_INICIO = date(2025, 11, 1)
PERIODO_FIN = date(2026, 10, 31)
MESES = [(2025, 11), (2025, 12)] + [(2026, mes) for mes in range(1, 11)]

# Paciente -> (area, diagnostico principal). El diagnostico se usa en la
# Fase 5 para que el primer REALIZA coincida con el area del ingreso.
PERFILES = {
    20364201: (1, 1),   20364205: (1, 1),   20364209: (1, 1),   20364213: (1, 1),
    20364202: (2, 17),  20364204: (2, 17),  20364206: (2, 17),  20364208: (2, 17),
    20364210: (2, 17),
    20364203: (3, 4),   20364207: (3, 4),   20364211: (3, 4),   20364215: (3, 4),
    20364212: (4, 2),   20364216: (4, 2),   20364218: (4, 10),  20364224: (4, 2),
    20364217: (5, 5),   20364225: (5, 12),  20364226: (5, 5),
    20364228: (6, 6),   20364229: (6, 13),  20364231: (6, 13),  20364232: (6, 6),
    20364227: (7, 3),   20364230: (7, 3),   20364234: (7, 11),  20364238: (7, 3),
    20364240: (7, 11),
    20364214: (8, 7),   20364235: (8, 7),   20364236: (8, 14),  20364239: (8, 14),
    20364219: (9, 19),  20364220: (9, 15),  20364237: (9, 18),
    20364221: (10, 8),  20364222: (10, 9),  20364223: (10, 8),  20364233: (10, 9),
}

# 5 pacientes con 3 ingresos, 10 con 2 y 25 con 1: total 60.
CON_TRES = {20364201, 20364209, 20364217, 20364225, 20364233}
CON_DOS = {
    20364202, 20364204, 20364206, 20364208, 20364210,
    20364212, 20364214, 20364216, 20364218, 20364220,
}

# Pólizas de la Fase 3:
# CI -> (id_principal, aprobada, hospitalizacion, dias,
#        id_secundaria, aprobada_sec, hospitalizacion_sec, dias_sec)
# None significa que el paciente no tiene póliza.
POLIZAS = {
    20364201: (1, True, False, 0, 27, True, True, 10),
    20364202: (2, True, True, 10, 28, True, False, 0),
    20364203: (3, True, True, 5, None, False, False, 0),
    20364204: (4, False, False, 0, 29, True, True, 5),
    20364205: (5, True, True, 15, None, False, False, 0),
    20364206: (6, True, False, 0, None, False, False, 0),
    20364207: (7, False, False, 0, 30, True, True, 3),
    20364208: (8, True, True, 10, None, False, False, 0),
    20364209: (9, False, True, 3, None, False, False, 0),
    20364210: (10, True, True, 15, None, False, False, 0),
    20364211: (11, False, True, 30, None, False, False, 0),
    20364212: (12, True, True, 30, None, False, False, 0),
    20364213: (13, True, False, 0, 31, True, True, 10),
    20364214: (14, True, True, 10, None, False, False, 0),
    20364215: (15, False, False, 0, None, False, False, 0),
    20364216: (16, True, True, 15, None, False, False, 0),
    20364217: (17, False, True, 5, 32, True, False, 0),
    20364218: (18, True, False, 0, None, False, False, 0),
    20364219: (19, False, True, 10, None, False, False, 0),
    20364220: (20, True, False, 0, 33, True, True, 15),
    20364221: (21, True, False, 0, None, False, False, 0),
    20364222: (22, True, True, 30, None, False, False, 0),
    20364223: (23, False, True, 15, None, False, False, 0),
    20364224: (24, True, True, 10, None, False, False, 0),
    20364225: (25, False, True, 30, None, False, False, 0),
    20364226: (26, True, True, 5, 34, True, False, 0),
    20364228: (35, True, True, 5, None, False, False, 0),
    20364229: (36, True, True, 10, None, False, False, 0),
    20364230: (37, True, True, 15, None, False, False, 0),
    20364232: (38, True, False, 0, None, False, False, 0),
    20364233: (39, True, True, 30, None, False, False, 0),
    20364235: (40, False, True, 3, None, False, False, 0),
    20364236: (41, True, True, 10, None, False, False, 0),
    20364237: (42, True, True, 30, None, False, False, 0),
}

CAMAS = {
    1: [301, 302, 303, 304],
    2: [401, 402, 403, 404],
    3: [201, 202],
    4: [501, 502],
    5: [601, 602],
    6: [701, 702],
    7: [101, 102, 103, 104],
    8: [801, 802],
    9: [901, 902],
    10: [1001, 1002],
}

MEDICOS = {
    1: [10000001, 10000011],
    2: [10000002],
    3: [10000003],
    4: [10000004],
    5: [10000005],
    6: [10000006],
    7: [10000007, 10000012],
    8: [10000008],
    9: [10000009],
    10: [10000010],
}

COSTO_DIARIO_BASE = {
    1: 1800,
    2: 2600,
    3: 1400,
    4: 1700,
    5: 2000,
    6: 2400,
    7: 1600,
    8: 2200,
    9: 3200,
    10: 2800,
}

# ---------------------------------------------------------------------------
# Fase 5 - Servicios
# ---------------------------------------------------------------------------

# Diagnosticos compatibles con cada area. El primero del ingreso es el
# diagnostico principal del perfil; el segundo se toma de esta lista.
DIAGNOSTICOS_POR_AREA = {
    1: [1, 20],
    2: [17, 22],
    3: [4, 21],
    4: [2, 10],
    5: [5, 12],
    6: [6, 13],
    7: [3, 11],
    8: [7, 14],
    9: [15, 18, 19],
    10: [8, 9],
}

# Diagnosticos que solo pueden asignarse a pacientes de un sexo.
DIAGNOSTICOS_SOLO_FEMENINO = {15, 17, 22}
DIAGNOSTICOS_SOLO_MASCULINO = {18}

# Diagnostico principal -> tratamiento principal compatible.
TRATAMIENTO_PRINCIPAL = {
    1: 1, 2: 3, 3: 4, 4: 5, 5: 6, 6: 12, 7: 7, 8: 8, 9: 8, 10: 11,
    11: 10, 12: 6, 13: 12, 14: 7, 15: 9, 16: 2, 17: 2, 18: 9, 19: 9,
    20: 1, 21: 5, 22: 2,
}

# Tratamiento secundario por area. Las areas 4 y 7 usan el otro tratamiento
# de su par para no repetir el principal.
TRATAMIENTO_SECUNDARIO = {
    1: 1, 2: 2, 3: 2, 5: 2, 6: 12, 8: 7, 9: 9, 10: 2,
}

# Posologia de la primera medicina asociada a cada tratamiento (APLICA).
DOSIS_TRATAMIENTO = {
    1: "1 TABLETA CADA 12 HORAS",
    2: "1 CAPSULA CADA 8 HORAS POR 7 DIAS",
    3: "1 TABLETA CON CADA COMIDA",
    4: "2 INHALACIONES CADA 6 HORAS",
    5: "1 AMPOLLA CADA 12 HORAS",
    6: "1 CAPSULA EN AYUNAS",
    7: "1 TABLETA AL DIA",
    8: "1 TABLETA CADA 8 HORAS",
    9: "1 AMPOLLA CADA 12 HORAS",
    10: "5 ML CADA 6 HORAS",
    11: "1 TABLETA EN AYUNAS",
    12: "1 TABLETA CADA 12 HORAS",
}

# Intervencion compatible con cada area. Traumatologia se decide por el
# diagnostico principal (fractura u artrosis).
INTERVENCION_POR_AREA = {
    1: 11,
    2: 3,
    3: 5,
    4: 12,
    5: 6,
    6: 13,
    7: 14,
    8: 15,
    9: 8,
}
INTERVENCION_POR_DIAGNOSTICO = {
    8: 4,   # fractura de femur -> reduccion de fractura
    9: 10,  # artrosis de rodilla -> artroscopia
}

PERSONAL_POR_AREA = {
    1: 15000001,
    2: 15000003,
    3: 15000005,
    4: 15000006,
    5: 15000007,
    6: 15000008,
    7: 15000009,
    8: 15000010,
    9: 15000011,
    10: 15000012,
}

COSTO_INTERVENCION = {
    1: 25000,
    2: 30000,
    3: 35000,
    4: 28000,
    5: 6000,
    6: 12000,
    7: 20000,
    8: 55000,
    9: 8000,
    10: 22000,
    11: 40000,
    12: 15000,
    13: 10000,
    14: 3500,
    15: 18000,
}
RIESGO_INTERVENCION = {
    1: "ALTO", 2: "ALTO", 3: "ALTO", 4: "MEDIO", 5: "BAJO",
    6: "MEDIO", 7: "MEDIO", 8: "ALTO", 9: "BAJO", 10: "MEDIO",
    11: "ALTO", 12: "MEDIO", 13: "BAJO", 14: "BAJO", 15: "MEDIO",
}
DURACION_INTERVENCION = {
    1: 90, 2: 120, 3: 60, 4: 90, 5: 30, 6: 45, 7: 60, 8: 180,
    9: 30, 10: 60, 11: 90, 12: 45, 13: 30, 14: 20, 15: 60,
}

# ---------------------------------------------------------------------------
# Fase 6 - Facturacion
# ---------------------------------------------------------------------------

# Costos del catalogo de diagnosticos y tratamientos (01_catalogos.sql).
COSTO_DIAGNOSTICO = {
    1: 6000, 2: 7000, 3: 5000, 4: 4500, 5: 5500, 6: 6500, 7: 8000,
    8: 12000, 9: 9500, 10: 4000, 11: 3500, 12: 9000, 13: 11000,
    14: 7500, 15: 15000, 16: 12000, 17: 9000, 18: 15000, 19: 14000,
    20: 8500, 21: 9500, 22: 6000,
}
COSTO_TRATAMIENTO = {
    1: 18000, 2: 32000, 3: 26000, 4: 24000, 5: 12000, 6: 20000,
    7: 38000, 8: 45000, 9: 78000, 10: 9000, 11: 21000, 12: 42000,
}

# Polizas de 03_polizas.sql:
# (ID_POLIZA, CI_PAC, ID_ASEGURADORA, TIPO_POLIZA, APROBADA,
#  HOSPITALIZACION, CIRUGIA, EXAMENES, COBERTURA, F_DESDE, F_HASTA)
POLIZAS_DETALLE = [
    (1, 20364201, 1, "PRINCIPAL", True, False, True, True, 10000, date(2025, 1, 1), date(2026, 12, 31)),
    (2, 20364202, 2, "PRINCIPAL", True, True, False, False, 20000, date(2025, 1, 1), date(2026, 12, 31)),
    (3, 20364203, 3, "PRINCIPAL", True, True, True, True, 30000, date(2024, 7, 1), date(2026, 12, 31)),
    (4, 20364204, 4, "PRINCIPAL", False, False, True, False, 50000, date(2025, 3, 1), date(2026, 12, 31)),
    (5, 20364205, 5, "PRINCIPAL", True, True, True, False, 60000, date(2025, 1, 1), None),
    (6, 20364206, 6, "PRINCIPAL", True, False, True, True, 100000, date(2025, 1, 1), date(2026, 12, 31)),
    (7, 20364207, 7, "PRINCIPAL", False, False, False, True, 10000, date(2024, 10, 1), date(2026, 12, 31)),
    (8, 20364208, 1, "PRINCIPAL", True, True, False, True, 20000, date(2025, 1, 1), date(2026, 12, 31)),
    (9, 20364209, 2, "PRINCIPAL", False, True, False, False, 30000, date(2025, 1, 1), date(2027, 6, 30)),
    (10, 20364210, 3, "PRINCIPAL", True, True, True, False, 50000, date(2025, 5, 1), date(2026, 12, 31)),
    (11, 20364211, 4, "PRINCIPAL", False, True, False, True, 60000, date(2025, 1, 1), date(2026, 12, 31)),
    (12, 20364212, 5, "PRINCIPAL", True, True, True, True, 100000, date(2024, 1, 1), None),
    (13, 20364213, 6, "PRINCIPAL", True, False, True, True, 10000, date(2025, 1, 1), date(2026, 12, 31)),
    (14, 20364214, 7, "PRINCIPAL", True, True, True, True, 20000, date(2025, 2, 1), date(2026, 12, 31)),
    (15, 20364215, 1, "PRINCIPAL", False, False, True, False, 30000, date(2025, 1, 1), date(2026, 12, 31)),
    (16, 20364216, 2, "PRINCIPAL", True, True, False, True, 50000, date(2024, 9, 1), date(2026, 12, 31)),
    (17, 20364217, 3, "PRINCIPAL", False, True, True, True, 60000, date(2025, 1, 1), date(2027, 1, 1)),
    (18, 20364218, 4, "PRINCIPAL", True, False, True, True, 100000, date(2025, 6, 1), date(2026, 12, 31)),
    (19, 20364219, 5, "PRINCIPAL", False, True, True, True, 10000, date(2025, 1, 1), date(2026, 12, 31)),
    (20, 20364220, 6, "PRINCIPAL", True, False, True, False, 20000, date(2024, 11, 1), date(2026, 12, 31)),
    (21, 20364221, 7, "PRINCIPAL", True, False, False, True, 30000, date(2025, 1, 1), None),
    (22, 20364222, 1, "PRINCIPAL", True, True, True, True, 50000, date(2025, 3, 1), date(2026, 12, 31)),
    (23, 20364223, 2, "PRINCIPAL", False, True, True, True, 60000, date(2025, 1, 1), date(2026, 12, 31)),
    (24, 20364224, 3, "PRINCIPAL", True, True, True, True, 100000, date(2024, 5, 1), date(2027, 12, 31)),
    (25, 20364225, 4, "PRINCIPAL", False, True, True, False, 10000, date(2025, 1, 1), date(2026, 12, 31)),
    (26, 20364226, 5, "PRINCIPAL", True, True, False, True, 20000, date(2025, 7, 1), date(2026, 12, 31)),
    (27, 20364201, 2, "SECUNDARIA", True, True, False, False, 40000, date(2025, 1, 1), date(2026, 12, 31)),
    (28, 20364202, 3, "SECUNDARIA", True, False, True, True, 50000, date(2025, 1, 1), date(2026, 12, 31)),
    (29, 20364204, 6, "SECUNDARIA", True, True, False, True, 30000, date(2025, 1, 1), date(2026, 12, 31)),
    (30, 20364207, 5, "SECUNDARIA", True, True, True, False, 20000, date(2025, 1, 1), date(2026, 12, 31)),
    (31, 20364213, 4, "SECUNDARIA", True, True, False, False, 40000, date(2025, 1, 1), date(2026, 12, 31)),
    (32, 20364217, 1, "SECUNDARIA", True, False, False, False, 30000, date(2025, 1, 1), date(2026, 12, 31)),
    (33, 20364220, 2, "SECUNDARIA", True, True, False, True, 50000, date(2025, 1, 1), date(2026, 12, 31)),
    (34, 20364226, 1, "SECUNDARIA", True, False, True, False, 40000, date(2025, 1, 1), date(2026, 12, 31)),
    (35, 20364228, 1, "PRINCIPAL", True, True, False, True, 30000, date(2025, 6, 1), date(2026, 12, 31)),
    (36, 20364229, 2, "PRINCIPAL", True, True, True, True, 60000, date(2025, 1, 1), date(2026, 12, 31)),
    (37, 20364230, 3, "PRINCIPAL", True, True, False, True, 40000, date(2025, 1, 1), date(2026, 12, 31)),
    (38, 20364232, 4, "PRINCIPAL", True, False, True, True, 50000, date(2025, 1, 1), date(2026, 12, 31)),
    (39, 20364233, 5, "PRINCIPAL", True, True, True, True, 80000, date(2025, 1, 1), date(2026, 12, 31)),
    (40, 20364235, 6, "PRINCIPAL", False, True, True, False, 20000, date(2025, 1, 1), date(2026, 12, 31)),
    (41, 20364236, 7, "PRINCIPAL", True, True, False, True, 70000, date(2025, 1, 1), date(2026, 12, 31)),
    (42, 20364237, 1, "PRINCIPAL", True, True, True, True, 100000, date(2025, 1, 1), date(2026, 12, 31)),
]

# Tipo de servicio facturado -> categoria de poliza y catalogo TIPO_SERVICIO.
CATEGORIA_SERVICIO = {
    "realiza": ("EXAMENES", 1),
    "prescribe": ("HOSPITALIZACION", 2),
    "practica": ("CIRUGIA", 3),
}
BANDERA_CATEGORIA = {
    "EXAMENES": "examenes",
    "HOSPITALIZACION": "hospitalizacion",
    "CIRUGIA": "cirugia",
}

DIAS_VENCIMIENTO = 30
INICIO_COBRO_RECIENTE = date(2026, 8, 1)
ESTADO_PAGADA = 1
ESTADO_PENDIENTE = 2
ESTADO_VENCIDA = 3

# ---------------------------------------------------------------------------
# Fase 7 - Efectos secundarios
# ---------------------------------------------------------------------------

# Efecto tipico asociado a cada tratamiento prescrito.
EFECTOS_POR_TRATAMIENTO = {
    1: "MAREO LEVE AL INCORPORARSE",
    2: "NAUSEAS Y DIARREA",
    3: "HIPOGLUCEMIA TRANSITORIA",
    4: "TOS SECA Y TEMBLOR",
    5: "IRRITACION LOCAL EN LA PIEL",
    6: "DOLOR ABDOMINAL",
    7: "SOMNOLENCIA DIURNA",
    8: "DOLOR MUSCULAR",
    9: "NAUSEAS Y CAIDA DEL CABELLO",
    10: "SOMNOLENCIA E IRRITABILIDAD",
    11: "CEFALEA LEVE",
    12: "MAREO Y SOMNOLENCIA",
}
GRAVEDADES = ("LEVE", "MODERADO", "GRAVE")
EFECTOS_POR_AREA = 2


def cantidad_ingresos(ci: int) -> int:
    if ci in CON_TRES:
        return 3
    if ci in CON_DOS:
        return 2
    return 1


def poliza_hospitalizacion(ci: int):
    """Devuelve (id_poliza, dias_cobertura) de la póliza efectiva o None."""
    datos = POLIZAS.get(ci)
    if datos is None:
        return None
    pid, aprobada, hosp, dias, sid, saprobada, shosp, sdias = datos
    if aprobada and hosp:
        return pid, int(dias)
    if sid is not None and saprobada and shosp:
        return sid, int(sdias)
    return None


def construir_ingresos():
    tokens = []
    for ci in sorted(PERFILES):
        tokens.extend([ci] * cantidad_ingresos(ci))

    contador_mes = Counter()
    ingresos = []

    for indice, ci in enumerate(tokens):
        mes_indice = indice % 12
        slot = contador_mes[mes_indice]
        contador_mes[mes_indice] += 1

        area, diagnostico = PERFILES[ci]
        anio, mes = MESES[mes_indice]

        if mes_indice == 11:
            # Octubre de 2026: 1 alta temprana y 4 estancias activas al corte.
            if slot == 0:
                dia, dias, activa = 5, 4, False
            else:
                dia = {1: 22, 2: 24, 3: 26, 4: 28}[slot]
                dias = (PERIODO_FIN - date(anio, mes, dia)).days + 1
                activa = True
        else:
            dia = 1 + slot * 2
            # Estancia determinista de 2 a 10 dias, siempre dentro del mes.
            dias = 2 + ((ci + mes_indice + slot) % 9)
            activa = False

        inicio = date(anio, mes, dia)
        fin = None if activa else inicio + timedelta(days=dias)

        poliza = poliza_hospitalizacion(ci)
        id_poliza = poliza[0] if poliza else None
        dias_cubiertos = min(dias, poliza[1]) if poliza else 0

        ingresos.append({
            "ci": ci,
            "area": area,
            "diagnostico": diagnostico,
            "inicio": inicio,
            "fin": fin,
            "dias": dias,
            "activa": activa,
            "id_poliza": id_poliza,
            "dias_cubiertos": dias_cubiertos,
            "costo_diario": COSTO_DIARIO_BASE[area] + ((ci + dias) % 3) * 100,
        })

    # Numeracion cronologica 5001-5060.
    ingresos.sort(key=lambda x: (x["inicio"], x["ci"]))
    for posicion, ingreso in enumerate(ingresos, start=5001):
        ingreso["numero"] = posicion

    # Camas: entre las libres del area, la que tenga menos usos.
    intervalos_cama = defaultdict(list)
    usos_cama = Counter()
    for ingreso in ingresos:
        fin_exclusivo = ingreso["inicio"] + timedelta(days=ingreso["dias"])
        libres = [
            cama for cama in CAMAS[ingreso["area"]]
            if all(
                not (ingreso["inicio"] < fin and inicio < fin_exclusivo)
                for inicio, fin in intervalos_cama[cama]
            )
        ]
        if not libres:
            raise RuntimeError(
                f"Sin cama libre para el ingreso {ingreso['numero']} "
                f"en el area {ingreso['area']}"
            )
        cama = min(libres, key=lambda c: (usos_cama[c], c))
        intervalos_cama[cama].append((ingreso["inicio"], fin_exclusivo))
        usos_cama[cama] += 1
        ingreso["cama"] = cama

    # Medico previsto para la Fase 5 (no se guarda en INGRESO).
    contador_area = Counter()
    for ingreso in ingresos:
        medicos = MEDICOS[ingreso["area"]]
        ingreso["medico"] = medicos[contador_area[ingreso["area"]] % len(medicos)]
        contador_area[ingreso["area"]] += 1

    return ingresos


def sexo_paciente(ci: int) -> int:
    """Sexo segun el maestro: las cedulas impares son masculinas."""
    return 1 if ci % 2 == 1 else 2


def ultimo_dia_estancia(ingreso):
    """Ultimo dia con servicios permitidos dentro de la internacion."""
    if ingreso["fin"] is None:
        return PERIODO_FIN
    return ingreso["fin"] - timedelta(days=1)


def diagnosticos_servicio(ingreso):
    area = ingreso["area"]
    principal = ingreso["diagnostico"]
    sexo = sexo_paciente(ingreso["ci"])
    candidatos = [
        diagnostico
        for diagnostico in DIAGNOSTICOS_POR_AREA[area]
        if diagnostico != principal
    ]
    if sexo == 1:
        candidatos = [
            diagnostico
            for diagnostico in candidatos
            if diagnostico not in DIAGNOSTICOS_SOLO_FEMENINO
        ]
    else:
        candidatos = [
            diagnostico
            for diagnostico in candidatos
            if diagnostico not in DIAGNOSTICOS_SOLO_MASCULINO
        ]
    if not candidatos:
        raise RuntimeError(
            f"Sin segundo diagnostico para el ingreso {ingreso['numero']} "
            f"(area {area}, diagnostico {principal}, sexo {sexo})"
        )
    return principal, candidatos[0]


def tratamientos_servicio(ingreso):
    area = ingreso["area"]
    principal = ingreso["diagnostico"]
    primero = TRATAMIENTO_PRINCIPAL[principal]
    if area == 4:
        segundo = 11 if primero == 3 else 3
    elif area == 7:
        segundo = 10 if primero == 4 else 4
    else:
        segundo = TRATAMIENTO_SECUNDARIO[area]
    return primero, segundo


def intervencion_servicio(ingreso):
    area = ingreso["area"]
    if area == 10:
        return INTERVENCION_POR_DIAGNOSTICO[ingreso["diagnostico"]]
    return INTERVENCION_POR_AREA[area]


def construir_servicios(ingresos):
    realiza = []
    prescribe = []
    practica = []

    for ingreso in ingresos:
        max_fecha = ultimo_dia_estancia(ingreso)
        inicio = ingreso["inicio"]
        ci = ingreso["ci"]
        numero = ingreso["numero"]
        area = ingreso["area"]
        medico = ingreso["medico"]

        if max_fecha <= inicio:
            raise RuntimeError(
                f"El ingreso {numero} necesita al menos dos dias para los servicios"
            )

        # Dos diagnosticos: el principal el dia del ingreso y el segundo al
        # dia siguiente (o el ultimo dia disponible en estancias de 2 dias).
        primer_diagnostico, segundo_diagnostico = diagnosticos_servicio(ingreso)
        for diagnostico, fecha in (
            (primer_diagnostico, inicio),
            (segundo_diagnostico, min(inicio + timedelta(days=1), max_fecha)),
        ):
            realiza.append({
                "ci_medico": medico,
                "ci_pac": ci,
                "id_diagn": diagnostico,
                "numero": numero,
                "area": area,
                "fecha": fecha,
            })

        # Dos prescripciones, con duracion acotada al resto de la estancia.
        primer_tratamiento, segundo_tratamiento = tratamientos_servicio(ingreso)
        for orden, (tratamiento, fecha) in enumerate(
            (
                (primer_tratamiento, inicio),
                (segundo_tratamiento, min(inicio + timedelta(days=1), max_fecha)),
            ),
            start=1,
        ):
            dias_disponibles = (max_fecha - fecha).days + 1
            duracion = min(dias_disponibles, 3 + ((ci + numero + orden) % 4))
            fin = fecha + timedelta(days=duracion - 1)
            prescribe.append({
                "ci_medico": medico,
                "ci_pac": ci,
                "id_tratamiento": tratamiento,
                "numero": numero,
                "area": area,
                "f_elaboracion": fecha,
                "f_inicio": fecha,
                "f_fin": fin,
                "cant_dias": duracion,
                "dosis": DOSIS_TRATAMIENTO[tratamiento],
            })

        # Una intervencion por ingreso, al dia siguiente del ingreso.
        intervencion = intervencion_servicio(ingreso)
        fecha_intervencion = min(inicio + timedelta(days=1), max_fecha)
        costo = COSTO_INTERVENCION[intervencion] + ((ci + numero) % 3) * 500
        practica.append({
            "ci_medico": medico,
            "ci_pac": ci,
            "id_intervencion": intervencion,
            "ci_personal": PERSONAL_POR_AREA[area],
            "numero": numero,
            "area": area,
            "fecha": fecha_intervencion,
            "riesgo": RIESGO_INTERVENCION[intervencion],
            "duracion": DURACION_INTERVENCION[intervencion],
            "gasto": round(costo * 0.15, 2),
            "costo": float(costo),
            "honorario": round(costo * 0.20, 2),
        })

    realiza.sort(key=lambda fila: (fila["numero"], fila["fecha"], fila["id_diagn"]))
    prescribe.sort(
        key=lambda fila: (fila["numero"], fila["f_elaboracion"], fila["id_tratamiento"])
    )
    practica.sort(
        key=lambda fila: (fila["numero"], fila["fecha"], fila["id_intervencion"])
    )
    return {"realiza": realiza, "prescribe": prescribe, "practica": practica}


def sql_fecha(valor):
    return "NULL" if valor is None else f"'{valor.isoformat()}'"


def sql_id(valor):
    return "NULL" if valor is None else str(valor)


def renderizar(ingresos):
    total = len(ingresos)
    activas = sum(1 for ingreso in ingresos if ingreso["activa"])
    lineas = []
    lineas.append("-- ============================================================================")
    lineas.append("-- Fase 4 - Ingresos y ocupaciones (PostgreSQL)")
    lineas.append("-- Esquema destino: \"OLTP\"")
    lineas.append("--")
    lineas.append("-- Generado por oltp/datos_prueba/generar_datos.py.")
    lineas.append("-- No editar a mano: los cambios deben hacerse en el generador.")
    lineas.append("--")
    lineas.append(f"-- Contenido: {total} ingresos, {total} ocupaciones y {activas} estancias ACTIVA.")
    lineas.append("-- Los ingresos se distribuyen en los 12 meses del periodo.")
    lineas.append("-- Una cama no se repite en fechas superpuestas y un paciente no tiene")
    lineas.append("-- dos ingresos simultaneos.")
    lineas.append("--")
    lineas.append("-- Requiere: 01_catalogos.sql, 02_maestros.sql y 03_polizas.sql.")
    lineas.append("-- ============================================================================")
    lineas.append("")
    lineas.append('SET search_path TO "OLTP";')
    lineas.append("")
    lineas.append('TRUNCATE TABLE "OLTP".INGRESO CASCADE;')
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Ingresos")
    lineas.append("-- ============================================================================")
    lineas.append("INSERT INTO INGRESO (NUMBER_INGRESO, CI_PAC, F_INGRESO, F_ALTA, ID_AREA) VALUES")
    for posicion, ingreso in enumerate(ingresos):
        sufijo = "," if posicion < total - 1 else ";"
        comentario = (
            f"-- {ingreso['ci']} area {ingreso['area']} "
            f"diag {ingreso['diagnostico']} medico {ingreso['medico']}"
        )
        lineas.append(
            f"\t({ingreso['numero']}, {ingreso['ci']}, {sql_fecha(ingreso['inicio'])}, "
            f"{sql_fecha(ingreso['fin'])}, {ingreso['area']}){sufijo}  {comentario}"
        )
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Ocupaciones")
    lineas.append("-- ============================================================================")
    lineas.append(
        "INSERT INTO OCUPA (CI_PAC, ID_NUMBER_CAMA, F_INICIO, CANTIDAD_DIAS, "
        "DIAS_CUBIERTOS_SEGURO, COSTO_DIARIO, ESTATUS, NUMBER_INGRESO, ID_POLIZA) VALUES"
    )
    for posicion, ingreso in enumerate(ingresos):
        sufijo = "," if posicion < total - 1 else ";"
        estatus = "ACTIVA" if ingreso["activa"] else "ALTA"
        comentario = f"-- ingreso {ingreso['numero']} cama {ingreso['cama']}"
        lineas.append(
            f"\t({ingreso['ci']}, {ingreso['cama']}, {sql_fecha(ingreso['inicio'])}, "
            f"{ingreso['dias']}, {ingreso['dias_cubiertos']}, "
            f"{ingreso['costo_diario']:.2f}, '{estatus}', {ingreso['numero']}, "
            f"{sql_id(ingreso['id_poliza'])}){sufijo}  {comentario}"
        )
    lineas.append("")
    lineas.extend(bloque_validacion())
    return "\n".join(lineas) + "\n"


def bloque_validacion():
    return [
        "-- ============================================================================",
        "-- Autovalidacion de la fase",
        "-- ============================================================================",
        "DO $$",
        "DECLARE",
        "\tv_filas INTEGER;",
        "BEGIN",
        "\tSELECT count(*) INTO v_filas FROM INGRESO;",
        "\tIF v_filas < 40 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 40 ingresos y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM INGRESO i",
        "\tLEFT JOIN OCUPA o ON o.NUMBER_INGRESO = i.NUMBER_INGRESO",
        "\tWHERE o.NUMBER_INGRESO IS NULL;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay ingresos sin ocupacion: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM INGRESO",
        "\tWHERE F_INGRESO < DATE '2025-11-01' OR F_INGRESO > DATE '2026-10-31';",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay ingresos fuera del periodo: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM INGRESO",
        "\tWHERE F_ALTA IS NOT NULL AND (F_ALTA < F_INGRESO OR F_ALTA > DATE '2026-10-31');",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay altas fuera del periodo: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA o",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO",
        "\tWHERE o.ESTATUS = 'ACTIVA' AND i.F_ALTA IS NOT NULL;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay estancias ACTIVA con fecha de alta: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA o",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO",
        "\tWHERE o.ESTATUS = 'ALTA' AND i.F_ALTA IS NULL;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay estancias ALTA sin fecha de alta: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA",
        "\tWHERE CANTIDAD_DIAS <= 0",
        "\t   OR DIAS_CUBIERTOS_SEGURO < 0",
        "\t   OR DIAS_CUBIERTOS_SEGURO > CANTIDAD_DIAS;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay dias de ocupacion o cobertura invalidos: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA",
        "\tWHERE COSTO_DIARIO < 1200 OR COSTO_DIARIO > 4000;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay costos diarios fuera de rango: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA o",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO",
        "\tJOIN CAMA c ON c.ID_NUMBER_CAMA = o.ID_NUMBER_CAMA",
        "\tWHERE o.CI_PAC <> i.CI_PAC OR c.ID_AREA_HOSPITAL <> i.ID_AREA;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay ocupaciones con paciente o area incoherente: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA o",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO",
        "\tWHERE o.F_INICIO <> i.F_INGRESO;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay ocupaciones que no inician el dia del ingreso: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM OCUPA a JOIN OCUPA b",
        "\t  ON a.ID_NUMBER_CAMA = b.ID_NUMBER_CAMA",
        "\t AND a.NUMBER_INGRESO < b.NUMBER_INGRESO",
        "\t AND a.F_INICIO < b.F_INICIO + b.CANTIDAD_DIAS::integer",
        "\t AND b.F_INICIO < a.F_INICIO + a.CANTIDAD_DIAS::integer;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay solapamientos de cama: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM OCUPA a JOIN OCUPA b",
        "\t  ON a.CI_PAC = b.CI_PAC",
        "\t AND a.NUMBER_INGRESO < b.NUMBER_INGRESO",
        "\t AND a.F_INICIO < b.F_INICIO + b.CANTIDAD_DIAS::integer",
        "\t AND b.F_INICIO < a.F_INICIO + a.CANTIDAD_DIAS::integer;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay pacientes en dos camas a la vez: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA",
        "\tWHERE ESTATUS = 'ACTIVA'",
        "\t  AND F_INICIO + CANTIDAD_DIAS::integer <= DATE '2026-10-31';",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay estancias ACTIVA terminadas antes del corte: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA o",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = o.NUMBER_INGRESO",
        "\tWHERE o.ESTATUS = 'ALTA'",
        "\t  AND i.F_ALTA <> o.F_INICIO + o.CANTIDAD_DIAS::integer;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay altas que no coinciden con la ocupacion: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM OCUPA o",
        "\tLEFT JOIN POLIZA p ON p.ID_POLIZA = o.ID_POLIZA AND p.CI_PAC = o.CI_PAC",
        "\tWHERE o.ID_POLIZA IS NOT NULL AND p.ID_POLIZA IS NULL;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay polizas de ocupacion que no pertenecen al paciente: %', v_filas;",
        "\tEND IF;",
        "END;",
        "$$;",
    ]


def valores_mapa_diagnosticos():
    filas = []
    for area, diagnosticos in sorted(DIAGNOSTICOS_POR_AREA.items()):
        for diagnostico in diagnosticos:
            if diagnostico in DIAGNOSTICOS_SOLO_FEMENINO:
                sexo = 2
            elif diagnostico in DIAGNOSTICOS_SOLO_MASCULINO:
                sexo = 1
            else:
                sexo = None
            filas.append(f"({area}, {diagnostico}, {sql_id(sexo)})")
    return ",\n\t\t\t".join(filas)


def valores_mapa_tratamientos():
    pares = set()
    for area, diagnosticos in DIAGNOSTICOS_POR_AREA.items():
        for diagnostico in diagnosticos:
            primero = TRATAMIENTO_PRINCIPAL[diagnostico]
            pares.add((area, primero))
            if area == 4:
                pares.add((area, 11 if primero == 3 else 3))
            elif area == 7:
                pares.add((area, 10 if primero == 4 else 4))
            else:
                pares.add((area, TRATAMIENTO_SECUNDARIO[area]))
    return ",\n\t\t\t".join(
        f"({area}, {tratamiento})" for area, tratamiento in sorted(pares)
    )


def valores_mapa_intervenciones():
    pares = {
        (area, intervencion)
        for area, intervencion in INTERVENCION_POR_AREA.items()
    }
    for intervencion in INTERVENCION_POR_DIAGNOSTICO.values():
        pares.add((10, intervencion))
    return ",\n\t\t\t".join(
        f"({area}, {intervencion})" for area, intervencion in sorted(pares)
    )


def renderizar_servicios(servicios):
    total_realiza = len(servicios["realiza"])
    total_prescribe = len(servicios["prescribe"])
    total_practica = len(servicios["practica"])

    lineas = []
    lineas.append("-- ============================================================================")
    lineas.append("-- Fase 5 - Servicios clinicos (PostgreSQL)")
    lineas.append("-- Esquema destino: \"OLTP\"")
    lineas.append("--")
    lineas.append("-- Generado por oltp/datos_prueba/generar_datos.py.")
    lineas.append("-- No editar a mano: los cambios deben hacerse en el generador.")
    lineas.append("--")
    lineas.append(
        f"-- Contenido: {total_realiza} diagnosticos, {total_prescribe} prescripciones "
        f"y {total_practica} intervenciones."
    )
    lineas.append("-- Cada ingreso tiene 2 diagnosticos, 2 prescripciones y 1 intervencion.")
    lineas.append("-- Las fechas quedan dentro de la internacion y los servicios usan")
    lineas.append("-- medicos y personal del area del ingreso.")
    lineas.append("--")
    lineas.append("-- Requiere: 01_catalogos.sql, 02_maestros.sql, 03_polizas.sql")
    lineas.append("--           y 04_ingresos_ocupaciones.sql.")
    lineas.append("-- ============================================================================")
    lineas.append("")
    lineas.append('SET search_path TO "OLTP";')
    lineas.append("")
    lineas.append(
        'TRUNCATE TABLE "OLTP".FACTURA, "OLTP".REALIZA, "OLTP".PRESCRIBE, '
        '"OLTP".PRACTICA CASCADE;'
    )
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Diagnosticos realizados")
    lineas.append("-- ============================================================================")
    lineas.append(
        "INSERT INTO REALIZA (CI_MEDICO, CI_PAC, ID_DIAGN, NUMBER_INGRESO, "
        "F_ELABORACION) VALUES"
    )
    for posicion, fila in enumerate(servicios["realiza"]):
        sufijo = "," if posicion < total_realiza - 1 else ";"
        comentario = f"-- ingreso {fila['numero']} area {fila['area']}"
        lineas.append(
            f"\t({fila['ci_medico']}, {fila['ci_pac']}, {fila['id_diagn']}, "
            f"{fila['numero']}, {sql_fecha(fila['fecha'])}){sufijo}  {comentario}"
        )
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Prescripciones")
    lineas.append("-- ============================================================================")
    lineas.append(
        "INSERT INTO PRESCRIBE (CI_MEDICO, CI_PAC, ID_TRATAMIENTO, NUMBER_INGRESO, "
        "F_ELABORACION, F_INICIO, F_FIN, CANT_DIAS, DOSIS_DIARIA) VALUES"
    )
    for posicion, fila in enumerate(servicios["prescribe"]):
        sufijo = "," if posicion < total_prescribe - 1 else ";"
        comentario = (
            f"-- ingreso {fila['numero']} area {fila['area']} "
            f"tratamiento {fila['id_tratamiento']}"
        )
        lineas.append(
            f"\t({fila['ci_medico']}, {fila['ci_pac']}, {fila['id_tratamiento']}, "
            f"{fila['numero']}, {sql_fecha(fila['f_elaboracion'])}, "
            f"{sql_fecha(fila['f_inicio'])}, {sql_fecha(fila['f_fin'])}, "
            f"{fila['cant_dias']}, '{fila['dosis']}'){sufijo}  {comentario}"
        )
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Intervenciones")
    lineas.append("-- ============================================================================")
    lineas.append(
        "INSERT INTO PRACTICA (CI_MEDICO, CI_PAC, ID_INTERVENCION, "
        "CI_PERSONAL_SANITARIO, F, RIESGO, DURACION, GASTO_EQUIPOS, COSTO, "
        "HONORARIO_EQUIPO, NUMBER_INGRESO) VALUES"
    )
    for posicion, fila in enumerate(servicios["practica"]):
        sufijo = "," if posicion < total_practica - 1 else ";"
        comentario = (
            f"-- ingreso {fila['numero']} area {fila['area']} "
            f"intervencion {fila['id_intervencion']}"
        )
        lineas.append(
            f"\t({fila['ci_medico']}, {fila['ci_pac']}, {fila['id_intervencion']}, "
            f"{fila['ci_personal']}, {sql_fecha(fila['fecha'])}, "
            f"'{fila['riesgo']}', {fila['duracion']}, {fila['gasto']:.2f}, "
            f"{fila['costo']:.2f}, {fila['honorario']:.2f}, "
            f"{fila['numero']}){sufijo}  {comentario}"
        )
    lineas.append("")
    lineas.extend(bloque_validacion_servicios())
    return "\n".join(lineas) + "\n"


def bloque_validacion_servicios():
    mapa_diagnosticos = valores_mapa_diagnosticos()
    mapa_tratamientos = valores_mapa_tratamientos()
    mapa_intervenciones = valores_mapa_intervenciones()
    return [
        "-- ============================================================================",
        "-- Autovalidacion de la fase",
        "-- ============================================================================",
        "DO $$",
        "DECLARE",
        "\tv_filas INTEGER;",
        "BEGIN",
        "\tSELECT count(*) INTO v_filas FROM REALIZA;",
        "\tIF v_filas < 100 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 100 diagnosticos y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM PRESCRIBE;",
        "\tIF v_filas < 100 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 100 prescripciones y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM PRACTICA;",
        "\tIF v_filas < 50 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 50 intervenciones y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM INGRESO i",
        "\tWHERE (SELECT count(*) FROM REALIZA r",
        "\t       WHERE r.NUMBER_INGRESO = i.NUMBER_INGRESO) <> 2;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay ingresos sin exactamente 2 diagnosticos: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM INGRESO i",
        "\tWHERE (SELECT count(*) FROM PRESCRIBE p",
        "\t       WHERE p.NUMBER_INGRESO = i.NUMBER_INGRESO) <> 2;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay ingresos sin exactamente 2 prescripciones: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM INGRESO i",
        "\tWHERE (SELECT count(*) FROM PRACTICA p",
        "\t       WHERE p.NUMBER_INGRESO = i.NUMBER_INGRESO) <> 1;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay ingresos sin exactamente 1 intervencion: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM REALIZA r JOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO",
        "\tWHERE r.F_ELABORACION < i.F_INGRESO",
        "\t   OR r.F_ELABORACION > COALESCE(i.F_ALTA - 1, DATE '2026-10-31');",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay diagnosticos fuera de la internacion: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRESCRIBE p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE p.F_ELABORACION IS NULL OR p.F_INICIO IS NULL OR p.F_FIN IS NULL",
        "\t   OR p.CANT_DIAS IS NULL OR p.DOSIS_DIARIA IS NULL",
        "\t   OR p.F_ELABORACION < i.F_INGRESO",
        "\t   OR p.F_ELABORACION > COALESCE(i.F_ALTA - 1, DATE '2026-10-31')",
        "\t   OR p.F_INICIO < i.F_INGRESO",
        "\t   OR p.F_FIN > COALESCE(i.F_ALTA - 1, DATE '2026-10-31')",
        "\t   OR p.F_FIN < p.F_INICIO",
        "\t   OR p.CANT_DIAS <> (p.F_FIN - p.F_INICIO) + 1;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay prescripciones incompletas o fuera de la internacion: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRACTICA p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE p.F IS NULL",
        "\t   OR p.F < i.F_INGRESO",
        "\t   OR p.F > COALESCE(i.F_ALTA - 1, DATE '2026-10-31')",
        "\t   OR p.COSTO IS NULL OR p.COSTO <= 0",
        "\t   OR p.GASTO_EQUIPOS IS NULL OR p.GASTO_EQUIPOS < 0",
        "\t   OR p.HONORARIO_EQUIPO IS NULL OR p.HONORARIO_EQUIPO < 0",
        "\t   OR p.GASTO_EQUIPOS + p.HONORARIO_EQUIPO > p.COSTO;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay intervenciones con fecha o montos invalidos: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM REALIZA r JOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM TRABAJA t",
        "\t\tWHERE t.ID_MEDICO = r.CI_MEDICO",
        "\t\t  AND t.ID_AREA = i.ID_AREA",
        "\t\t  AND t.F <= i.F_INGRESO",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay diagnosticos con un medico ajeno al area: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRESCRIBE p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM TRABAJA t",
        "\t\tWHERE t.ID_MEDICO = p.CI_MEDICO",
        "\t\t  AND t.ID_AREA = i.ID_AREA",
        "\t\t  AND t.F <= i.F_INGRESO",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay prescripciones con un medico ajeno al area: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRACTICA p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM TRABAJA t",
        "\t\tWHERE t.ID_MEDICO = p.CI_MEDICO",
        "\t\t  AND t.ID_AREA = i.ID_AREA",
        "\t\t  AND t.F <= i.F_INGRESO",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay intervenciones con un medico ajeno al area: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM REALIZA r",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO",
        "\tJOIN PAC pac ON pac.CI_PAC = r.CI_PAC",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM (VALUES",
        f"\t\t\t{mapa_diagnosticos}",
        "\t\t) AS m(area, diagnostico, sexo)",
        "\t\tWHERE m.area = i.ID_AREA",
        "\t\t  AND m.diagnostico = r.ID_DIAGN",
        "\t\t  AND (m.sexo IS NULL OR m.sexo = pac.ID_SX)",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay diagnosticos incompatibles con el area o el sexo: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRESCRIBE p",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM (VALUES",
        f"\t\t\t{mapa_tratamientos}",
        "\t\t) AS m(area, tratamiento)",
        "\t\tWHERE m.area = i.ID_AREA",
        "\t\t  AND m.tratamiento = p.ID_TRATAMIENTO",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay tratamientos incompatibles con el area: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRACTICA p",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM (VALUES",
        f"\t\t\t{mapa_intervenciones}",
        "\t\t) AS m(area, intervencion)",
        "\t\tWHERE m.area = i.ID_AREA",
        "\t\t  AND m.intervencion = p.ID_INTERVENCION",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay intervenciones incompatibles con el area: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRACTICA p",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tJOIN PERSONAL_SANITARIO ps ON ps.CI_PERSONAL = p.CI_PERSONAL_SANITARIO",
        "\tWHERE ps.ID_AREA <> i.ID_AREA;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay intervenciones con personal de otra area: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM INGRESO i JOIN PAC p ON p.CI_PAC = i.CI_PAC",
        "\tWHERE i.ID_AREA = 7",
        "\t  AND p.F_NACIMIENTO <= (i.F_INGRESO - INTERVAL '18 years')::date;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay pacientes adultos en el area pediatrica: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM REALIZA r JOIN PAC p ON p.CI_PAC = r.CI_PAC",
        "\tWHERE (r.ID_DIAGN IN (15, 17, 22) AND p.ID_SX <> 2)",
        "\t   OR (r.ID_DIAGN = 18 AND p.ID_SX <> 1);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay diagnosticos con un sexo incompatible: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM (",
        "\t\tSELECT CI_MEDICO, CI_PAC, ID_DIAGN, NUMBER_INGRESO, F_ELABORACION",
        "\t\tFROM REALIZA",
        "\t\tGROUP BY 1, 2, 3, 4, 5",
        "\t\tHAVING count(*) > 1",
        "\t) d;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay diagnosticos duplicados: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM (",
        "\t\tSELECT CI_MEDICO, CI_PAC, ID_TRATAMIENTO, NUMBER_INGRESO, F_ELABORACION",
        "\t\tFROM PRESCRIBE",
        "\t\tGROUP BY 1, 2, 3, 4, 5",
        "\t\tHAVING count(*) > 1",
        "\t) d;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay prescripciones duplicadas: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM (",
        "\t\tSELECT CI_MEDICO, CI_PAC, ID_INTERVENCION, CI_PERSONAL_SANITARIO, F",
        "\t\tFROM PRACTICA",
        "\t\tGROUP BY 1, 2, 3, 4, 5",
        "\t\tHAVING count(*) > 1",
        "\t) d;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay intervenciones duplicadas: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM REALIZA r JOIN INGRESO i ON i.NUMBER_INGRESO = r.NUMBER_INGRESO",
        "\tWHERE r.CI_PAC <> i.CI_PAC;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay diagnosticos con paciente incoherente: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRESCRIBE p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE p.CI_PAC <> i.CI_PAC;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay prescripciones con paciente incoherente: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM PRACTICA p JOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\tWHERE p.CI_PAC <> i.CI_PAC;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay intervenciones con paciente incoherente: %', v_filas;",
        "\tEND IF;",
        "END;",
        "$$;",
    ]


def resumen_servicios(servicios):
    print(f"Diagnosticos (REALIZA): {len(servicios['realiza'])}")
    print(f"Prescripciones (PRESCRIBE): {len(servicios['prescribe'])}")
    print(f"Intervenciones (PRACTICA): {len(servicios['practica'])}")
    print("Servicios por area:")
    for area in sorted(DIAGNOSTICOS_POR_AREA):
        realizados = sum(1 for fila in servicios["realiza"] if fila["area"] == area)
        prescritos = sum(1 for fila in servicios["prescribe"] if fila["area"] == area)
        practicados = sum(1 for fila in servicios["practica"] if fila["area"] == area)
        print(
            f"  area {area}: {realizados} diagnosticos, "
            f"{prescritos} prescripciones, {practicados} intervenciones"
        )


def polizas_por_paciente():
    """Agrupa las polizas de la Fase 3 por paciente."""
    agrupadas = defaultdict(list)
    for fila in POLIZAS_DETALLE:
        (
            id_poliza, ci, id_aseguradora, tipo, aprobada,
            hospitalizacion, cirugia, examenes, cobertura, desde, hasta,
        ) = fila
        agrupadas[ci].append({
            "id": id_poliza,
            "aseguradora": id_aseguradora,
            "tipo": tipo,
            "aprobada": aprobada,
            "hospitalizacion": hospitalizacion,
            "cirugia": cirugia,
            "examenes": examenes,
            "cobertura": float(cobertura),
            "desde": desde,
            "hasta": hasta,
        })
    return agrupadas


def poliza_vigente(polizas, ci, categoria, fecha):
    """Poliza efectiva para un servicio: principal y luego secundaria."""
    bandera = BANDERA_CATEGORIA[categoria]
    for tipo in ("PRINCIPAL", "SECUNDARIA"):
        for poliza in polizas.get(ci, []):
            if poliza["tipo"] != tipo or not poliza["aprobada"]:
                continue
            if not poliza[bandera]:
                continue
            if fecha < poliza["desde"]:
                continue
            if poliza["hasta"] is not None and fecha > poliza["hasta"]:
                continue
            return poliza
    return None


def construir_facturas(servicios):
    polizas = polizas_por_paciente()
    servicios_facturables = []

    for tipo in ("realiza", "prescribe", "practica"):
        categoria, id_tipo_servicio = CATEGORIA_SERVICIO[tipo]
        for fila in servicios[tipo]:
            if tipo == "realiza":
                fecha = fila["fecha"]
                monto = float(COSTO_DIAGNOSTICO[fila["id_diagn"]])
                referencia = fila["id_diagn"]
            elif tipo == "prescribe":
                fecha = fila["f_elaboracion"]
                monto = float(COSTO_TRATAMIENTO[fila["id_tratamiento"]])
                referencia = fila["id_tratamiento"]
            else:
                fecha = fila["fecha"]
                monto = float(fila["costo"])
                referencia = fila["id_intervencion"]

            servicios_facturables.append({
                "tipo": tipo,
                "categoria": categoria,
                "id_tipo_servicio": id_tipo_servicio,
                "ci": fila["ci_pac"],
                "numero": fila["numero"],
                "area": fila["area"],
                "fecha": fecha,
                "monto": monto,
                "referencia": referencia,
                "clave": fila,
            })

    servicios_facturables.sort(
        key=lambda fila: (
            fila["fecha"],
            fila["id_tipo_servicio"],
            fila["numero"],
            fila["ci"],
            fila["referencia"],
        )
    )

    facturas = []
    posicion_temprana = 0
    posicion_pagada = 0

    for indice, servicio in enumerate(servicios_facturables):
        poliza = poliza_vigente(
            polizas, servicio["ci"], servicio["categoria"], servicio["fecha"]
        )
        total = round(servicio["monto"], 2)
        if poliza is None:
            cubierto = 0.0
            tipo_cliente = "PACIENTE"
            id_poliza = None
            id_aseguradora = None
        else:
            cubierto = round(min(poliza["cobertura"], total), 2)
            tipo_cliente = "ASEGURADORA"
            id_poliza = poliza["id"]
            id_aseguradora = poliza["aseguradora"]
        paciente = round(total - cubierto, 2)

        f_pago = None
        monto_pagado = None
        if servicio["fecha"] >= INICIO_COBRO_RECIENTE:
            # Cobro reciente: queda pendiente al corte.
            estado = ESTADO_PENDIENTE
        else:
            if posicion_temprana % 5 == 0:
                # Emitida hace mas de 60 dias y sin pago: vencida.
                estado = ESTADO_VENCIDA
            else:
                estado = ESTADO_PAGADA
                f_pago = servicio["fecha"] + timedelta(
                    days=5 + (posicion_pagada * 7) % 86
                )
                # Defensa: un pago nunca supera el corte del periodo.
                if f_pago > PERIODO_FIN:
                    f_pago = PERIODO_FIN
                if posicion_pagada % 5 == 3:
                    # Algunos pagos son parciales; la mayoria son totales.
                    factor = 0.40 + 0.05 * (posicion_pagada % 11)
                    monto_pagado = min(round(total * factor, 2), total)
                else:
                    monto_pagado = total
                posicion_pagada += 1
            posicion_temprana += 1

        facturas.append({
            **servicio,
            "id_factura": 6001 + indice,
            "id_detalle": 9001 + indice,
            "id_poliza": id_poliza,
            "id_aseguradora": id_aseguradora,
            "tipo_cliente": tipo_cliente,
            "f_vencimiento": servicio["fecha"] + timedelta(days=DIAS_VENCIMIENTO),
            "monto_total": total,
            "monto_cubierto": cubierto,
            "monto_paciente": paciente,
            "estado": estado,
            "f_pago": f_pago,
            "monto_pagado": monto_pagado,
        })

    return facturas


def subconsulta_prescripcion(fila):
    """Subconsulta por clave natural de una prescripcion."""
    return (
        "(SELECT ID_PRESCRIPCION FROM PRESCRIBE"
        f" WHERE CI_MEDICO = {fila['ci_medico']}"
        f" AND CI_PAC = {fila['ci_pac']}"
        f" AND ID_TRATAMIENTO = {fila['id_tratamiento']}"
        f" AND NUMBER_INGRESO = {fila['numero']}"
        f" AND F_ELABORACION = {sql_fecha(fila['f_elaboracion'])})"
    )


def subconsulta_servicio(factura):
    """Subconsulta por clave natural para resolver el ID identity del servicio."""
    clave = factura["clave"]
    if factura["tipo"] == "realiza":
        return (
            "(SELECT ID_REALIZA FROM REALIZA"
            f" WHERE CI_MEDICO = {clave['ci_medico']}"
            f" AND CI_PAC = {clave['ci_pac']}"
            f" AND ID_DIAGN = {clave['id_diagn']}"
            f" AND NUMBER_INGRESO = {clave['numero']}"
            f" AND F_ELABORACION = {sql_fecha(clave['fecha'])})"
        )
    if factura["tipo"] == "prescribe":
        return subconsulta_prescripcion(clave)
    return (
        "(SELECT ID_PRACTICA FROM PRACTICA"
        f" WHERE CI_MEDICO = {clave['ci_medico']}"
        f" AND CI_PAC = {clave['ci_pac']}"
        f" AND ID_INTERVENCION = {clave['id_intervencion']}"
        f" AND CI_PERSONAL_SANITARIO = {clave['ci_personal']}"
        f" AND F = {sql_fecha(clave['fecha'])})"
    )


def renderizar_facturacion(facturas):
    total = len(facturas)
    pagadas = sum(1 for f in facturas if f["estado"] == ESTADO_PAGADA)
    pendientes = sum(1 for f in facturas if f["estado"] == ESTADO_PENDIENTE)
    vencidas = sum(1 for f in facturas if f["estado"] == ESTADO_VENCIDA)
    parciales = sum(
        1 for f in facturas
        if f["estado"] == ESTADO_PAGADA and f["monto_pagado"] < f["monto_total"]
    )

    lineas = []
    lineas.append("-- ============================================================================")
    lineas.append("-- Fase 6 - Facturacion (PostgreSQL)")
    lineas.append("-- Esquema destino: \"OLTP\"")
    lineas.append("--")
    lineas.append("-- Generado por oltp/datos_prueba/generar_datos.py.")
    lineas.append("-- No editar a mano: los cambios deben hacerse en el generador.")
    lineas.append("--")
    lineas.append(
        f"-- Contenido: {total} facturas y {total} detalles (una por servicio)."
    )
    lineas.append(
        f"-- Estados: {pagadas} pagadas ({parciales} con pago parcial), "
        f"{pendientes} pendientes y {vencidas} vencidas."
    )
    lineas.append("-- La fecha de emision es la fecha del servicio y el vencimiento")
    lineas.append("-- es la emision + 30 dias.")
    lineas.append("-- La cobertura usa la poliza principal vigente; si no cubre la")
    lineas.append("-- categoria, intenta la secundaria. Sin poliza el paciente paga todo.")
    lineas.append("--")
    lineas.append("-- Requiere: 01_catalogos.sql, 02_maestros.sql, 03_polizas.sql,")
    lineas.append("--           04_ingresos_ocupaciones.sql y 05_servicios.sql.")
    lineas.append("-- ============================================================================")
    lineas.append("")
    lineas.append('SET search_path TO "OLTP";')
    lineas.append("")
    lineas.append('TRUNCATE TABLE "OLTP".FACTURA, "OLTP".FACTURA_DETALLE CASCADE;')
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Facturas")
    lineas.append("-- ============================================================================")
    lineas.append(
        "INSERT INTO FACTURA (ID_FACTURA, NUMBER_INGRESO, CI_PAC, ID_POLIZA, "
        "ID_ASEGURADORA, TIPO_CLIENTE, F_EMISION, F_VENCIMIENTO, MONTO_TOTAL, "
        "MONTO_CUBIERTO, MONTO_PACIENTE, ID_ESTADO, F_PAGO, MONTO_PAGADO) VALUES"
    )
    for posicion, factura in enumerate(facturas):
        sufijo = "," if posicion < total - 1 else ";"
        estado = {
            ESTADO_PAGADA: "PAGADA",
            ESTADO_PENDIENTE: "PENDIENTE",
            ESTADO_VENCIDA: "VENCIDA",
        }[factura["estado"]]
        comentario = (
            f"-- ingreso {factura['numero']} area {factura['area']} "
            f"{factura['tipo']} {factura['referencia']} {estado}"
        )
        lineas.append(
            f"\t({factura['id_factura']}, {factura['numero']}, {factura['ci']}, "
            f"{sql_id(factura['id_poliza'])}, {sql_id(factura['id_aseguradora'])}, "
            f"'{factura['tipo_cliente']}', {sql_fecha(factura['fecha'])}, "
            f"{sql_fecha(factura['f_vencimiento'])}, "
            f"{factura['monto_total']:.2f}, {factura['monto_cubierto']:.2f}, "
            f"{factura['monto_paciente']:.2f}, {factura['estado']}, "
            f"{sql_fecha(factura['f_pago'])}, "
            f"{sql_monto(factura['monto_pagado'])}){sufijo}  {comentario}"
        )
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Detalle de factura (un servicio por linea)")
    lineas.append("-- ============================================================================")
    lineas.append(
        "INSERT INTO FACTURA_DETALLE (ID_DETALLE, ID_FACTURA, ID_TIPO_SERVICIO, "
        "ID_REALIZA, ID_PRESCRIPCION, ID_PRACTICA, F_SERVICIO, MONTO) VALUES"
    )
    for posicion, factura in enumerate(facturas):
        sufijo = "," if posicion < total - 1 else ";"
        id_realiza = subconsulta_servicio(factura) if factura["tipo"] == "realiza" else "NULL"
        id_prescripcion = subconsulta_servicio(factura) if factura["tipo"] == "prescribe" else "NULL"
        id_practica = subconsulta_servicio(factura) if factura["tipo"] == "practica" else "NULL"
        lineas.append(
            f"\t({factura['id_detalle']}, {factura['id_factura']}, "
            f"{factura['id_tipo_servicio']}, {id_realiza}, {id_prescripcion}, "
            f"{id_practica}, {sql_fecha(factura['fecha'])}, "
            f"{factura['monto_total']:.2f}){sufijo}"
        )
    lineas.append("")
    lineas.extend(bloque_validacion_facturacion())
    return "\n".join(lineas) + "\n"


def sql_monto(valor):
    return "NULL" if valor is None else f"{valor:.2f}"


def bloque_validacion_facturacion():
    return [
        "-- ============================================================================",
        "-- Autovalidacion de la fase",
        "-- ============================================================================",
        "DO $$",
        "DECLARE",
        "\tv_filas INTEGER;",
        "BEGIN",
        "\tSELECT count(*) INTO v_filas FROM FACTURA;",
        "\tIF v_filas < 200 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 200 facturas y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\t-- Una factura por servicio.",
        "\tSELECT count(*) INTO v_filas FROM FACTURA;",
        "\tIF v_filas <> (SELECT count(*) FROM REALIZA)",
        "\t            + (SELECT count(*) FROM PRESCRIBE)",
        "\t            + (SELECT count(*) FROM PRACTICA) THEN",
        "\t\tRAISE EXCEPTION 'La cantidad de facturas no coincide con los servicios: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA f",
        "\tWHERE (SELECT count(*) FROM FACTURA_DETALLE d",
        "\t       WHERE d.ID_FACTURA = f.ID_FACTURA) <> 1;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas sin exactamente un detalle: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM REALIZA r",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM FACTURA_DETALLE d WHERE d.ID_REALIZA = r.ID_REALIZA",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay diagnosticos sin factura: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM PRESCRIBE p",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM FACTURA_DETALLE d WHERE d.ID_PRESCRIPCION = p.ID_PRESCRIPCION",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay prescripciones sin factura: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM PRACTICA p",
        "\tWHERE NOT EXISTS (",
        "\t\tSELECT 1 FROM FACTURA_DETALLE d WHERE d.ID_PRACTICA = p.ID_PRACTICA",
        "\t);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay intervenciones sin factura: %', v_filas;",
        "\tEND IF;",
        "",
        "\t-- El detalle y la factura describen el mismo servicio y el mismo monto.",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM FACTURA_DETALLE d",
        "\tJOIN FACTURA f ON f.ID_FACTURA = d.ID_FACTURA",
        "\tLEFT JOIN REALIZA r ON r.ID_REALIZA = d.ID_REALIZA",
        "\tLEFT JOIN PRESCRIBE p ON p.ID_PRESCRIPCION = d.ID_PRESCRIPCION",
        "\tLEFT JOIN PRACTICA pr ON pr.ID_PRACTICA = d.ID_PRACTICA",
        "\tWHERE d.F_SERVICIO <> f.F_EMISION",
        "\t   OR d.MONTO <> f.MONTO_TOTAL",
        "\t   OR (d.ID_REALIZA IS NOT NULL AND d.ID_TIPO_SERVICIO <> 1)",
        "\t   OR (d.ID_PRESCRIPCION IS NOT NULL AND d.ID_TIPO_SERVICIO <> 2)",
        "\t   OR (d.ID_PRACTICA IS NOT NULL AND d.ID_TIPO_SERVICIO <> 3)",
        "\t   OR (r.ID_REALIZA IS NOT NULL",
        "\t       AND (r.NUMBER_INGRESO <> f.NUMBER_INGRESO OR r.CI_PAC <> f.CI_PAC))",
        "\t   OR (p.ID_PRESCRIPCION IS NOT NULL",
        "\t       AND (p.NUMBER_INGRESO <> f.NUMBER_INGRESO OR p.CI_PAC <> f.CI_PAC))",
        "\t   OR (pr.ID_PRACTICA IS NOT NULL",
        "\t       AND (pr.NUMBER_INGRESO <> f.NUMBER_INGRESO OR pr.CI_PAC <> f.CI_PAC));",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay detalles incoherentes con su factura: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE MONTO_CUBIERTO + MONTO_PACIENTE <> MONTO_TOTAL;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas con montos incoherentes: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE (MONTO_CUBIERTO > 0",
        "\t       AND (TIPO_CLIENTE <> 'ASEGURADORA'",
        "\t            OR ID_POLIZA IS NULL OR ID_ASEGURADORA IS NULL))",
        "\t   OR (MONTO_CUBIERTO = 0 AND TIPO_CLIENTE <> 'PACIENTE');",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas con tipo de cliente incoherente: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE F_VENCIMIENTO <> F_EMISION + 30;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas con vencimiento distinto de emision + 30: %', v_filas;",
        "\tEND IF;",
        "",
        "\t-- La poliza usada debe cubrir la categoria del servicio y estar vigente.",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM FACTURA f",
        "\tJOIN FACTURA_DETALLE d ON d.ID_FACTURA = f.ID_FACTURA",
        "\tJOIN TIPO_SERVICIO ts ON ts.ID_TIPO_SERVICIO = d.ID_TIPO_SERVICIO",
        "\tJOIN POLIZA p ON p.ID_POLIZA = f.ID_POLIZA",
        "\tWHERE NOT p.APROBADA",
        "\t   OR f.MONTO_CUBIERTO > p.COBERTURA",
        "\t   OR f.F_EMISION < p.F_DESDE",
        "\t   OR (p.F_HASTA IS NOT NULL AND f.F_EMISION > p.F_HASTA)",
        "\t   OR (ts.CATEGORIA_POLIZA = 'EXAMENES' AND NOT p.EXAMENES)",
        "\t   OR (ts.CATEGORIA_POLIZA = 'HOSPITALIZACION' AND NOT p.HOSPITALIZACION)",
        "\t   OR (ts.CATEGORIA_POLIZA = 'CIRUGIA' AND NOT p.CIRUGIA);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas con una poliza que no cubre el servicio: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE ID_POLIZA IS NULL AND MONTO_CUBIERTO <> 0;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas sin poliza con monto cubierto: %', v_filas;",
        "\tEND IF;",
        "",
        "\t-- Pagadas: con fecha y monto de pago, dentro del corte.",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE ID_ESTADO = 1",
        "\t  AND (F_PAGO IS NULL OR MONTO_PAGADO IS NULL",
        "\t       OR F_PAGO < F_EMISION OR F_PAGO > DATE '2026-10-31'",
        "\t       OR F_PAGO - F_EMISION < 5 OR F_PAGO - F_EMISION > 90",
        "\t       OR MONTO_PAGADO <= 0);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas pagadas sin pago valido: %', v_filas;",
        "\tEND IF;",
        "",
        "\t-- Pendientes y vencidas: impagas.",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE ID_ESTADO IN (2, 3)",
        "\t  AND (F_PAGO IS NOT NULL OR MONTO_PAGADO IS NOT NULL);",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas impagas con datos de pago: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE ID_ESTADO = 2",
        "\t  AND (F_EMISION < DATE '2026-08-01' OR F_EMISION > DATE '2026-10-31');",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas pendientes fuera del cobro reciente: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE ID_ESTADO = 3 AND F_VENCIMIENTO >= DATE '2026-09-01';",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay facturas vencidas con mora de 60 dias o menos: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA WHERE ID_ESTADO = 1;",
        "\tIF v_filas < 150 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 150 facturas pagadas y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA WHERE ID_ESTADO = 2;",
        "\tIF v_filas < 50 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 50 facturas pendientes y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM FACTURA WHERE ID_ESTADO = 3;",
        "\tIF v_filas < 30 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 30 facturas vencidas y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\t-- La mayoria de los pagos son totales, pero debe haber algunos parciales.",
        "\tSELECT count(*) INTO v_filas FROM FACTURA",
        "\tWHERE ID_ESTADO = 1 AND MONTO_PAGADO < MONTO_TOTAL;",
        "\tIF v_filas = 0 THEN",
        "\t\tRAISE EXCEPTION 'No hay facturas pagadas con pago parcial';",
        "\tEND IF;",
        "\tIF v_filas >= (SELECT count(*) / 2 FROM FACTURA WHERE ID_ESTADO = 1) THEN",
        "\t\tRAISE EXCEPTION 'Demasiadas facturas pagadas con pago parcial: %', v_filas;",
        "\tEND IF;",
        "END;",
        "$$;",
    ]


def resumen_facturacion(facturas):
    print(f"Facturas: {len(facturas)}")
    print(f"Detalles: {len(facturas)}")
    estados = {ESTADO_PAGADA: "PAGADA", ESTADO_PENDIENTE: "PENDIENTE", ESTADO_VENCIDA: "VENCIDA"}
    for estado, descripcion in estados.items():
        print(f"{descripcion}: {sum(1 for f in facturas if f['estado'] == estado)}")
    parciales = sum(
        1 for f in facturas
        if f["estado"] == ESTADO_PAGADA and f["monto_pagado"] < f["monto_total"]
    )
    print(f"Pagos parciales: {parciales}")
    print(
        "Facturas con cobertura: "
        f"{sum(1 for f in facturas if f['monto_cubierto'] > 0)}"
    )
    print(
        "Facturas de autopago: "
        f"{sum(1 for f in facturas if f['tipo_cliente'] == 'PACIENTE')}"
    )
    print(
        f"Monto total facturado: {sum(f['monto_total'] for f in facturas):.2f} Bs"
    )


def construir_efectos(servicios):
    """Reparte 2 efectos secundarios por cada una de las 10 areas."""
    prescripciones_por_area = defaultdict(list)
    for fila in servicios["prescribe"]:
        prescripciones_por_area[fila["area"]].append(fila)

    efectos = []
    for orden, area in enumerate(sorted(prescripciones_por_area)):
        filas = prescripciones_por_area[area]
        base = (orden * 7) % len(filas)
        segunda = (base + len(filas) // 2) % len(filas)
        if segunda == base:
            segunda = (base + 1) % len(filas)

        for posicion in (base, segunda):
            fila = filas[posicion]
            dias = int(fila["cant_dias"])
            desplazamiento = (fila["ci_pac"] + fila["numero"] + posicion) % dias
            fecha = fila["f_inicio"] + timedelta(days=desplazamiento)
            gravedad = GRAVEDADES[
                (fila["ci_pac"] + fila["numero"] + posicion) % len(GRAVEDADES)
            ]
            efectos.append({
                "id_efecto": 4001 + len(efectos),
                "prescripcion": fila,
                "fecha": fecha,
                "descripcion": EFECTOS_POR_TRATAMIENTO[fila["id_tratamiento"]],
                "gravedad": gravedad,
                "area": area,
            })

    efectos.sort(key=lambda fila: fila["id_efecto"])
    return efectos


def renderizar_efectos(efectos):
    total = len(efectos)
    lineas = []
    lineas.append("-- ============================================================================")
    lineas.append("-- Fase 7 - Efectos secundarios (PostgreSQL)")
    lineas.append("-- Esquema destino: \"OLTP\"")
    lineas.append("--")
    lineas.append("-- Generado por oltp/datos_prueba/generar_datos.py.")
    lineas.append("-- No editar a mano: los cambios deben hacerse en el generador.")
    lineas.append("--")
    lineas.append(
        f"-- Contenido: {total} efectos secundarios, {EFECTOS_POR_AREA} por area."
    )
    lineas.append("-- La fecha cae dentro del periodo de la prescripcion asociada.")
    lineas.append("--")
    lineas.append("-- Requiere: 01_catalogos.sql, 02_maestros.sql, 03_polizas.sql,")
    lineas.append("--           04_ingresos_ocupaciones.sql y 05_servicios.sql.")
    lineas.append("-- ============================================================================")
    lineas.append("")
    lineas.append('SET search_path TO "OLTP";')
    lineas.append("")
    lineas.append('TRUNCATE TABLE "OLTP".EFECTO_SECUNDARIO_PACIENTE CASCADE;')
    lineas.append("")
    lineas.append("-- ============================================================================")
    lineas.append("-- Efectos secundarios por prescripcion")
    lineas.append("-- ============================================================================")
    lineas.append(
        "INSERT INTO EFECTO_SECUNDARIO_PACIENTE (ID_EFECTO, ID_PRESCRIPCION, "
        "FECHA, DESCRIPCION, GRAVEDAD) VALUES"
    )
    for posicion, efecto in enumerate(efectos):
        sufijo = "," if posicion < total - 1 else ";"
        fila = efecto["prescripcion"]
        comentario = (
            f"-- ingreso {fila['numero']} area {efecto['area']} "
            f"tratamiento {fila['id_tratamiento']}"
        )
        lineas.append(
            f"\t({efecto['id_efecto']}, {subconsulta_prescripcion(fila)}, "
            f"{sql_fecha(efecto['fecha'])}, '{efecto['descripcion']}', "
            f"'{efecto['gravedad']}'){sufijo}  {comentario}"
        )
    lineas.append("")
    lineas.extend(bloque_validacion_efectos())
    return "\n".join(lineas) + "\n"


def bloque_validacion_efectos():
    return [
        "-- ============================================================================",
        "-- Autovalidacion de la fase",
        "-- ============================================================================",
        "DO $$",
        "DECLARE",
        "\tv_filas INTEGER;",
        "BEGIN",
        "\tSELECT count(*) INTO v_filas FROM EFECTO_SECUNDARIO_PACIENTE;",
        "\tIF v_filas < 20 THEN",
        "\t\tRAISE EXCEPTION 'Se esperaban al menos 20 efectos secundarios y hay %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas",
        "\tFROM EFECTO_SECUNDARIO_PACIENTE e",
        "\tJOIN PRESCRIBE p ON p.ID_PRESCRIPCION = e.ID_PRESCRIPCION",
        "\tWHERE p.F_INICIO IS NULL OR p.F_FIN IS NULL",
        "\t   OR e.FECHA < p.F_INICIO OR e.FECHA > p.F_FIN;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay efectos fuera del periodo de la prescripcion: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM EFECTO_SECUNDARIO_PACIENTE",
        "\tWHERE GRAVEDAD NOT IN ('LEVE', 'MODERADO', 'GRAVE');",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay efectos con gravedad invalida: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM EFECTO_SECUNDARIO_PACIENTE",
        "\tWHERE DESCRIPCION IS NULL OR trim(DESCRIPCION) = '';",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay efectos sin descripcion: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM (",
        "\t\tSELECT ID_PRESCRIPCION FROM EFECTO_SECUNDARIO_PACIENTE",
        "\t\tGROUP BY 1 HAVING count(*) > 1",
        "\t) d;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay prescripciones con mas de un efecto: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(DISTINCT i.ID_AREA) INTO v_filas",
        "\tFROM EFECTO_SECUNDARIO_PACIENTE e",
        "\tJOIN PRESCRIBE p ON p.ID_PRESCRIPCION = e.ID_PRESCRIPCION",
        "\tJOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO;",
        "\tIF v_filas <> 10 THEN",
        "\t\tRAISE EXCEPTION 'Los efectos no se reparten entre las 10 areas: %', v_filas;",
        "\tEND IF;",
        "",
        "\tSELECT count(*) INTO v_filas FROM (",
        "\t\tSELECT i.ID_AREA, count(*) AS efectos",
        "\t\tFROM EFECTO_SECUNDARIO_PACIENTE e",
        "\t\tJOIN PRESCRIBE p ON p.ID_PRESCRIPCION = e.ID_PRESCRIPCION",
        "\t\tJOIN INGRESO i ON i.NUMBER_INGRESO = p.NUMBER_INGRESO",
        "\t\tGROUP BY 1 HAVING count(*) < 2",
        "\t) d;",
        "\tIF v_filas > 0 THEN",
        "\t\tRAISE EXCEPTION 'Hay areas con menos de 2 efectos: %', v_filas;",
        "\tEND IF;",
        "END;",
        "$$;",
    ]


def resumen_efectos(efectos):
    print(f"Efectos secundarios: {len(efectos)}")
    for gravedad in GRAVEDADES:
        print(
            f"{gravedad}: "
            f"{sum(1 for e in efectos if e['gravedad'] == gravedad)}"
        )
    print("Efectos por area:")
    for area, cantidad in sorted(Counter(e["area"] for e in efectos).items()):
        print(f"  area {area}: {cantidad}")


def resumen(ingresos):
    print(f"Ingresos: {len(ingresos)}")
    print(f"Ocupaciones: {len(ingresos)}")
    print(f"ACTIVA: {sum(1 for i in ingresos if i['activa'])}")
    print(f"Rango de numeros: {min(i['numero'] for i in ingresos)}-{max(i['numero'] for i in ingresos)}")
    print("Ingresos por area:")
    for area, cantidad in sorted(Counter(i["area"] for i in ingresos).items()):
        print(f"  area {area}: {cantidad}")
    print("Ingresos por mes:")
    for (anio, mes), cantidad in sorted(Counter((i["inicio"].year, i["inicio"].month) for i in ingresos).items()):
        print(f"  {anio}-{mes:02d}: {cantidad}")


def main():
    parser = argparse.ArgumentParser(description="Genera las fases 4 a 7 del OLTP.")
    parser.add_argument(
        "--out",
        default=str(Path(__file__).resolve().parent / "04_ingresos_ocupaciones.sql"),
        help="Archivo SQL de la Fase 4.",
    )
    parser.add_argument(
        "--out-servicios",
        default=str(Path(__file__).resolve().parent / "05_servicios.sql"),
        help="Archivo SQL de la Fase 5.",
    )
    parser.add_argument(
        "--out-facturacion",
        default=str(Path(__file__).resolve().parent / "06_facturacion.sql"),
        help="Archivo SQL de la Fase 6.",
    )
    parser.add_argument(
        "--out-efectos",
        default=str(Path(__file__).resolve().parent / "07_efectos_secundarios.sql"),
        help="Archivo SQL de la Fase 7.",
    )
    parser.add_argument(
        "--solo-fase",
        choices=("4", "5", "6", "7"),
        help="Genera solo la fase indicada.",
    )
    args = parser.parse_args()

    ingresos = construir_ingresos()

    if args.solo_fase in (None, "4"):
        sql = renderizar(ingresos)
        Path(args.out).write_text(sql, encoding="utf-8")
        resumen(ingresos)
        print(f"Archivo generado: {args.out}")

    if args.solo_fase in (None, "5", "6", "7"):
        servicios = construir_servicios(ingresos)

        if args.solo_fase in (None, "5"):
            sql_servicios = renderizar_servicios(servicios)
            Path(args.out_servicios).write_text(sql_servicios, encoding="utf-8")
            resumen_servicios(servicios)
            print(f"Archivo generado: {args.out_servicios}")

        if args.solo_fase in (None, "6"):
            facturas = construir_facturas(servicios)
            sql_facturacion = renderizar_facturacion(facturas)
            Path(args.out_facturacion).write_text(sql_facturacion, encoding="utf-8")
            resumen_facturacion(facturas)
            print(f"Archivo generado: {args.out_facturacion}")

        if args.solo_fase in (None, "7"):
            efectos = construir_efectos(servicios)
            sql_efectos = renderizar_efectos(efectos)
            Path(args.out_efectos).write_text(sql_efectos, encoding="utf-8")
            resumen_efectos(efectos)
            print(f"Archivo generado: {args.out_efectos}")


if __name__ == "__main__":
    main()
