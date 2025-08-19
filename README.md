# Olist Brazilian E-commerce — SQL Portfolio (SQLite + VS Code)

This project analyzes the **Olist Brazilian E-commerce dataset** using **SQLite** inside **VS Code**.  

It demonstrates skills in **SQL querying (SELECT, WHERE, GROUP BY, JOIN, window functions)**, database schema design, and portfolio documentation.  

The dataset contains **100k+ orders across 9 related tables** (customers, orders, items, payments, reviews, products, sellers, geolocation, category translations).

---

## Dataset
- **Source:** [Olist Brazilian E-commerce (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Tables used:**  
  `customers`, `orders`, `order_items`, `order_payments`, `order_reviews`,  
  `products`, `sellers`, `geolocation`, `product_category_name_translation`
- Data is not included in this repo (to keep it small). Download from Kaggle and place CSVs into the `data/` folder.

---

## Repo Structure

```text
olist-sql/
├─ data/                         # Kaggle CSVs (ignored in git)
├─ db/
│  └─ olist.db                   # local SQLite database (ignored in git)
├─ sql/
│  ├─ schema.sql                 # CREATE TABLE + indexes
│  ├─ 01_select_where.sql        # basic scans & filters
│  ├─ 02_group_by.sql            # aggregations & KPIs
│  └─ 03_joins_window.sql        # joins + window functions
└─ README.md
```

---

## Quickstart

### 1) Create the database
```text
sqlite3 db/olist.db < sql/schema.sql
```

### 2) Import the CSVs inside sqlite3
```text
.mode csv
.headers on

.import data/olist_customers_dataset.csv customers
.import data/olist_orders_dataset.csv orders
.import data/olist_order_items_dataset.csv order_items
.import data/olist_order_payments_dataset.csv order_payments
.import data/olist_order_reviews_dataset.csv order_reviews
.import data/olist_products_dataset.csv products
.import data/olist_sellers_dataset.csv sellers
.import data/olist_geolocation_dataset.csv geolocation
.import data/product_category_name_translation.csv product_category_name_translation
```

### 3) Sanity checks
```text
SELECT COUNT (*) AS customers FROM customers;
SELECT COUNT (*) AS orders FROM orders;
SELECT COUNT (*) AS order_items FROM order_items;
```

### 4) Run queries in VS Code
- Install SQLite (alexcvzz) extension.
- Open db/olist.db to browse tables.
- Open files in sql/ and run queries (highlight + "Run Query").

### Insights
- **Top categories by revenue:** Electronics and bed/bath/table account for a large share of delivered order revenue.
- **Monthly revenue trend:** Strong growth in holiday months; consistent YoY patterns.
- **Delivery speed:** Average actual delivery is ~12 days vs ~10 days estimated.
- **Reviews:** Categories with longer shipping times tend to have lower review scores.
- **Geography:** São Paulo (SP) contributes the majority of orders.

### Notes
- **Dates are stored as `TEXT`.** Use:
  - `substr(order_purchase_timestamp, 1, 7)` → YYYY-MM
  - `julianday(date1) - julianday(date2)` → date differences (days)
- **After imports** (optional pragmas):
~~~sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
~~~

# License
MIT License. Data © Olist, available publicly on Kaggle for educational use.
