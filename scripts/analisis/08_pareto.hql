USE superstore_db;

-- a) Pareto 80% ventas
WITH por_producto AS (
  SELECT
    product_id,
    product_name,
    SUM(sales) AS ventas,
    SUM(profit) AS ganancia
  FROM superstore
  GROUP BY product_id, product_name
),
ventas_ord AS (
  SELECT
    product_id,
    product_name,
    ventas,
    ganancia,
    SUM(ventas) OVER (ORDER BY ventas DESC) AS ventas_acum,
    SUM(ventas) OVER () AS ventas_total,
    ROUND(
      SUM(ventas) OVER (ORDER BY ventas DESC) * 100.0
      / SUM(ventas) OVER (), 2
    ) AS pct_acum
  FROM por_producto
),
marcado AS (
  SELECT
    *,
    LAG(pct_acum, 1, CAST(0.0 AS DOUBLE)) OVER (ORDER BY ventas DESC) AS pct_acum_ant
  FROM ventas_ord
)
SELECT
  product_id,
  product_name,
  ventas,
  ventas_acum,
  ventas_total,
  pct_acum
FROM marcado
WHERE pct_acum_ant < 80
ORDER BY ventas DESC;

-- b) Pareto 80% ganancias
WITH por_producto AS (
  SELECT
    product_id,
    product_name,
    SUM(sales) AS ventas,
    SUM(profit) AS ganancia
  FROM superstore
  GROUP BY product_id, product_name
),
gan_ord AS (
  SELECT
    product_id,
    product_name,
    ventas,
    ganancia,
    SUM(ganancia) OVER (ORDER BY ganancia DESC) AS ganancia_acum,
    SUM(ganancia) OVER () AS ganancia_total,
    ROUND(
      SUM(ganancia) OVER (ORDER BY ganancia DESC) * 100.0
      / SUM(ganancia) OVER (), 2
    ) AS pct_acum
  FROM por_producto
),
marcado AS (
  SELECT
    *,
    LAG(pct_acum, 1, CAST(0.0 AS DOUBLE)) OVER (ORDER BY ganancia DESC) AS pct_acum_ant
  FROM gan_ord
)
SELECT
  product_id,
  product_name,
  ganancia,
  ganancia_acum,
  ganancia_total,
  pct_acum
FROM marcado
WHERE pct_acum_ant < 80
ORDER BY ganancia DESC;
