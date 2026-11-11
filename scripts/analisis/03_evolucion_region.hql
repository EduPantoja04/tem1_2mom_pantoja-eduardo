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

-- Mejor / peor desempeño (ej. por ganancia total del periodo)
SELECT region, SUM(profit) AS ganancia_total
FROM superstore
GROUP BY region
ORDER BY ganancia_total DESC;