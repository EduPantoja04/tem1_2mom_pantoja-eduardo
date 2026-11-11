# Pregunta 8. Análisis Pareto de ventas y rentabilidad

## Enunciado
Aplicar la regla 80/20: (a) productos que concentran el 80% de ventas acumuladas; (b) productos que concentran el 80% de ganancias acumuladas. Ordenar por contribución, calcular participación acumulada, identificar concentradores y comparar ambos resultados.

## Estrategia de solución
Agregar por producto, ordenar de mayor a menor contribución y calcular porcentaje acumulado con `SUM() OVER`. Para incluir el producto que cruza el umbral del 80% (compatible con Hive 2.x), usar `LAG(pct_acum)` y filtrar `pct_acum_ant < 80`. Repetir el patrón para ganancias.

## Consulta HiveQL
Ver script: `scripts/analisis/08_pareto.hql`

### a) 80% de ventas
```sql
USE superstore_db;

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
```

### b) 80% de ganancias
```sql
USE superstore_db;

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
```

## Evidencia de ejecución
![Pareto ventas](../evidencias/p08/Screenshot%202026-11-11%20100707.png)
![Pareto ganancias](../evidencias/p08/Screenshot%202026-11-11%20100757.png)

## Resultado obtenido
Conjuntos de productos que concentran ~80% de ventas y ~80% de ganancias, con porcentajes acumulados (ver capturas).

## Interpretación técnica
Es esperable que el conjunto Pareto de ventas no coincida plenamente con el de ganancias: hay productos de alto volumen con margen bajo y productos menos vendidos pero muy rentables. La comparación orienta a no decidir solo por facturación.

## Conclusión
La regla 80/20 evidencia concentración comercial distinta según se mire ventas o rentabilidad; la gestión debe equilibrar ambos criterios.
