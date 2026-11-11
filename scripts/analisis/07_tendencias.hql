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
