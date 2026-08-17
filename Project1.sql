USE DATABASE CUSTOMER_SALES_DB;
USE SCHEMA SALES_SCHEMA;
CREATE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

-- Stage
CREATE STAGE SALES_STAGE
FILE_FORMAT = CSV_FORMAT;

-- TABLES
CREATE TABLE CUSTOMERS (
    customer_id NUMBER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(100)
);
CREATE TABLE FOODITEMS (
    food_id NUMBER,
    name VARCHAR(100),
    price NUMBER(10,2),
    category VARCHAR(50),
    availability VARCHAR(20)
);
CREATE TABLE ORDERS (
    order_id NUMBER,
    customer_id NUMBER,
    food_id NUMBER,
    quantity NUMBER,
    order_date TIMESTAMP,
    status VARCHAR(30),
    total_amount NUMBER(10,2)
);
---DATA LOADING 
COPY INTO CUSTOMERS
FROM @SALES_STAGE/customers.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO FOODITEMS
FROM @SALES_STAGE/fooditems.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO ORDERS
FROM @SALES_STAGE/orders.csv
FILE_FORMAT = CSV_FORMAT;

---VERIFICATION
SELECT * FROM CUSTOMERS;
SELECT * FROM FOODITEMS;
SELECT * FROM ORDERS;

---ANALYSIS
SELECT * FROM CUSTOMERS;
SELECT * FROM FOODITEMS;
SELECT * FROM ORDERS;

-- Generate a Customer-wise Sales Report showing:
-- Customer ID
-- -- Customer Name
-- Total Amount Spent
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_amount_spent
FROM CUSTOMERS c
INNER JOIN ORDERS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_amount_spent DESC;

-- Find the Highest Spending Customer.
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_amount_spent
FROM CUSTOMERS c
INNER JOIN ORDERS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_amount_spent DESC
LIMIT 1;

-- Calculate the Total Business Revenue.
SELECT SUM(total_amount) AS total_revenue
FROM ORDERS;

-- Generate a Category-wise Revenue Report.
-- The report should display:
-- Food Category
-- Total Revenue
SELECT
    f.category,
    SUM(o.total_amount) AS total_revenue
FROM ORDERS o
INNER JOIN FOODITEMS f
    ON o.food_id = f.food_id
GROUP BY f.category
ORDER BY total_revenue DESC;

-- Generate an Order Status-wise Revenue Report.
-- The report should display:
-- Order Status
-- Total Revenue
SELECT
    status AS order_status,
    SUM(total_amount) AS revenue
FROM ORDERS
GROUP BY status;

-- Display the Top Three Customers based on their total spending.
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spent
FROM CUSTOMERS c
INNER JOIN ORDERS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 3;

-- Generate a Customer Purchase Frequency Report showing:
-- Customer ID
-- Customer Name
-- Number of Orders Placed
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS orders_placed
FROM CUSTOMERS c
INNER JOIN ORDERS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY c.customer_id;

-- Display all Delivered Orders only.
SELECT *
FROM ORDERS
WHERE status = 'Delivered';

-- Display all orders placed after 12 July 2026.
SELECT *
FROM ORDERS
WHERE order_date > '2026-07-12';

-- Task 23:Create a View named CUSTOMER_SALES_REPORT containing:
-- Customer ID
-- Customer Name
-- Total Amount Spent
CREATE VIEW CUSTOMER_SALES_REPORT AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_amount_spent
FROM CUSTOMERS c
INNER JOIN ORDERS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Retrieve all records from the created View.
SELECT *
FROM CUSTOMER_SALES_REPORT;

-- Sort the View data in descending order of Total Amount Spent.
SELECT *
FROM CUSTOMER_SALES_REPORT
ORDER BY total_amount_spent DESC;