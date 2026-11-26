-- ============================================================================
-- DATABASE 3: ORDER PROCESSING DATABASE (JSSSTU DBMS LAB)
-- Compatible with: MariaDB / MySQL on Linux
-- Execution: sudo mariadb < orders.sql
-- ============================================================================
-- PROBLEM STATEMENT:
-- Design and implement an Order Processing Database with CUSTOMER, ORDERS,
-- ORDER_ITEM, ITEM, SHIPMENT, and WAREHOUSE tables. (ORDERS is used instead
-- of the reserved keyword ORDER to avoid SQL syntax conflicts.)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1 & 2: DATABASE CREATION
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS order_processing_db;
CREATE DATABASE order_processing_db;
USE order_processing_db;

-- ----------------------------------------------------------------------------
-- SECTION 3 & 4: TABLE CREATION WITH PRIMARY KEYS, FOREIGN KEYS & CONSTRAINTS
-- ----------------------------------------------------------------------------
CREATE TABLE CUSTOMER (
    cust_no INT PRIMARY KEY,
    cname   VARCHAR(50) NOT NULL,
    city    VARCHAR(40) DEFAULT 'Bengaluru'
);

CREATE TABLE ORDERS (
    order_no INT PRIMARY KEY,
    odate    DATE NOT NULL,
    cust_no  INT NOT NULL,
    ord_amt  DECIMAL(10,2) CHECK (ord_amt >= 0),
    FOREIGN KEY (cust_no) REFERENCES CUSTOMER(cust_no) ON DELETE CASCADE
);

CREATE TABLE ITEM (
    item_no   INT PRIMARY KEY,
    unitprice DECIMAL(10,2) NOT NULL CHECK (unitprice > 0)
);

CREATE TABLE ORDER_ITEM (
    order_no INT,
    item_no  INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_no, item_no),
    FOREIGN KEY (order_no) REFERENCES ORDERS(order_no) ON DELETE CASCADE,
    FOREIGN KEY (item_no)  REFERENCES ITEM(item_no)    ON DELETE CASCADE
);

CREATE TABLE WAREHOUSE (
    warehouse_no INT PRIMARY KEY,
    city         VARCHAR(40) NOT NULL
);

