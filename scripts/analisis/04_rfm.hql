USE superstore_db;

WITH rfm AS (
  SELECT
    customer_id,
    customer_name,
    DATEDIFF(
      (SELECT MAX(order_date) FROM superstore),
      MAX(order_date)
    ) AS recency,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(sales) AS monetary
  FROM superstore
  GROUP BY customer_id, customer_name
),
scored AS (
  SELECT
    *,
    NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
  FROM rfm
)
SELECT
  customer_id,
  customer_name,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  CONCAT(CAST(r_score AS STRING), CAST(f_score AS STRING), CAST(m_score AS STRING)) AS rfm_code,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Alto valor'
    WHEN f_score >= 4 AND m_score >= 3 THEN 'Recurrente'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Riesgo abandono'
    ELSE 'Regular'
  END AS segmento
FROM scored;
