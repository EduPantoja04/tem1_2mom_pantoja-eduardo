USE superstore_db;

-- Total
SELECT COUNT(*) AS total_registros FROM superstore;

-- Row ID duplicados
SELECT COUNT(*) AS row_id_duplicados
FROM (
  SELECT row_id FROM superstore GROUP BY row_id HAVING COUNT(*) > 1
) t;

-- Órdenes y clientes únicos
SELECT
  COUNT(DISTINCT order_id) AS ordenes_unicas,
  COUNT(DISTINCT customer_id) AS clientes_unicos
FROM superstore;

-- NULLs por campos clave
SELECT
  SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS null_row_id,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
  SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
  SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
  SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM superstore;

-- Fechas inválidas (NULL tras parseo) / ship < order
SELECT COUNT(*) AS fechas_envio_antes_pedido
FROM superstore
WHERE ship_date < order_date;

-- Ventas <= 0
SELECT COUNT(*) AS ventas_le_cero FROM superstore WHERE sales <= 0;

-- Descuento fuera de [0,1] (si Discount está en proporción)
SELECT COUNT(*) AS descuento_fuera_rango
FROM superstore
WHERE discount < 0 OR discount > 1;

-- Resumen unificado (ejemplo)
SELECT 'total_registros' AS metrica, CAST(COUNT(*) AS STRING) AS valor FROM superstore
UNION ALL
SELECT 'ordenes_unicas', CAST(COUNT(DISTINCT order_id) AS STRING) FROM superstore
UNION ALL
SELECT 'clientes_unicos', CAST(COUNT(DISTINCT customer_id) AS STRING) FROM superstore
UNION ALL
SELECT 'ventas_le_cero', CAST(SUM(CASE WHEN sales <= 0 THEN 1 ELSE 0 END) AS STRING) FROM superstore
UNION ALL
SELECT 'descuento_fuera_rango', CAST(SUM(CASE WHEN discount < 0 OR discount > 1 THEN 1 ELSE 0 END) AS STRING) FROM superstore
UNION ALL
SELECT 'ship_antes_order', CAST(SUM(CASE WHEN ship_date < order_date THEN 1 ELSE 0 END) AS STRING) FROM superstore;