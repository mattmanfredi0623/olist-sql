-- 02_GROUP_BY: Aggregations & KPIs

-- 1) Orders delivered by state
SELECT c.customer_state,
       COUNT(*) AS orders_delivered
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY orders_delivered DESC;

-- 2) Monthly order counts (YYYY-MM)
SELECT substr(order_purchase_timestamp, 1, 7) AS month,
       COUNT(*) AS orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- 3) Average item price & freight by category
SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
       ROUND(AVG(oi.price), 2)   AS avg_item_price,
       ROUND(AVG(oi.freight_value), 2) AS avg_freight
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t
  ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY avg_item_price DESC
LIMIT 25;

-- 4) Payment type distribution
SELECT payment_type, COUNT(*) AS num_payments, ROUND(SUM(payment_value),2) AS total_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_value DESC;

-- 5) Reviews distribution (score histogram)
SELECT review_score, COUNT(*) AS reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- 6) Seller performance (gross item revenue)
SELECT s.seller_id,
       s.seller_state,
       ROUND(SUM(oi.price), 2) AS gross_item_revenue,
       COUNT(DISTINCT oi.order_id) AS orders_served
FROM order_items oi
JOIN sellers s ON s.seller_id = oi.seller_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
ORDER BY gross_item_revenue DESC
LIMIT 20;

-- 7) Delivery speed KPIs (actual vs estimated)
SELECT
  ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_approved_at)), 2) AS avg_days_ship_to_delivery,
  ROUND(AVG(julianday(order_estimated_delivery_date) - julianday(order_approved_at)), 2) AS avg_days_ship_to_estimated
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_approved_at IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- 8) Top categories by total revenue (items only)
SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
       ROUND(SUM(oi.price), 2) AS item_revenue,
       COUNT(DISTINCT oi.order_id) AS distinct_orders
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t
  ON t.product_category_name = p.product_category_name
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
HAVING item_revenue IS NOT NULL
ORDER BY item_revenue DESC
LIMIT 20;
