/*
--PHASE-1
CREATE WAREHOUSE IF NOT EXISTS ENTERPRISE_WHPROJECT-3:Enterprise Incremental Sales Data Warehouse using Snowflake
----------
Problem Statement:
-------------------
A multinational retail company has already migrated its operational databases to the Snowflake Cloud Data Warehouse. Initially, the company performed a complete data migration and generated analytical reports for business users.

As the business expanded, new sales transactions started arriving every hour from multiple regional branches. Reloading the complete historical data every time became inefficient and increased processing time.

The data engineering team has been assigned to develop an Incremental Data Warehouse Pipeline capable of loading only newly arrived records while preserving historical data.

To improve warehouse reliability, the company also wants to maintain an audit trail, recover accidentally deleted data, create testing environments without duplicating storage, and automate daily data loading.

Your task is to implement the required Snowflake objects and generate analytical reports using the newly loaded data.

Project Objectives
--------------------
After completing this project, students will be able to 
Perform Incremental Data Loading
Use Snowflake Streams
Automate loading using Tasks
Recover historical data using Time Travel
Create Zero Copy Clones
Validate newly arrived records
Maintain Audit Logs
Generate analytical reports.

Input Files
------------
customers.csv
---------------
customer_id,customer_name,city,membership
1,Amit,Hyderabad,Gold
2,Priya,Bangalore,Silver
3,Rahul,Chennai,Gold
4,Neha,Pune,Silver
5,Arjun,Delhi,Platinum


products.csv
-------------
product_id,product_name,category,price
101,Laptop,Electronics,60000
102,Mobile,Electronics,25000
103,Keyboard,Accessories,1500
104,Mouse,Accessories,800
105,Monitor,Electronics,12000

branches.csv
------------
branch_id,branch_name,state
1,Hyderabad Branch,Telangana
2,Bangalore Branch,Karnataka
3,Delhi Branch,Delhi

sales_history.csv
------------------
sale_id,customer_id,product_id,branch_id,quantity,sale_date,total_amount
1,1,101,1,1,2026-07-01,60000
2,2,102,2,2,2026-07-02,50000
3,3,103,2,2,2026-07-03,3000
4,4,104,1,5,2026-07-04,4000
5,5,105,3,2,2026-07-05,24000


new_sales.csv
---------------
sale_id,customer_id,product_id,branch_id,quantity,sale_date,total_amount
6,1,102,1,1,2026-07-06,25000
7,2,105,2,1,2026-07-07,12000
8,3,101,3,1,2026-07-08,60000
9,4,103,1,2,2026-07-09,3000
10,5,102,3,1,2026-07-10,25000

your Tasks:
--------------
Phase-1 : Snowflake Environment
-------------------------------
1.Create Warehouse ENTERPRISE_WH
2.Create Database ENTERPRISE_DB
3.Create Schema SALES_SCHEMA
4.Create CSV File Format
5.Create Internal Stage

Phase-2 : Data Loading
-------------------------
6.Upload all CSV files.
7.Create all required tables.
8.Load sales_history.csv into SALES table.
9.Verify the loaded records.

Phase-3 : Incremental Loading
--------------------------------
10.Create a Stream on the SALES table.
11.Load new_sales.csv.
12.Display only newly inserted records using the Stream.
13.Merge newly arrived records into the SALES table.


Phase-4 : Data Validation
-------------------------
14.Identify duplicate Sale IDs.
15.Identify missing Customer IDs.
16.Display invalid Product IDs.
17.Count total newly inserted records.

Phase-5 : Time Travel
---------------------
18.Delete one sales record.
19.Recover the deleted record using Time Travel.
20.Verify recovery.


Phase-6 : Zero Copy Clone
-------------------------
21.Create a clone named: SALES_TEST
22.Display cloned records.
23.Insert one new record into the clone.
24.Verify that the original SALES table remains unchanged.

Phase-7 : Task Automation
-------------------------
25.Create a Task that automatically performs incremental loading every day.
26.Resume the Task.
27.Verify Task execution.


Phase-8 : Business Analytics
-----------------------------
Generate
28.Customer Revenue Report
29.Branch Revenue Report
30.Product Revenue Report
31.Monthly Revenue Report
32.Highest Revenue Customer
33.Highest Revenue Branch
34.Top Five Products
35.Customer Purchase Frequency
36.Running Revenue
37.Customer Ranking

Phase-9 : Views
----------------
38.Create View: CUSTOMER_REVENUE
39.Create Materialized View: BRANCH_REVENUE
40.Display data from both Views.


Expected Outputs
--------------------

Output-1:Customers Loaded Successfully

Output-2:Products Loaded Successfully

Output-3:Historical Sales Loaded

Output-4:New Sales Captured by Stream

Output-5:Incremental Load Completed

Output-6:Duplicate Record Report

Output-7:Missing Customer Report

Output-8:Recovered Records using Time Travel

Output-9:Clone Created Successfully

Output-10:Original Table Unchanged After Clone Modification

Output-11:Customer Revenue Report

Output-12:Branch Revenue Report

Output-13:Monthly Revenue Report

Output-14:Top Five Customers

Output-15:Top Five Products

Output-16:Customer Ranking

Output-17:Running Revenue

Output-18:Materialized View Output


Snowflake Concepts Covered:
----------------------------
Snowflake Administration:
-------------------------
Warehouse
Database
Schema
Stage
File Format

Data Engineering
----------------
COPY INTO
MERGE
Streams
Tasks
Time Travel
Zero Copy Clone

SQL Analytics:
-------------
JOIN
GROUP BY
HAVING
ORDER BY
CTE
Window Functions
Ranking

Snowflake Objects
-----------------
Views
Materialized Views
*/
CREATE WAREHOUSE IF NOT EXISTS ENTERPRISE_WH
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS ENTERPRISE_DB;

