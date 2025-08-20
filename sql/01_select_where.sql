-- 01_SELECT_WHERE: Basic scanning & filters

-- Peek at recent orders
SELECT order_id, customer_id, order_status, order_purchase_timestamp
FROM orders
ORDER BY order_purchase_timestamp DESC
LIMIT 10;

-- Delivered orders only
SELECT order_id, order_status, order_delivered_customer_date
FROM orders
WHERE order_status = 'delivered'
ORDER BY order_delivered_customer_date DESC
LIMIT 10;

-- Customers in SP state (São Paulo) with a specific ZIP prefix range
SELECT customer_id, customer_city, customer_state, customer_zip_code_prefix
FROM customers
WHERE customer_state = 'SP'
  AND customer_zip_code_prefix BETWEEN 10000 AND 19999
LIMIT 20;

-- Orders with missing delivery date (potential delays/cancellations)
SELECT order_id, order_status, order_purchase_timestamp, order_delivered_customer_date
FROM orders
WHERE order_status <> 'delivered'
   OR order_delivered_customer_date IS NULL
ORDER BY order_purchase_timestamp DESC
LIMIT 20;

-- Items that look unusually expensive (price outliers)
SELECT order_id, order_item_id, product_id, price, freight_value
FROM order_items
WHERE price > 1000
ORDER BY price DESC
LIMIT 20;

-- Payments using credit card & installments >= 6
SELECT order_id, payment_type, payment_installments, payment_value
FROM order_payments
WHERE payment_type = 'credit_card'
  AND payment_installments >= 6
ORDER BY payment_value DESC
LIMIT 20;

-- Reviews with low scores and non-null comments
SELECT order_id, review_score, review_comment_message
FROM order_reviews
WHERE review_score <= 2
  AND review_comment_message IS NOT NULL
LIMIT 20;

-- Products with potential data quality issues (missing category)
SELECT product_id, product_category_name, product_weight_g
FROM products
WHERE product_category_name IS NULL
   OR product_category_name = ''
LIMIT 20;

-- Seller concentration by state (quick scan)
SELECT seller_id, seller_city, seller_state
FROM sellers
WHERE seller_state IN ('SP','RJ','MG','RS')
LIMIT 20;

-- Geolocation sample for ZIPs in SP
SELECT geolocation_zip_code_prefix, geolocation_city, geolocation_state, geolocation_lat, geolocation_lng
FROM geolocation
WHERE geolocation_state = 'SP'
LIMIT 20;
