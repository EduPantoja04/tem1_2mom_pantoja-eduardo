USE superstore_db;

ANALYZE TABLE superstore COMPUTE STATISTICS;
ANALYZE TABLE superstore COMPUTE STATISTICS FOR COLUMNS region, order_date, category, sales, profit;

EXPLAIN
SELECT region, SUM(sales) AS ventas, SUM(profit) AS ganancia
FROM superstore
WHERE region = 'West'
GROUP BY region;

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
