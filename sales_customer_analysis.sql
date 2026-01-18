CREATE DATABASE ecommerce_analytics;

-- customer--
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INT,
    customer_city TEXT,
    customer_state TEXT
);

--orders--
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

--orders items--
CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

--payment--
CREATE TABLE payments (
    order_id TEXT,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC
);

--review--
CREATE TABLE reviews (
    review_id TEXT PRIMARY KEY,
    order_id TEXT,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

--product--
CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

--seller--
CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city TEXT,
    seller_state TEXT
);

--geolocation--
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city TEXT,
    geolocation_state TEXT
);

--category translation--
CREATE TABLE category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);

--customer_csv--
COPY CUSTOMERS
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

--geolocation--
COPY geolocation
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;

--orders items--
COPY order_items
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

--payment--
COPY payments
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

--review--
COPY reviews
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;

--orders--
COPY orders
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

--product--
COPY products
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

--seller--
COPY sellers
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

--category translation--
COPY category_translation
FROM 'C:\Users\Rahul Patil\OneDrive\Desktop\olist_data\product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;


SELECT * FROM customers;
SELECT * FROM geolocation;
SELECT * FROM order_items;
SELECT * FROM payments;
SELECT * FROM reviews;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM category_translation;

--total orders--
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

--average_ordervalue--
SELECT
    SUM(payment_value) AS total_revenue,
    AVG(payment_value) AS avg_order_value
FROM payments;

--best product--
SELECT
    oi.product_id,
    SUM(oi.price) AS product_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id
ORDER BY product_revenue DESC;

--readable best product--
SELECT
    ct.product_category_name_english AS category,
    SUM(oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct 
    ON p.product_category_name = ct.product_category_name
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC;

--top seller--
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    SUM(oi.price) AS seller_revenue
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY seller_revenue DESC;

--repeat customer--
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

--operational performance--
SELECT
    AVG(
        o.order_delivered_customer_date 
        - o.order_purchase_timestamp
    ) AS avg_delivery_time
FROM orders o
WHERE o.order_status = 'delivered';









