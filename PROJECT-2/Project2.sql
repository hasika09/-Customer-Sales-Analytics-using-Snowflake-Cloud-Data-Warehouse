/*Problem Statement:
-----------------
A nationwide retail chain has expanded its operations across multiple
cities and now receives daily sales data from all its branches. 
To improve reporting and decision-making, the company has migrated its data to the Snowflake Cloud Data Warehouse.

Every day, the company receives four CSV files containing customer details, product information, branch information, and sales transactions. The data engineering team must load these files into Snowflake, while the business intelligence team needs analytical reports to identify top-performing products, branches, and customers.

Your task is to build the Snowflake environment, load the data, and generate business reports that help management understand sales trends and customer purchasing behavior.

Project Objectives:
---------------------
After completing this project, students will be able to:

Load multiple datasets into Snowflake.
Perform multi-table joins.
Use aggregate functions.
Apply Window Functions.
Use Common Table Expressions (CTEs).
Create Views and Materialized Views.
Generate business intelligence reports.

Input Files:
------------
The company provides the following CSV files:

customers.csv
products.csv
branches.csv
sales.csv


customers.csv
--------------
customer_id,customer_name,city,membership
1,Amit,Hyderabad,Gold
2,Priya,Bengaluru,Silver
3,Rahul,Chennai,Gold
4,Neha,Pune,Silver
5,Arjun,Delhi,Platinum


products.csv
------------
product_id,product_name,category,price
101,Laptop,Electronics,60000
102,Mobile,Electronics,25000
103,Headphones,Accessories,3000
104,Keyboard,Accessories,1500
105,Monitor,Electronics,12000


branches.csv
-------------
branch_id,branch_name,city
1,Hyderabad Branch,Hyderabad
2,Bengaluru Branch,Bengaluru
3,Delhi Branch,Delhi


sales.csv
----------
sale_id,customer_id,product_id,branch_id,quantity,sale_date,total_amount
1,1,101,1,1,2026-07-01,60000
2,2,102,2,2,2026-07-02,50000
3,3,103,2,3,2026-07-03,9000
4,4,104,1,5,2026-07-04,7500
5,5,105,3,2,2026-07-05,24000
6,1,102,1,1,2026-07-06,25000
7,2,105,2,1,2026-07-07,12000
8,3,101,3,1,2026-07-08,60000
9,4,103,1,2,2026-07-09,6000
10,5,102,3,1,2026-07-10,25000
11,1,104,1,4,2026-07-11,6000
12,2,103,2,2,2026-07-12,6000


Your Tasks:
-----------
Phase-1: Snowflake Environment
-------------------------------
Create a Warehouse named RETAIL_WH.
Create a Database named RETAIL_DB.
Create a Schema named SALES_SCHEMA.
Create a CSV File Format.
Create an Internal Stage.


Phase-2: Data Loading
----------------------
Upload all four CSV files.
Create the required tables.
Load the data using COPY INTO.
Verify the imported records.

Phase-3: SQL Analytics
-------------------------
Display all customers.
Display all products.
Display all branches.
Display all sales transactions.
Calculate total business revenue.
Generate customer-wise sales.
Generate branch-wise sales.
Generate product-wise sales.
Generate category-wise sales.
Display the highest revenue branch.
Display the highest spending customer.
Display the top three products by revenue.
Display the top three customers by spending.


Phase-4: Window Functions
---------------------------
Rank customers based on total spending.
Rank branches based on total sales.
Display the top-selling product in each category using ROW_NUMBER().
Calculate cumulative sales using SUM() OVER().
Calculate the average sale amount using AVG() OVER().


Phase-5: CTE
--------------
Generate customer-wise revenue using a Common Table Expression (CTE).
Display customers whose spending is greater than the average spending.


Phase-6: Views
-----------------
Create a View named SALES_REPORT.
Create a Materialized View named TOP_CUSTOMERS.
Query both views.



Expected Outputs:
-------------
You should generate the following reports:
All Customers
All Products
All Branches
Customer-wise Sales Report
Branch-wise Revenue Report
Product-wise Revenue Report
Category-wise Revenue Report
Highest Revenue Branch
Highest Spending Customer
Top Three Products
Top Three Customers
Customer Ranking
Branch Ranking
Top Product in Each Category
Cumulative Sales Report
Average Sales Report
Customers Spending Above Average
Sales Report View
Materialized View Report



*/


USE WAREHOUSE RETAIL_WH;
USE DATABASE RETAIL_DB;
USE SCHEMA SALES_SCHEMA;

CREATE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

CREATE STAGE RETAIL_STAGE
FILE_FORMAT = CSV_FORMAT;

CREATE TABLE CUSTOMERS (
    customer_id NUMBER,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    membership VARCHAR(30)
);
CREATE TABLE PRODUCTS (
    product_id NUMBER,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMBER(10,2)
);

