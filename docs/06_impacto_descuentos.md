# Pregunta 6. Análisis del impacto de los descuentos

## Enunciado
Clasificar registros en rangos de descuento (sin, bajo ≤20%, medio ≤50%, alto >50%) y calcular ventas, ganancias, margen, registros con pérdidas, % no rentables, descuento promedio y categorías/subcategorías más afectadas. Evaluar si descuentos elevados se asocian a mayor proporción de operaciones no rentables.

## Estrategia de solución
Etiquetar cada línea con un rango mediante `CASE` sobre `discount`. Agregar KPIs por rango. Complementar con un corte de categorías/subcategorías bajo descuento alto y pérdidas (`profit < 0`).

## Consulta HiveQL
Ver script: `scripts/analisis/06_descuentos.hql`

```sql
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
```

## Evidencia de ejecución
![Impacto descuentos 1](../evidencias/p06/Screenshot%202026-11-11%20100204.png)
![Impacto descuentos 2](../evidencias/p06/Screenshot%202026-11-11%20100228.png)

## Resultado obtenido
KPIs por rango de descuento y ranking de categorías/subcategorías más afectadas bajo descuento alto (ver capturas).

## Interpretación técnica
Si el `%` de operaciones no rentables crece al pasar de descuento bajo a alto, existe asociación entre agresividad comercial y deterioro del margen. Las subcategorías con más pérdidas bajo descuento alto son prioritarias para revisión de política de precios.

## Conclusión
El análisis confirma (según evidencia) la relación entre rangos de descuento y rentabilidad, aportando base cuantitativa para ajustar descuentos sin sacrificar contribución.
