# Pregunta 2. Auditoría de calidad e integridad de datos

## Enunciado
Realizar un análisis de calidad sobre el dataset: total de registros, duplicados de fila, órdenes/clientes únicos, NULLs, fechas inválidas, ventas ≤ 0, descuentos fuera de rango y envíos anteriores al pedido. Construir un resumen y proponer criterios de tratamiento.

## Estrategia de solución
Ejecutar métricas de integridad sobre `superstore` con agregaciones y `CASE`. Consolidar hallazgos clave en un resumen con `UNION ALL`. Con base en los resultados, definir reglas de exclusión o corrección para analítica.

## Consulta HiveQL
Ver script: `scripts/analisis/02_calidad.hql`

```sql
USE superstore_db;

SELECT COUNT(*) AS total_registros FROM superstore;

SELECT COUNT(*) AS row_id_duplicados
FROM (
  SELECT row_id FROM superstore GROUP BY row_id HAVING COUNT(*) > 1
) t;

SELECT
  COUNT(DISTINCT order_id) AS ordenes_unicas,
  COUNT(DISTINCT customer_id) AS clientes_unicos
FROM superstore;

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

SELECT COUNT(*) AS fechas_envio_antes_pedido
FROM superstore
WHERE ship_date < order_date;

SELECT COUNT(*) AS ventas_le_cero FROM superstore WHERE sales <= 0;

SELECT COUNT(*) AS descuento_fuera_rango
FROM superstore
WHERE discount < 0 OR discount > 1;

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
```

## Evidencia de ejecución
![Auditoría calidad 1](../evidencias/p02/Screenshot%202026-11-11%20095148.png)
![Auditoría calidad 2](../evidencias/p02/Screenshot%202026-11-11%20095325.png)
![Auditoría calidad 3](../evidencias/p02/Screenshot%202026-11-11%20095418.png)

## Resultado obtenido
Resumen de métricas de calidad obtenido en Beeline (total de registros, unicidad, nulos e inconsistencias de negocio). Detalle numérico en las capturas de `evidencias/p02/`.

## Interpretación técnica
La auditoría permite separar problemas estructurales (nulos, duplicados) de inconsistencias de negocio (ventas ≤ 0, descuentos fuera de `[0,1]`, `ship_date < order_date`).

### Criterios de tratamiento propuestos
| Hallazgo | Tratamiento sugerido |
|----------|----------------------|
| `row_id` duplicado | Conservar una fila (p. ej. la primera) o investigar origen |
| Fechas nulas / no parseadas | Excluir de análisis temporales o corregir en staging |
| `ship_date < order_date` | Marcar como anómalo; excluir de KPIs de lead time |
| `sales <= 0` | Excluir de rankings de ventas o revisar como devolución |
| `discount` fuera de `[0,1]` | Filtrar o recortar al intervalo válido |

## Conclusión
Se obtuvo un diagnóstico de calidad accionable que condiciona la confiabilidad de las consultas analíticas posteriores.