CREATE TABLE SHIPMENT (
    order_no     INT,
    warehouse_no INT,
    ship_date    DATE,
    PRIMARY KEY (order_no, warehouse_no),
    FOREIGN KEY (order_no)     REFERENCES ORDERS(order_no)         ON DELETE CASCADE,
    FOREIGN KEY (warehouse_no) REFERENCES WAREHOUSE(warehouse_no)  ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- SECTION 5: SAMPLE INSERT STATEMENTS (AT LEAST 5 RECORDS PER TABLE)
-- ----------------------------------------------------------------------------
INSERT INTO CUSTOMER (cust_no, cname, city) VALUES
(1, 'Arjun Mehta',   'Mysuru'),
(2, 'Priya Sharma',  'Bengaluru'),
(3, 'Rohan Verma',   'Mysuru'),
(4, 'Kavya Hegde',   'Mangaluru'),
(5, 'Siddharth Rao', 'Hubballi'),
(6, 'Neha Kulkarni', NULL); -- NULL city for IS NULL & LEFT JOIN demo

INSERT INTO ITEM (item_no, unitprice) VALUES
(501, 250.00),
(502, 500.00),
(503, 1200.00),
(504, 750.00),
(505, 150.00),
(506, 999.00); -- Unordered item for RIGHT JOIN demo

INSERT INTO WAREHOUSE (warehouse_no, city) VALUES
(10, 'Mysuru'),
(20, 'Bengaluru'),
(30, 'Mangaluru'),
(40, 'Hubballi'),
(50, 'Chennai');

INSERT INTO ORDERS (order_no, odate, cust_no, ord_amt) VALUES
(1001, '2026-01-05', 1, 1250.00),
(1002, '2026-01-12', 2, 2400.00),
(1003, '2026-02-01', 1, 1500.00),
(1004, '2026-02-14', 3, 2250.00),
(1005, '2026-03-03', 4,  600.00),
(1006, '2026-03-15', 5, 3600.00);

INSERT INTO ORDER_ITEM (order_no, item_no, quantity) VALUES
(1001, 501, 5),
(1002, 503, 2),
(1003, 502, 3),
(1004, 504, 3),
(1005, 505, 4),
(1006, 503, 3);

INSERT INTO SHIPMENT (order_no, warehouse_no, ship_date) VALUES
(1001, 10, '2026-01-07'),
(1002, 20, '2026-01-14'),
(1003, 10, '2026-02-03'),
(1004, 20, '2026-02-16'),
(1005, 30, '2026-03-05');
-- Order 1006 is not shipped yet (useful for LEFT JOIN / NOT EXISTS).

-- ----------------------------------------------------------------------------
-- SECTION 6: DISPLAY ALL RECORDS
-- ----------------------------------------------------------------------------
SELECT * FROM CUSTOMER;
SELECT * FROM ITEM;
SELECT * FROM WAREHOUSE;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_ITEM;
SELECT * FROM SHIPMENT;

-- ----------------------------------------------------------------------------
-- SECTION 7: DDL QUERIES
-- ----------------------------------------------------------------------------
ALTER TABLE CUSTOMER ADD COLUMN email VARCHAR(80) UNIQUE;
ALTER TABLE CUSTOMER MODIFY COLUMN email VARCHAR(120);
ALTER TABLE CUSTOMER DROP COLUMN email;

CREATE TABLE TEMP_INVOICE (inv_no INT PRIMARY KEY, amount DECIMAL(10,2));
DROP TABLE TEMP_INVOICE;

CREATE DATABASE temp_orders_test;
DROP DATABASE temp_orders_test;
USE order_processing_db;

-- ----------------------------------------------------------------------------
-- SECTION 8: DML QUERIES (INSERT, UPDATE, DELETE - 2+ EXAMPLES EACH)
-- ----------------------------------------------------------------------------
-- 8.1 INSERT
INSERT INTO CUSTOMER (cust_no, cname, city) VALUES (7, 'Tarun Nair', 'Belagavi');
INSERT INTO ITEM (item_no, unitprice) VALUES (507, 450.00);

-- 8.2 UPDATE
UPDATE CUSTOMER SET city = 'Mysuru' WHERE cust_no = 7;
UPDATE ITEM SET unitprice = 475.00 WHERE item_no = 507;

-- 8.3 DELETE
DELETE FROM ITEM WHERE item_no = 507;
DELETE FROM CUSTOMER WHERE cust_no = 7;

-- ----------------------------------------------------------------------------
-- SECTION 9: DQL / SELECT QUERIES
-- ----------------------------------------------------------------------------
SELECT order_no, odate, ord_amt FROM ORDERS WHERE ord_amt >= 1500;
SELECT DISTINCT city FROM CUSTOMER WHERE city IS NOT NULL;
SELECT cust_no, cname FROM CUSTOMER WHERE cname LIKE '%a%';
SELECT order_no, ord_amt FROM ORDERS WHERE ord_amt BETWEEN 1000 AND 2500;
SELECT cust_no, cname, city FROM CUSTOMER WHERE city IN ('Mysuru', 'Bengaluru');
SELECT cust_no, cname, city FROM CUSTOMER WHERE city NOT IN ('Mysuru', 'Bengaluru');
SELECT cust_no, cname FROM CUSTOMER WHERE city IS NULL;
SELECT item_no, unitprice FROM ITEM ORDER BY unitprice ASC;
SELECT order_no, ord_amt FROM ORDERS ORDER BY ord_amt DESC;

-- ----------------------------------------------------------------------------
-- SECTION 10: SET OPERATIONS (UNION vs UNION ALL)
-- ----------------------------------------------------------------------------
-- 10.1 UNION: All unique cities that have either a Customer or a Warehouse
SELECT city FROM CUSTOMER WHERE city IS NOT NULL
UNION
SELECT city FROM WAREHOUSE;

-- 10.2 UNION ALL: Same list including duplicates
SELECT city FROM CUSTOMER WHERE city IS NOT NULL
UNION ALL
SELECT city FROM WAREHOUSE;

-- ----------------------------------------------------------------------------
-- SECTION 11: SUBQUERIES (Nested, Correlated, EXISTS, NOT EXISTS, IN)
-- ----------------------------------------------------------------------------
-- 11.1 Nested Query: Orders whose amount exceeds the average order amount
SELECT order_no, cust_no, ord_amt
FROM ORDERS
WHERE ord_amt > (SELECT AVG(ord_amt) FROM ORDERS);

-- 11.2 IN with Subquery: Customers who placed orders shipped from Warehouse 10
SELECT cname
FROM CUSTOMER
WHERE cust_no IN (
    SELECT O.cust_no
    FROM ORDERS O
    JOIN SHIPMENT S ON O.order_no = S.order_no
    WHERE S.warehouse_no = 10
);

-- 11.3 Correlated Nested Query: Orders higher than the average order of that customer
SELECT O1.order_no, O1.cust_no, O1.ord_amt
FROM ORDERS O1
WHERE O1.ord_amt >= (
    SELECT AVG(O2.ord_amt)
    FROM ORDERS O2
    WHERE O2.cust_no = O1.cust_no
);

-- 11.4 EXISTS: Orders that have been shipped
SELECT O.order_no, O.odate, O.ord_amt
FROM ORDERS O
WHERE EXISTS (
    SELECT 1 FROM SHIPMENT S WHERE S.order_no = O.order_no
);

-- 11.5 NOT EXISTS: Orders that have NOT been shipped yet
SELECT O.order_no, O.odate, O.ord_amt
FROM ORDERS O
WHERE NOT EXISTS (
    SELECT 1 FROM SHIPMENT S WHERE S.order_no = O.order_no
);

-- ----------------------------------------------------------------------------
-- SECTION 12: JOIN OPERATIONS
-- ----------------------------------------------------------------------------
-- 12.1 INNER JOIN: Customers and their orders
SELECT C.cname, O.order_no, O.ord_amt
FROM CUSTOMER C
INNER JOIN ORDERS O ON C.cust_no = O.cust_no;

-- 12.2 LEFT JOIN: All customers including those without orders
SELECT C.cust_no, C.cname, O.order_no
FROM CUSTOMER C
LEFT JOIN ORDERS O ON C.cust_no = O.cust_no;

-- 12.3 RIGHT JOIN: All items including unordered items (Item 506)
SELECT OI.order_no, I.item_no, I.unitprice
FROM ORDER_ITEM OI
RIGHT JOIN ITEM I ON OI.item_no = I.item_no;

-- 12.4 CROSS JOIN
SELECT C.cname, W.city AS warehouse_city
FROM CUSTOMER C
CROSS JOIN WAREHOUSE W
LIMIT 10;

-- 12.5 SELF JOIN: Pairs of different customers living in the same city
SELECT C1.cname AS customer_1, C2.cname AS customer_2, C1.city
FROM CUSTOMER C1
JOIN CUSTOMER C2 ON C1.city = C2.city AND C1.cust_no < C2.cust_no;

-- 12.6 Multiple-table JOIN: Customer, Order, Item, Quantity, Warehouse, Ship Date
SELECT C.cname, O.order_no, OI.item_no, OI.quantity, W.city AS shipped_from, S.ship_date
FROM CUSTOMER C
JOIN ORDERS O     ON C.cust_no = O.cust_no
JOIN ORDER_ITEM OI ON O.order_no = OI.order_no
JOIN SHIPMENT S   ON O.order_no = S.order_no
JOIN WAREHOUSE W  ON S.warehouse_no = W.warehouse_no
ORDER BY O.order_no;

-- ----------------------------------------------------------------------------
-- SECTION 13: AGGREGATE FUNCTIONS
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)     AS total_orders,
    SUM(ord_amt) AS total_revenue,
    ROUND(AVG(ord_amt), 2) AS avg_order_amt,
    MIN(ord_amt) AS min_order_amt,
    MAX(ord_amt) AS max_order_amt
