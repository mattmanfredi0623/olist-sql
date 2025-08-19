-- OLIST BRAZILIAN E‑COMMERCE (SQLite) SCHEMA
-- Run inside sqlite3

-- speed up large CSV imports
PRAGMA journal_mode = OFF;
PRAGMA synchronous = OFF;
PRAGMA temp_store = MEMORY;


-- TABLES


DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  customer_id TEXT PRIMARY KEY,
  customer_unique_id TEXT,
  customer_zip_code_prefix INTEGER,
  customer_city TEXT,
  customer_state TEXT
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  order_id TEXT PRIMARY KEY,
  customer_id TEXT,
  order_status TEXT,
  order_purchase_timestamp TEXT,
  order_approved_at TEXT,
  order_delivered_carrier_date TEXT,
  order_delivered_customer_date TEXT,
  order_estimated_delivery_date TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
  order_id TEXT,
  order_item_id INTEGER,
  product_id TEXT,
  seller_id TEXT,
  shipping_limit_date TEXT,
  price REAL,
  freight_value REAL,
  PRIMARY KEY (order_id, order_item_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

DROP TABLE IF EXISTS order_payments;
CREATE TABLE order_payments (
  order_id TEXT,
  payment_sequential INTEGER,
  payment_type TEXT,
  payment_installments INTEGER,
  payment_value REAL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

DROP TABLE IF EXISTS order_reviews;
CREATE TABLE order_reviews (
  review_id TEXT PRIMARY KEY,
  order_id TEXT,
  review_score INTEGER,
  review_comment_title TEXT,
  review_comment_message TEXT,
  review_creation_date TEXT,
  review_answer_timestamp TEXT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  product_id TEXT PRIMARY KEY,
  product_category_name TEXT,
  product_name_length INTEGER,
  product_description_length INTEGER,
  product_photos_qty INTEGER,
  product_weight_g INTEGER,
  product_length_cm INTEGER,
  product_height_cm INTEGER,
  product_width_cm INTEGER
);

DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
  seller_id TEXT PRIMARY KEY,
  seller_zip_code_prefix INTEGER,
  seller_city TEXT,
  seller_state TEXT
);

DROP TABLE IF EXISTS geolocation;
CREATE TABLE geolocation (
  geolocation_zip_code_prefix INTEGER,
  geolocation_lat REAL,
  geolocation_lng REAL,
  geolocation_city TEXT,
  geolocation_state TEXT
);

DROP TABLE IF EXISTS product_category_name_translation;
CREATE TABLE product_category_name_translation (
  product_category_name TEXT,
  product_category_name_english TEXT
);


-- INDEXES

CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_seller ON order_items(seller_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON order_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_reviews_order ON order_reviews(order_id);
CREATE INDEX IF NOT EXISTS idx_products_cat ON products(product_category_name);
CREATE INDEX IF NOT EXISTS idx_customers_state ON customers(customer_state);
CREATE INDEX IF NOT EXISTS idx_sellers_state ON sellers(seller_state);

-- revert pragmas after import
-- PRAGMA journal_mode = WAL;
-- PRAGMA synchronous = NORMAL;
