# Diccionario de datos — Sample Superstore

Fuente: `data/Sample - Superstore.csv`  
Formato de fechas en origen: `M/d/yyyy` (ejemplo: `11/8/2016`)  
`Discount` se representa como proporción (ejemplo: `0.45` = 45%).

| # | Campo (CSV) | Nombre sugerido Hive | Tipo Hive | Descripción | Restricciones / observaciones |
|---|-------------|----------------------|-----------|-------------|-------------------------------|
| 1 | Row ID | `row_id` | `INT` | Identificador único de cada fila del dataset. | Debe ser único y no nulo. Clave candidata de fila. |
| 2 | Order ID | `order_id` | `STRING` | Identificador de la orden de compra (puede repetirse en varias líneas). | No nulo. Formato típico: `CA-2016-152156` / `US-2015-108966`. |
| 3 | Order Date | `order_date` | `DATE` | Fecha en que se realizó el pedido. | No nula. Parsear desde `M/d/yyyy`. Debe ser ≤ `ship_date`. |
| 4 | Ship Date | `ship_date` | `DATE` | Fecha de envío del pedido. | No nula. Parsear desde `M/d/yyyy`. Debe ser ≥ `order_date`. |
| 5 | Ship Mode | `ship_mode` | `STRING` | Modalidad de envío. | Dominio esperado: `Standard Class`, `Second Class`, `First Class`, `Same Day`. |
| 6 | Customer ID | `customer_id` | `STRING` | Identificador del cliente. | No nulo. Formato típico: `CG-12520`. |
| 7 | Customer Name | `customer_name` | `STRING` | Nombre completo del cliente. | No nulo. |
| 8 | Segment | `segment` | `STRING` | Segmento de mercado del cliente. | Dominio esperado: `Consumer`, `Corporate`, `Home Office`. |
| 9 | Country | `country` | `STRING` | País de la ubicación del pedido. | En este dataset suele ser `United States`. |
| 10 | City | `city` | `STRING` | Ciudad de la ubicación del pedido. | No nulo. |
| 11 | State | `state` | `STRING` | Estado de la ubicación del pedido. | No nulo. |
| 12 | Postal Code | `postal_code` | `STRING` | Código postal. | Se recomienda `STRING` para preservar ceros a la izquierda. |
| 13 | Region | `region` | `STRING` | Región comercial. | Dominio esperado: `East`, `West`, `Central`, `South`. |
| 14 | Product ID | `product_id` | `STRING` | Identificador del producto. | No nulo. Formato típico: `FUR-BO-10001798`. |
| 15 | Category | `category` | `STRING` | Categoría del producto. | Dominio esperado: `Furniture`, `Office Supplies`, `Technology`. |
| 16 | Sub-Category | `sub_category` | `STRING` | Subcategoría del producto. | No nulo. Ejemplos: `Bookcases`, `Chairs`, `Labels`, `Tables`. |
| 17 | Product Name | `product_name` | `STRING` | Nombre descriptivo del producto. | Puede contener comas; el CSV usa comillas. |
| 18 | Sales | `sales` | `DOUBLE` | Monto de ventas de la línea. | Esperado `> 0`. Valores ≤ 0 se consideran inconsistentes. |
| 19 | Quantity | `quantity` | `INT` | Cantidad de unidades vendidas. | Entero positivo (`> 0`). |
| 20 | Discount | `discount` | `DOUBLE` | Descuento aplicado como proporción. | Intervalo esperado: `[0, 1]`. Ejemplo: `0.20` = 20%. |
| 21 | Profit | `profit` | `DOUBLE` | Ganancia (o pérdida) de la línea. | Puede ser negativa. Relacionada con ventas y descuento. |

## Notas de modelado

- Granularidad: **una fila = una línea de detalle de orden** (producto dentro de una orden).
- Relación lógica: un `order_id` puede tener muchas filas; un `customer_id` puede tener muchas órdenes.
- Para la tabla staging en Hive conviene cargar primero todo como `STRING` y castear a tipos definitivos en la tabla analítica.
- Campos con mayor riesgo de inconsistencia en auditoría: fechas (`order_date` / `ship_date`), `sales`, `discount` y `profit`.
