# Pregunta 5. Ranking de productos según rentabilidad

## Enunciado
Identificar productos de mayor y menor desempeño: top 5 por ganancia acumulada por categoría, top 5 por volumen de ventas, top 5 con menor rentabilidad, margen individual y posición dentro de la categoría. Usar `RANK()`, `DENSE_RANK()` y agregaciones.

## Estrategia de solución
Agregar ventas/ganancia/margen por producto y categoría. Aplicar `RANK()` por ganancia dentro de categoría, `DENSE_RANK()` por ventas y un ranking global de menor margen. Filtrar los top/bottom 5 según el ranking correspondiente.

## Consulta HiveQL
Ver script: `scripts/analisis/05_ranking_productos.hql`

```sql
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
-- Top 5 mayor ganancia por categoría
SELECT *
FROM ranked
WHERE rank_ganancia_cat <= 5
ORDER BY category, rank_ganancia_cat;

-- Top 5 mayor volumen de ventas (global)
SELECT *
FROM ranked
WHERE rank_ventas_global <= 5
ORDER BY rank_ventas_global;

-- Top 5 menor rentabilidad (margen)
SELECT *
FROM ranked
WHERE rank_menor_rentabilidad <= 5
ORDER BY rank_menor_rentabilidad;
```

## Evidencia de ejecución
![Ranking productos](../evidencias/p05/Screenshot%202026-11-11%20100112.png)

## Resultado obtenido
Rankings de productos por ganancia (por categoría), ventas y menor margen (ver captura).

## Interpretación técnica
`RANK` deja huecos ante empates; `DENSE_RANK` no. Combinarlos evidencia tanto liderazgo por categoría como concentración de ventas globales y productos con margen crítico.

## Conclusión
El ranking orienta decisiones de surtido: potenciar productos top por categoría y revisar aquellos con menor rentabilidad pese a su rotación.
