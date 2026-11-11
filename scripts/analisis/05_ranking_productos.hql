USE superstore_db;

WITH prod AS (
  SELECT
    category,
    product_id,
    product_name,
    SUM(sales) AS ventas,
    SUM(profit) AS ganancia,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS margen_pct
  FROM superstore
  GROUP BY category, product_id, product_name
),
ranked AS (
  SELECT
    *,
    RANK() OVER (PARTITION BY category ORDER BY ganancia DESC) AS rank_ganancia_cat,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY ventas DESC) AS dense_rank_ventas_cat,
    RANK() OVER (ORDER BY margen_pct ASC) AS rank_menor_rentabilidad,
    RANK() OVER (ORDER BY ventas DESC) AS rank_ventas_global
  FROM prod
)
SELECT *
FROM ranked
WHERE rank_ganancia_cat <= 5
ORDER BY category, rank_ganancia_cat;

SELECT *
FROM ranked
WHERE rank_ventas_global <= 5
ORDER BY rank_ventas_global;

SELECT *
FROM ranked
WHERE rank_menor_rentabilidad <= 5
ORDER BY rank_menor_rentabilidad;
