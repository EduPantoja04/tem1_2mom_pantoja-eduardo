USE superstore_db;

WITH base AS (
  SELECT
    *,
    CASE
      WHEN discount = 0 THEN 'Sin descuento'
      WHEN discount > 0 AND discount <= 0.20 THEN 'Descuento bajo'
      WHEN discount > 0.20 AND discount <= 0.50 THEN 'Descuento medio'
      WHEN discount > 0.50 THEN 'Descuento alto'
    END AS rango_descuento,
    CASE WHEN profit < 0 THEN 1 ELSE 0 END AS es_perdida
  FROM superstore
)
SELECT
  rango_descuento,
  SUM(sales) AS ventas,
  SUM(profit) AS ganancia,
  ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS margen_pct,
  SUM(es_perdida) AS regs_perdida,
  ROUND(SUM(es_perdida) * 100.0 / COUNT(*), 2) AS pct_no_rentables,
  ROUND(AVG(discount) * 100, 2) AS descuento_promedio_pct,
  COUNT(*) AS n_registros
FROM base
GROUP BY rango_descuento
ORDER BY rango_descuento;

SELECT
  category,
  sub_category,
  COUNT(*) AS n,
  SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS perdidas
FROM superstore
WHERE discount > 0.50
GROUP BY category, sub_category
ORDER BY perdidas DESC
LIMIT 10;
