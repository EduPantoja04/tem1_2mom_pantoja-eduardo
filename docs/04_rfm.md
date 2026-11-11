# Pregunta 4. Segmentación avanzada de clientes mediante RFM

## Enunciado
Construir un análisis RFM (Recency, Frequency, Monetary): días desde la última compra respecto a la fecha máxima del dataset, órdenes únicas, ventas acumuladas, puntuaciones RFM e identificación de clientes de alto valor, recurrentes y en riesgo de abandono.

## Estrategia de solución
1. Calcular por cliente: `recency` con `DATEDIFF` respecto a `MAX(order_date)`, `frequency` con `COUNT(DISTINCT order_id)` y `monetary` con `SUM(sales)`.
2. Asignar scores 1–5 con `NTILE(5)` (menor recency = mejor; mayor frequency/monetary = mejor).
3. Segmentar con reglas de negocio justificadas sobre los scores.
4. Evitar `CROSS JOIN` (Hive lo bloquea en modo estricto) usando subconsulta escalar para la fecha de referencia.

### Criterios de segmentación (justificación)
| Segmento | Regla | Justificación |
|----------|-------|---------------|
| Alto valor | R,F,M ≥ 4 | Compra reciente, frecuente y de alto monto |
| Recurrente | F ≥ 4 y M ≥ 3 | Alta frecuencia con aporte monetario relevante |
| Riesgo abandono | R ≤ 2 y F ≤ 2 | Baja actividad reciente y poca frecuencia histórica |
| Regular | Resto | Perfil intermedio |

## Consulta HiveQL
Ver script: `scripts/analisis/04_rfm.hql`

```sql
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
```

## Evidencia de ejecución
![RFM clientes](../evidencias/p04/Screenshot%202026-11-11%20095947.png)

## Resultado obtenido
Listado de clientes con métricas RFM, código RFM y segmento asignado (ver captura).

## Interpretación técnica
RFM prioriza retención: los de alto valor sostienen el ingreso; los recurrentes son base estable; el riesgo de abandono concentra oportunidades de reactivación comercial.

## Conclusión
La segmentación RFM permite orientar acciones diferenciadas por perfil de cliente con criterios explícitos y reproducibles en HiveQL.