CREATE SCHEMA IF NOT EXISTS ENTERPRISE_DB.SALES_SCHEMA;

USE WAREHOUSE ENTERPRISE_WH;

USE DATABASE ENTERPRISE_DB;

USE SCHEMA SALES_SCHEMA;

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
NULL_IF = ('NULL', 'null');

CREATE OR REPLACE STAGE SALES_STAGE
FILE_FORMAT = CSV_FORMAT;

LIST @SALES_STAGE;



--PHASE2
CREATE OR REPLACE TABLE CUSTOMERS
(
    CUSTOMER_ID NUMBER,
    CUSTOMER_NAME VARCHAR,
    CITY VARCHAR,
    MEMBERSHIP VARCHAR
);

CREATE OR REPLACE TABLE PRODUCTS
(
    PRODUCT_ID NUMBER,
    PRODUCT_NAME VARCHAR,
    CATEGORY VARCHAR,
    PRICE NUMBER(12,2)
);

CREATE OR REPLACE TABLE BRANCHES
(
    BRANCH_ID NUMBER,
    BRANCH_NAME VARCHAR,
    STATE VARCHAR
);

CREATE OR REPLACE TABLE SALES
(
    SALE_ID NUMBER,
    CUSTOMER_ID NUMBER,
    PRODUCT_ID NUMBER,
    BRANCH_ID NUMBER,
    QUANTITY NUMBER,
    SALE_DATE DATE,
    TOTAL_AMOUNT NUMBER(12,2)
);

CREATE OR REPLACE TABLE NEW_SALES_STAGE
(
    SALE_ID NUMBER,
    CUSTOMER_ID NUMBER,
    PRODUCT_ID NUMBER,
    BRANCH_ID NUMBER,
    QUANTITY NUMBER,
    SALE_DATE DATE,
    TOTAL_AMOUNT NUMBER(12,2)
);

COPY INTO CUSTOMERS
FROM @SALES_STAGE/customers.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

SELECT * FROM CUSTOMERS
ORDER BY CUSTOMER_ID;

COPY INTO PRODUCTS
FROM @SALES_STAGE/products.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

SELECT * FROM PRODUCTS
ORDER BY PRODUCT_ID;

COPY INTO BRANCHES
FROM @SALES_STAGE/branches.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

SELECT * FROM BRANCHES
ORDER BY BRANCH_ID;

COPY INTO SALES
FROM @SALES_STAGE/sales_history.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

SELECT * FROM SALES
ORDER BY SALE_ID;

SELECT COUNT(*) AS HISTORICAL_SALES_COUNT
FROM SALES;



--PHASE-3
CREATE OR REPLACE STREAM SALES_STREAM
ON TABLE SALES;

COPY INTO NEW_SALES_STAGE
FROM @SALES_STAGE/new_sales.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

SELECT *
FROM NEW_SALES_STAGE
ORDER BY SALE_ID;

INSERT INTO SALES
(
    SALE_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    BRANCH_ID,
    QUANTITY,
    SALE_DATE,
    TOTAL_AMOUNT
)
SELECT
    SALE_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    BRANCH_ID,
    QUANTITY,
    SALE_DATE,
    TOTAL_AMOUNT
