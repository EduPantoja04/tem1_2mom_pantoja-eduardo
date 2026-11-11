# Análisis de optimización

## Enunciado
Documentar estrategias de optimización aplicadas o recomendadas sobre el modelo Hive del dataset Superstore.

## Estrategia de solución
Evaluar formato de almacenamiento, tipado, particionamiento, estadísticas y buenas prácticas de consulta (`EXPLAIN`, filtros selectivos, evitar `SELECT *` en producción).

## Consulta HiveQL
Ver script: `scripts/optimizacion/01_optimizacion.hql`

```sql
USE superstore_db;

-- Estadísticas de tabla
ANALYZE TABLE superstore COMPUTE STATISTICS;
ANALYZE TABLE superstore COMPUTE STATISTICS FOR COLUMNS region, order_date, category, sales, profit;

-- Plan de ejecución de una consulta típica
EXPLAIN
SELECT region, SUM(sales) AS ventas, SUM(profit) AS ganancia
FROM superstore
WHERE region = 'West'
GROUP BY region;

-- Ejemplo de tabla particionada por región (opcional / demostrativo)
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

DROP TABLE IF EXISTS superstore_part;
CREATE TABLE superstore_part (
  row_id INT,
  order_id STRING,
  order_date DATE,
  ship_date DATE,
  ship_mode STRING,
  customer_id STRING,
  customer_name STRING,
  segment STRING,
  country STRING,
  city STRING,
  state STRING,
  postal_code STRING,
  product_id STRING,
  category STRING,
  sub_category STRING,
  product_name STRING,
  sales DOUBLE,
  quantity INT,
  discount DOUBLE,
  profit DOUBLE
)
PARTITIONED BY (region STRING)
STORED AS ORC;

INSERT OVERWRITE TABLE superstore_part PARTITION (region)
SELECT
  row_id, order_id, order_date, ship_date, ship_mode,
  customer_id, customer_name, segment, country, city, state, postal_code,
  product_id, category, sub_category, product_name,
  sales, quantity, discount, profit, region
FROM superstore;

SHOW PARTITIONS superstore_part;
```

## Evidencia de ejecución
Agregar capturas de `EXPLAIN`, `ANALYZE TABLE` y/o `SHOW PARTITIONS` en `evidencias/optimizacion/` cuando se ejecuten.

## Resultado obtenido
- Tabla analítica en **ORC** (mejor compresión y predicados que TEXTFILE).
- Staging en texto solo para ingesta.
- Posibilidad de particionar por `region` para consultas regionales.
- Estadísticas para mejorar el planificador.

## Interpretación técnica
ORC + tipado correcto reduce I/O. El particionamiento ayuda cuando los filtros coinciden con la clave de partición; mal usado (muchas particiones pequeñas) puede degradar. `ANALYZE` alimenta al optimizador basado en costos.

## Conclusión
Las optimizaciones priorizan formato columnar, estadísticas y partición alineada a patrones de consulta del negocio.
