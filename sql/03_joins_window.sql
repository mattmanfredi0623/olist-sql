-- 03_JOINS_WINDOW: Multi-table joins & analytic (window) functions

-- INNER JOIN: orders → customers (recent delivered)
SELECT o.order_id,
       o.order_purchase_timestamp,
       c.customer_state
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
ORDER BY o.order_purchase_timestamp DESC
LIMIT 20;

-- LEFT JOIN: customers with/without delivered orders (lifetime spend from items)
WITH item_totals AS (
  SELECT order_id, SUM(price + freight_value) AS order_total
  FROM order_items
  GROUP BY order_id
)
SELECT c.customer_id,
       c.customer_state,
       COALESCE(SUM(it.order_total), 0) AS lifetime_spend
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.order_status = 'delivered'
LEFT JOIN item_totals it ON it.order_id = o.order_id
GROUP BY c.customer_id, c.customer_state
ORDER BY lifetime_spend DESC
LIMIT 20;

-- Three-way JOIN: items -> orders -> products (top 20 expensive line items)
SELECT oi.order_id, oi.order_item_id, p.product_category_name, oi.price, oi.freight_value
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'delivered'
ORDER BY oi.price DESC
LIMIT 20;

-- Window: Monthly revenue per customer with ranking
WITH month_spend AS (
  SELECT c.customer_id,
         substr(o.order_purchase_timestamp, 1, 7) AS month,
         SUM(oi.price + oi.freight_value) AS monthly_spend
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_id, month
)
SELECT customer_id,
       month,
       monthly_spend,
       RANK() OVER (PARTITION BY month ORDER BY monthly_spend DESC) AS rnk_in_month
FROM month_spend
WHERE monthly_spend IS NOT NULL
ORDER BY month, rnk_in_month
LIMIT 100;

-- Window: Running cumulative revenue by month
WITH month_rev AS (
  SELECT substr(order_purchase_timestamp, 1, 7) AS month,
         SUM(oi.price + oi.freight_value) AS revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY month
)
SELECT month,
       revenue,
       SUM(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue
FROM month_rev
ORDER BY month;

-- Window: Percent of total sales by category (using window SUM)
WITH cat_rev AS (
  SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
         SUM(oi.price) AS revenue
  FROM order_items oi
  JOIN products p ON p.product_id = oi.product_id
  LEFT JOIN product_category_name_translation t
    ON t.product_category_name = p.product_category_name
  JOIN orders o ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY category
)
SELECT category,
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total
FROM cat_rev
ORDER BY revenue DESC
LIMIT 25;