FROM NEW_SALES_STAGE;

SELECT
    SALE_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    BRANCH_ID,
    QUANTITY,
    SALE_DATE,
    TOTAL_AMOUNT,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM SALES_STREAM
WHERE METADATA$ACTION = 'INSERT'
ORDER BY SALE_ID;

MERGE INTO SALES AS TARGET
USING
(
    SELECT
        SALE_ID,
        CUSTOMER_ID,
        PRODUCT_ID,
        BRANCH_ID,
        QUANTITY,
        SALE_DATE,
        TOTAL_AMOUNT
    FROM NEW_SALES_STAGE
) AS SOURCE
ON TARGET.SALE_ID = SOURCE.SALE_ID

WHEN NOT MATCHED THEN

INSERT
(
    SALE_ID,
    CUSTOMER_ID,
    PRODUCT_ID,
    BRANCH_ID,
    QUANTITY,
    SALE_DATE,
    TOTAL_AMOUNT
)

VALUES
(
    SOURCE.SALE_ID,
    SOURCE.CUSTOMER_ID,
    SOURCE.PRODUCT_ID,
    SOURCE.BRANCH_ID,
    SOURCE.QUANTITY,
    SOURCE.SALE_DATE,
    SOURCE.TOTAL_AMOUNT
);

SELECT *
FROM SALES
ORDER BY SALE_ID;



--PHASE-4
SELECT
    SALE_ID,
    COUNT(*) AS DUPLICATE_COUNT
FROM SALES
GROUP BY SALE_ID
HAVING COUNT(*) > 1
ORDER BY SALE_ID;

SELECT
    S.SALE_ID,
    S.CUSTOMER_ID
FROM SALES S
LEFT JOIN CUSTOMERS C
    ON S.CUSTOMER_ID = C.CUSTOMER_ID
WHERE C.CUSTOMER_ID IS NULL
ORDER BY S.SALE_ID;

SELECT
    S.SALE_ID,
    S.PRODUCT_ID
FROM SALES S
LEFT JOIN PRODUCTS P
    ON S.PRODUCT_ID = P.PRODUCT_ID
WHERE P.PRODUCT_ID IS NULL
ORDER BY S.SALE_ID;

SELECT
    S.SALE_ID,
    S.BRANCH_ID
FROM SALES S
LEFT JOIN BRANCHES B
    ON S.BRANCH_ID = B.BRANCH_ID
WHERE B.BRANCH_ID IS NULL
ORDER BY S.SALE_ID;

SELECT COUNT(*) AS TOTAL_NEW_RECORDS
FROM NEW_SALES_STAGE;




--PHASE-5
DELETE FROM SALES
WHERE SALE_ID = 9;

SELECT *
FROM SALES
WHERE SALE_ID = 9;

SELECT *
FROM SALES
AT (OFFSET => -180)
WHERE SALE_ID = 9;


INSERT INTO SALES
SELECT *
FROM SALES
AT (OFFSET => -180)
WHERE SALE_ID = 9;

SELECT *
FROM SALES
WHERE SALE_ID = 9;

--PHASE-6
CREATE OR REPLACE TABLE SALES_TEST
CLONE SALES;

SELECT *
FROM SALES_TEST
ORDER BY SALE_ID;

INSERT INTO SALES_TEST
VALUES (
    11,
    1,
    103,
    1,
    3,
    '2026-07-11',
    4500
);


SELECT *
FROM SALES_TEST
ORDER BY SALE_ID;

SELECT *
FROM SALES
ORDER BY SALE_ID;

CREATE OR REPLACE TASK DAILY_INCREMENTAL_LOAD
WAREHOUSE = ENTERPRISE_WH
SCHEDULE = 'USING CRON 0 1 * * * UTC'
AS
MERGE INTO SALES AS TARGET
USING NEW_SALES_STAGE AS SOURCE
ON TARGET.SALE_ID = SOURCE.SALE_ID

WHEN MATCHED THEN
    UPDATE SET
        TARGET.CUSTOMER_ID = SOURCE.CUSTOMER_ID,
        TARGET.PRODUCT_ID = SOURCE.PRODUCT_ID,
        TARGET.BRANCH_ID = SOURCE.BRANCH_ID,
        TARGET.QUANTITY = SOURCE.QUANTITY,
        TARGET.SALE_DATE = SOURCE.SALE_DATE,
        TARGET.TOTAL_AMOUNT = SOURCE.TOTAL_AMOUNT

