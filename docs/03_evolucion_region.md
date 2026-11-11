# Pregunta 3. Análisis de evolución comercial por región

## Enunciado
Determinar la evolución de ventas y ganancias por región y año: totales, margen, variación porcentual respecto al año anterior e identificación de la región con mejor y peor desempeño. Usar CTE y funciones de ventana.

## Estrategia de solución
Agregar ventas y ganancia por `region` y `YEAR(order_date)` en una CTE. Calcular margen y variación YoY con `LAG()` particionado por región. En una segunda consulta, rankear regiones por ganancia total acumulada.

## Consulta HiveQL
Ver script: `scripts/analisis/03_evolucion_region.hql`

```sql
USE superstore_db;

WITH base AS (
  SELECT
    region,
    YEAR(order_date) AS anio,
    SUM(sales) AS ventas,
    SUM(profit) AS ganancia
  FROM superstore
  GROUP BY region, YEAR(order_date)
),
calc AS (
  SELECT
    region,
    anio,
    ventas,
    ganancia,
    ROUND(ganancia / NULLIF(ventas, 0) * 100, 2) AS margen_pct,
    LAG(ventas) OVER (PARTITION BY region ORDER BY anio) AS ventas_ant,
    ROUND(
      (ventas - LAG(ventas) OVER (PARTITION BY region ORDER BY anio))
      / NULLIF(LAG(ventas) OVER (PARTITION BY region ORDER BY anio), 0) * 100, 2
    ) AS var_ventas_pct
  FROM base
)
SELECT * FROM calc ORDER BY region, anio;

SELECT region, SUM(profit) AS ganancia_total
FROM superstore
GROUP BY region
ORDER BY ganancia_total DESC;
```

## Evidencia de ejecución
![Evolución por región](../evidencias/p03/Screenshot%202026-11-11%20095611.png)
![Mejor/peor región](../evidencias/p03/Screenshot%202026-11-11%20095646.png)

## Resultado obtenido
Serie región-año con ventas, ganancia, margen y variación porcentual; ranking de regiones por ganancia total (ver capturas).

## Interpretación técnica
`LAG` permite comparar cada año con el inmediato anterior dentro de la misma región sin autojoins. El margen contextualiza si el crecimiento de ventas se traduce en rentabilidad.

## Conclusión
La evolución regional muestra diferencias claras de desempeño; la región con mayor ganancia acumulada lidera el negocio y la de menor ganancia concentra el peor resultado comercial del periodo.