FROM ORDERS;

-- ----------------------------------------------------------------------------
-- SECTION 14: GROUPING OPERATIONS
-- ----------------------------------------------------------------------------
-- 14.1 GROUP BY with aggregate: Number of orders and total spend per customer
SELECT C.cname, COUNT(O.order_no) AS no_of_orders, SUM(O.ord_amt) AS total_spent
FROM CUSTOMER C
JOIN ORDERS O ON C.cust_no = O.cust_no
GROUP BY C.cname;

-- 14.2 GROUP BY with HAVING: Warehouses that shipped more than 1 order
SELECT warehouse_no, COUNT(order_no) AS shipments_count
FROM SHIPMENT
GROUP BY warehouse_no
HAVING COUNT(order_no) > 1;

-- 14.3 GROUP BY multiple columns: Orders grouped by customer city and warehouse city
SELECT C.city AS cust_city, W.city AS warehouse_city, COUNT(*) AS order_count
FROM CUSTOMER C
JOIN ORDERS O    ON C.cust_no = O.cust_no
JOIN SHIPMENT S  ON O.order_no = S.order_no
JOIN WAREHOUSE W ON S.warehouse_no = W.warehouse_no
GROUP BY C.city, W.city
HAVING COUNT(*) >= 1;

-- ----------------------------------------------------------------------------
-- SECTION 15: DCL QUERIES (ADMIN-ONLY)
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'order_user'@'localhost' IDENTIFIED BY 'Order@123';
GRANT SELECT, INSERT, UPDATE ON order_processing_db.* TO 'order_user'@'localhost';
SHOW GRANTS FOR 'order_user'@'localhost';
REVOKE UPDATE ON order_processing_db.* FROM 'order_user'@'localhost';
SHOW GRANTS FOR 'order_user'@'localhost';
FLUSH PRIVILEGES;
