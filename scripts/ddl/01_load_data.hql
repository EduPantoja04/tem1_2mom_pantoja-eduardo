USE superstore_db;

-- Opción A: LOAD desde HDFS
LOAD DATA INPATH '/user/hive/warehouse/superstore_raw/SampleSuperstore.csv'
INTO TABLE superstore_stg;

-- Opción B (local, si está permitido):
-- LOAD DATA LOCAL INPATH '/home/usuario/SampleSuperstore.csv' INTO TABLE superstore_stg;

-- Transformar a tipado (ajusta el formato de fecha si falla)
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