CREATE TABLE BRANCHES (
    branch_id NUMBER,
    branch_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE SALES (
    sale_id NUMBER,
    customer_id NUMBER,
    product_id NUMBER,
    branch_id NUMBER,
    quantity NUMBER,
    sale_date DATE,
    total_amount NUMBER(12,2)
);

COPY INTO CUSTOMERS
FROM @RETAIL_STAGE/customers1.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO PRODUCTS
FROM @RETAIL_STAGE/products.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO BRANCHES
FROM @RETAIL_STAGE/branches.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO SALES
FROM @RETAIL_STAGE/sales.csv
FILE_FORMAT = CSV_FORMAT;

SELECT * FROM CUSTOMERS;
SELECT * FROM PRODUCTS;
SELECT * FROM BRANCHES;
SELECT * FROM SALES;

SELECT
    SUM(total_amount) AS total_business_revenue
FROM SALES;

SELECT
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_amount_spent
FROM CUSTOMERS c
INNER JOIN SALES s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_amount_spent DESC;


SELECT
    b.branch_id,
    b.branch_name,
    SUM(s.total_amount) AS total_revenue
FROM BRANCHES b
INNER JOIN SALES s
    ON b.branch_id = s.branch_id
GROUP BY
    b.branch_id,
    b.branch_name
ORDER BY total_revenue DESC;

SELECT
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_quantity_sold,
    SUM(s.total_amount) AS total_revenue
FROM PRODUCTS p
INNER JOIN SALES s
    ON p.product_id = s.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC;

SELECT
    p.category,
    SUM(s.total_amount) AS total_revenue
FROM PRODUCTS p
INNER JOIN SALES s
    ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

SELECT
    b.branch_id,
    b.branch_name,
    SUM(s.total_amount) AS total_revenue
FROM BRANCHES b
INNER JOIN SALES s
    ON b.branch_id = s.branch_id
GROUP BY
    b.branch_id,
    b.branch_name
ORDER BY total_revenue DESC
LIMIT 1;

SELECT
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_spending
FROM CUSTOMERS c
INNER JOIN SALES s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spending DESC
LIMIT 1;

SELECT
    p.product_id,
    p.product_name,
    SUM(s.total_amount) AS total_revenue
FROM PRODUCTS p
INNER JOIN SALES s
    ON p.product_id = s.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 3;


SELECT
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_spending
FROM CUSTOMERS c
INNER JOIN SALES s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spending DESC
LIMIT 3;

-- 1. Rank customers based on total spending
SELECT
    customer_id,
    total_spending,
    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS customer_rank
FROM (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spending
    FROM sales
    GROUP BY customer_id
) t;


-- 2. Rank branches based on total sales
SELECT
    branch_id,
    total_sales,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS branch_rank
FROM (
    SELECT
        branch_id,
        SUM(total_amount) AS total_sales
    FROM sales
    GROUP BY branch_id
) t;


-- 3. Top-selling product in each category using ROW_NUMBER()
SELECT
    category,
    product_id,
    product_name,
    revenue
FROM (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(s.total_amount) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY SUM(s.total_amount) DESC
        ) AS rn
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
) t
WHERE rn = 1;


-- 4. Cumulative sales using SUM() OVER()
SELECT
    sale_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY sale_date
    ) AS cumulative_sales
FROM sales
ORDER BY sale_date;


-- 5. Average sale amount using AVG() OVER()
SELECT
    sale_id,
    sale_date,
    total_amount,
    AVG(total_amount) OVER () AS average_sale_amount
FROM sales
ORDER BY sale_date;

-- Generate Customer-wise Revenue Using CTE
WITH CUSTOMER_REVENUE AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS total_revenue
    FROM CUSTOMERS c
    INNER JOIN SALES s
        ON c.customer_id = s.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT *
FROM CUSTOMER_REVENUE
ORDER BY total_revenue DESC;

-- Display Customers Whose Spending is Greater
-- Than Average Spending

WITH CUSTOMER_REVENUE AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS total_spending
    FROM CUSTOMERS c
    INNER JOIN SALES s
        ON c.customer_id = s.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
),

AVERAGE_SPENDING AS
(
    SELECT
        AVG(total_spending) AS average_spending
    FROM CUSTOMER_REVENUE
)

SELECT
    cr.customer_id,
    cr.customer_name,
    cr.total_spending
FROM CUSTOMER_REVENUE cr
CROSS JOIN AVERAGE_SPENDING a
WHERE cr.total_spending > a.average_spending
ORDER BY cr.total_spending DESC;

-- Create View named SALES_REPORT
CREATE OR REPLACE VIEW SALES_REPORT AS

SELECT
    s.sale_id,
    s.sale_date,

    c.customer_id,
    c.customer_name,

    p.product_id,
    p.product_name,
    p.category,

    b.branch_id,
    b.branch_name,

    s.quantity,
    s.total_amount

FROM SALES s

INNER JOIN CUSTOMERS c
    ON s.customer_id = c.customer_id

INNER JOIN PRODUCTS p
    ON s.product_id = p.product_id

INNER JOIN BRANCHES b
    ON s.branch_id = b.branch_id;


-- Retrieve all records from SALES_REPORT View
SELECT *
FROM SALES_REPORT;

-- Sort SALES_REPORT by Total Amount
SELECT *
FROM SALES_REPORT
ORDER BY total_amount DESC;

-- Create Materialized View named TOP_CUSTOMERS
CREATE OR REPLACE VIEW TOP_CUSTOMERS AS

SELECT
    customer_id,
    SUM(total_amount) AS total_spending
FROM SALES
GROUP BY customer_id;

-- Query TOP_CUSTOMERS Materialized View
SELECT
    tc.customer_id,
    c.customer_name,
    tc.total_spending
FROM TOP_CUSTOMERS tc
INNER JOIN CUSTOMERS c
    ON tc.customer_id = c.customer_id
ORDER BY tc.total_spending DESC;