WHEN NOT MATCHED THEN
    INSERT (
        SALE_ID,
        CUSTOMER_ID,
        PRODUCT_ID,
        BRANCH_ID,
        QUANTITY,
        SALE_DATE,
        TOTAL_AMOUNT
    )
    VALUES (
        SOURCE.SALE_ID,
        SOURCE.CUSTOMER_ID,
        SOURCE.PRODUCT_ID,
        SOURCE.BRANCH_ID,
        SOURCE.QUANTITY,
        SOURCE.SALE_DATE,
        SOURCE.TOTAL_AMOUNT
    );

ALTER TASK DAILY_INCREMENTAL_LOAD
RESUME;

SHOW TASKS;

SELECT *
FROM TABLE(
    INFORMATION_SCHEMA.TASK_HISTORY(
        TASK_NAME => 'DAILY_INCREMENTAL_LOAD'
    )
);

SELECT
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES s
JOIN CUSTOMERS c
    ON s.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME
ORDER BY TOTAL_REVENUE DESC;

SELECT
    b.BRANCH_ID,
    b.BRANCH_NAME,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES s
JOIN BRANCHES b
    ON s.BRANCH_ID = b.BRANCH_ID
GROUP BY
    b.BRANCH_ID,
    b.BRANCH_NAME
ORDER BY TOTAL_REVENUE DESC;

SELECT
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    p.CATEGORY,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES s
JOIN PRODUCTS p
    ON s.PRODUCT_ID = p.PRODUCT_ID
GROUP BY
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    p.CATEGORY
ORDER BY TOTAL_REVENUE DESC;

SELECT
    DATE_TRUNC('MONTH', SALE_DATE) AS MONTH,
    SUM(TOTAL_AMOUNT) AS MONTHLY_REVENUE
FROM SALES
GROUP BY DATE_TRUNC('MONTH', SALE_DATE)
ORDER BY MONTH;

SELECT
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES s
JOIN CUSTOMERS c
    ON s.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 1;

SELECT
    b.BRANCH_ID,
    b.BRANCH_NAME,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES s
JOIN BRANCHES b
    ON s.BRANCH_ID = b.BRANCH_ID
GROUP BY
    b.BRANCH_ID,
    b.BRANCH_NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 1;

SELECT
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES s
JOIN PRODUCTS p
    ON s.PRODUCT_ID = p.PRODUCT_ID
GROUP BY
    p.PRODUCT_ID,
    p.PRODUCT_NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 5;


SELECT
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    COUNT(s.SALE_ID) AS PURCHASE_FREQUENCY
FROM CUSTOMERS c
JOIN SALES s
    ON c.CUSTOMER_ID = s.CUSTOMER_ID
GROUP BY
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME
ORDER BY PURCHASE_FREQUENCY DESC;

SELECT
    SALE_DATE,
    SALE_ID,
    TOTAL_AMOUNT,
    SUM(TOTAL_AMOUNT) OVER (
        ORDER BY SALE_DATE, SALE_ID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RUNNING_REVENUE
FROM SALES
ORDER BY SALE_DATE, SALE_ID;


SELECT
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE,

    RANK() OVER (
        ORDER BY SUM(s.TOTAL_AMOUNT) DESC
    ) AS CUSTOMER_RANK

FROM SALES s
JOIN CUSTOMERS c
    ON s.CUSTOMER_ID = c.CUSTOMER_ID

GROUP BY
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME

ORDER BY CUSTOMER_RANK;


CREATE OR REPLACE VIEW CUSTOMER_REVENUE AS
SELECT
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    SUM(s.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES s
JOIN CUSTOMERS c
    ON s.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME;


SELECT *
FROM CUSTOMER_REVENUE
ORDER BY TOTAL_REVENUE DESC;

CREATE OR REPLACE MATERIALIZED VIEW BRANCH_REVENUE AS
SELECT
    BRANCH_ID,
    SUM(TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM SALES
GROUP BY BRANCH_ID;


SELECT *
FROM BRANCH_REVENUE;

SELECT
    br.BRANCH_ID,
    b.BRANCH_NAME,
    br.TOTAL_REVENUE
FROM BRANCH_REVENUE br
JOIN BRANCHES b
    ON br.BRANCH_ID = b.BRANCH_ID
ORDER BY br.TOTAL_REVENUE DESC;
