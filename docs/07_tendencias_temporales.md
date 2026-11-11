# Pregunta 7. Análisis de tendencias temporales

## Enunciado
Construir evolución mensual de ventas y ganancias: variación vs mes anterior, comparación con el mismo mes del año anterior, promedio móvil de 3 meses e identificación de los tres meses con mayor y menor volumen de ventas. Usar `LAG()`, ventanas y agregaciones temporales.

## Estrategia de solución
Agregar por mes con `TRUNC(order_date, 'MM')`. Calcular `LAG` a 1 mes (MoM) y a 12 meses (YoY), más media móvil de 3 meses con `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`. Obtener top/bottom 3 con `ORDER BY ... LIMIT`.

## Consulta HiveQL
Ver script: `scripts/analisis/07_tendencias.hql`

```sql
USE superstore_db;

WITH mensual AS (
  SELECT
    TRUNC(order_date, 'MM') AS mes,
    SUM(sales) AS ventas,
    SUM(profit) AS ganancia
  FROM superstore
  GROUP BY TRUNC(order_date, 'MM')
),
calc AS (
  SELECT
    mes,
    ventas,
    ganancia,
    LAG(ventas, 1) OVER (ORDER BY mes) AS ventas_mes_ant,
    ROUND(
      (ventas - LAG(ventas, 1) OVER (ORDER BY mes))
      / NULLIF(LAG(ventas, 1) OVER (ORDER BY mes), 0) * 100, 2
    ) AS var_mes_pct,
    LAG(ventas, 12) OVER (ORDER BY mes) AS ventas_mismo_mes_anio_ant,
    ROUND(
      (ventas - LAG(ventas, 12) OVER (ORDER BY mes))
      / NULLIF(LAG(ventas, 12) OVER (ORDER BY mes), 0) * 100, 2
    ) AS var_yoy_pct,
    ROUND(
      AVG(ventas) OVER (ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2
    ) AS media_movil_3m
  FROM mensual
)
SELECT * FROM calc ORDER BY mes;

SELECT mes, ventas FROM mensual ORDER BY ventas DESC LIMIT 3;
SELECT mes, ventas FROM mensual ORDER BY ventas ASC LIMIT 3;
```

## Evidencia de ejecución
![Tendencias mensuales](../evidencias/p07/Screenshot%202026-11-11%20100324.png)

## Resultado obtenido
Serie mensual con variaciones MoM/YoY, media móvil y extremos de volumen (ver captura).

## Interpretación técnica
La media móvil suaviza ruido mensual; MoM captura cambios de corto plazo y YoY controla estacionalidad. Los meses extremos señalan picos comerciales y valles operativos.

## Conclusión
El análisis temporal evidencia ciclos y puntos de inflexión útiles para planificación comercial y de inventario.
