# Pregunta 1. Diseño e implementación del modelo de datos

## Enunciado
Construir el modelo de almacenamiento en Apache Hive para el dataset Superstore: identificar campos, elaborar diccionario de datos, crear tabla analítica con tipos apropiados y documentar el procedimiento de carga.

## Estrategia de solución
1. Inspeccionar el CSV y definir el diccionario de datos (`docs/00_diccionario_datos.md`).
2. Crear una tabla staging (`superstore_stg`) con todos los campos en `STRING` y `OpenCSVSerde` para absorber comillas/comas del CSV.
3. Crear la tabla analítica (`superstore`) tipada y almacenada en ORC.
4. Cargar el CSV con `LOAD DATA LOCAL INPATH` hacia staging.
5. Transformar con `INSERT OVERWRITE` casteando fechas (`M/d/yyyy`), numéricos e insertando en `superstore`.
6. Validar con `SELECT ... LIMIT 10` y `COUNT(*)`.

## Consulta HiveQL

### DDL
Ver script: `scripts/ddl/01_create_tables.hql`

```sql
CREATE DATABASE IF NOT EXISTS superstore_db;
USE superstore_db;

DROP TABLE IF EXISTS superstore_stg;
CREATE TABLE superstore_stg (
  row_id STRING,
  order_id STRING,
  order_date STRING,
  ship_date STRING,
  ship_mode STRING,
  customer_id STRING,
  customer_name STRING,
  segment STRING,
  country STRING,
  city STRING,
  state STRING,
  postal_code STRING,
  region STRING,
  product_id STRING,
  category STRING,
  sub_category STRING,
  product_name STRING,
  sales STRING,
  quantity STRING,
  discount STRING,
  profit STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar"     = "\""
)
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

DROP TABLE IF EXISTS superstore;
CREATE TABLE superstore (
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
  region STRING,
  product_id STRING,
  category STRING,
  sub_category STRING,
  product_name STRING,
  sales DOUBLE,
  quantity INT,
  discount DOUBLE,
  profit DOUBLE
)
STORED AS ORC;
```

### DML / carga
Ver script: `scripts/ddl/01_load_data.hql`

```sql
USE superstore_db;

LOAD DATA LOCAL INPATH '/tmp/SampleSuperstore.csv'
OVERWRITE INTO TABLE superstore_stg;

INSERT OVERWRITE TABLE superstore
SELECT
  CAST(row_id AS INT),
  order_id,
  TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(order_date, 'M/d/yyyy'))),
  TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(ship_date, 'M/d/yyyy'))),
  ship_mode,
  customer_id,
  customer_name,
  segment,
  country,
  city,
  state,
  postal_code,
  region,
  product_id,
  category,
  sub_category,
  product_name,
  CAST(sales AS DOUBLE),
  CAST(quantity AS INT),
  CAST(discount AS DOUBLE),
  CAST(profit AS DOUBLE)
FROM superstore_stg;
```

## Evidencia de ejecución
![DDL / tablas creadas](../evidencias/p01/Screenshot%202026-11-11%20093106.png)
![Carga / describe](../evidencias/p01/Screenshot%202026-11-11%20093209.png)
![Validación de carga](../evidencias/p01/Screenshot%202026-11-11%20093634.png)
![Registros importados](../evidencias/p01/Screenshot%202026-11-11%20094029.png)

## Resultado obtenido
- Base de datos `superstore_db` creada.
- Tablas `superstore_stg` y `superstore` disponibles.
- Staging cargado con ~9994 registros; tabla analítica poblada tras el `INSERT OVERWRITE`.

## Interpretación técnica
El modelo en dos capas (staging + analítica) reduce fallos de ingesta y permite tipar fechas y métricas de forma controlada. ORC favorece consultas analíticas posteriores frente a texto plano.

## Conclusión
Se implementó un modelo Hive reproducible, con diccionario, DDL tipado y evidencia de registros importados listos para el análisis.
