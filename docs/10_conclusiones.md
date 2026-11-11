# Conclusiones generales

## Enunciado
Sintetizar los hallazgos del proyecto de procesamiento y análisis del Sample Superstore en Apache Hive.

## Estrategia de solución
Integrar resultados de modelado, calidad, analítica comercial (región, RFM, productos, descuentos) y analítica avanzada (tendencias, Pareto), destacando implicaciones para la toma de decisiones.

## Consulta HiveQL
No aplica una consulta única; el proyecto se sustenta en los scripts de `scripts/ddl/`, `scripts/analisis/` y `scripts/optimizacion/`.

## Evidencia de ejecución
El historial de evidencias por pregunta está en `evidencias/p01` … `evidencias/p08`.

## Resultado obtenido
1. **Modelado:** pipeline staging → tabla tipada ORC reproducible en Docker Hive.
2. **Calidad:** métricas de integridad documentadas con criterios de tratamiento.
3. **Región:** evolución anual con margen y variación YoY mediante CTE/`LAG`.
4. **RFM:** perfiles de alto valor, recurrentes y riesgo de abandono.
5. **Productos:** rankings con `RANK`/`DENSE_RANK` por categoría y rentabilidad.
6. **Descuentos:** rangos asociados a pérdidas y categorías más afectadas.
7. **Tendencias:** serie mensual con MoM, YoY y media móvil.
8. **Pareto:** concentración 80/20 distinta entre ventas y ganancias.

## Interpretación técnica
HiveQL con CTEs y funciones de ventana permite responder preguntas de negocio sin salir del ecosistema Big Data. La calidad de datos condiciona la validez de cada KPI; por ello la auditoría precede al análisis.

## Conclusión
El proyecto demuestra el ciclo completo de ingeniería y analítica en Hive: modelar, auditar, consultar, optimizar e interpretar resultados para apoyar decisiones comerciales sobre el Superstore.
