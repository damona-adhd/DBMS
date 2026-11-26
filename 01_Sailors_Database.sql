-- ============================================================================
-- DATABASE 1: SAILORS DATABASE (JSSSTU DBMS LAB)
-- Compatible with: MariaDB / MySQL on Linux
-- Execution: sudo mariadb < sailors.sql
-- ============================================================================
-- PROBLEM STATEMENT:
-- Design and implement a Sailors Database with SAILORS, BOAT, and RESERVES
-- tables. Enforce primary keys, foreign keys, and constraints. Populate each
-- table with at least 5 records and demonstrate DDL, DML, DQL, Set Operations,
-- Subqueries, Joins, Aggregate Functions, Grouping, and DCL commands.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1 & 2: DATABASE CREATION
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS sailors_db;
CREATE DATABASE sailors_db;
USE sailors_db;

-- ----------------------------------------------------------------------------
-- SECTION 3 & 4: TABLE CREATION WITH PRIMARY KEYS, FOREIGN KEYS & CONSTRAINTS
-- Demonstrates: CREATE TABLE, PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE,
--               CHECK, DEFAULT
-- ----------------------------------------------------------------------------
CREATE TABLE SAILORS (
    sid    INT PRIMARY KEY,
    sname  VARCHAR(50) NOT NULL,
    rating INT DEFAULT 5 CHECK (rating BETWEEN 1 AND 10),
    age    DECIMAL(4,1) CHECK (age >= 18.0)
);

CREATE TABLE BOAT (
    bid    INT PRIMARY KEY,
    bname  VARCHAR(50) NOT NULL UNIQUE,
    color  VARCHAR(20) NOT NULL
);

CREATE TABLE RESERVES (
    sid   INT,
    bid   INT,
    rdate DATE,
    PRIMARY KEY (sid, bid, rdate),
    FOREIGN KEY (sid) REFERENCES SAILORS(sid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (bid) REFERENCES BOAT(bid) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Note: Column 'rdate' stores reservation date ('date' is avoided as an
-- unquoted identifier to keep queries clean, though backticks `date` also work).

-- ----------------------------------------------------------------------------
-- SECTION 5: SAMPLE INSERT STATEMENTS (AT LEAST 5 RECORDS PER TABLE)
-- Parent tables (SAILORS, BOAT) are populated BEFORE child table (RESERVES).
-- ----------------------------------------------------------------------------
INSERT INTO SAILORS (sid, sname, rating, age) VALUES
(101, 'Aarav',   8, 25.5),
(102, 'Bhavna',  7, 32.0),
(103, 'Chirag',  9, 45.0),
(104, 'Divya',   5, 22.5),
(105, 'Eshan',  10, 38.0),
(106, 'Farah',   7, NULL);  -- NULL age included to demonstrate IS NULL

INSERT INTO BOAT (bid, bname, color) VALUES
(201, 'Interlake', 'Red'),
(202, 'Clipper',   'Green'),
(203, 'Marine',    'Blue'),
(204, 'SeaHawk',   'Red'),
(205, 'WaveRider', 'Yellow'),
(206, 'StormKing', 'Green'); -- Unreserved boat to demonstrate RIGHT JOIN

INSERT INTO RESERVES (sid, bid, rdate) VALUES
(101, 201, '2026-01-10'),
(101, 202, '2026-01-15'),
(102, 201, '2026-02-05'),
(103, 203, '2026-02-18'),
(103, 204, '2026-03-01'),
(105, 205, '2026-03-12'),
(101, 204, '2026-03-20');
-- Notice: Sailor 104 and 106 have no reservations (useful for LEFT JOIN).

-- ----------------------------------------------------------------------------
-- SECTION 6: DISPLAY ALL RECORDS
-- ----------------------------------------------------------------------------
SELECT '--- ALL SAILORS ---' AS info;
SELECT * FROM SAILORS;

SELECT '--- ALL BOATS ---' AS info;
SELECT * FROM BOAT;

SELECT '--- ALL RESERVATIONS ---' AS info;
SELECT * FROM RESERVES;

-- ----------------------------------------------------------------------------
-- SECTION 7: DDL QUERIES (ALTER TABLE, ADD, MODIFY, DROP COLUMN, DROP TABLE,
--                         DROP DATABASE)
-- ----------------------------------------------------------------------------
-- 7.1 ADD COLUMN
ALTER TABLE SAILORS ADD COLUMN city VARCHAR(30) DEFAULT 'Mysuru';

-- 7.2 MODIFY COLUMN
ALTER TABLE SAILORS MODIFY COLUMN city VARCHAR(50) NOT NULL DEFAULT 'Mysuru';

-- 7.3 DROP COLUMN
ALTER TABLE SAILORS DROP COLUMN city;

-- 7.4 DROP TABLE (demonstrated safely on a temporary table)
CREATE TABLE TEMP_SAILOR_LOG (
    log_id INT PRIMARY KEY,
    note   VARCHAR(100)
);
DROP TABLE TEMP_SAILOR_LOG;

-- 7.5 DROP DATABASE (demonstrated safely on a temporary database)
CREATE DATABASE temp_sailors_test;
DROP DATABASE temp_sailors_test;
USE sailors_db;

-- ----------------------------------------------------------------------------
-- SECTION 8: DML QUERIES (INSERT, UPDATE, DELETE - 2+ EXAMPLES EACH)
-- ----------------------------------------------------------------------------
-- 8.1 INSERT (2 examples)
INSERT INTO SAILORS (sid, sname, rating, age) VALUES (107, 'Gaurav', 6, 29.0);
INSERT INTO BOAT (bid, bname, color) VALUES (207, 'OceanStar', 'White');

-- 8.2 UPDATE (2 examples)
UPDATE SAILORS SET rating = 9 WHERE sid = 107;
UPDATE BOAT SET color = 'Silver' WHERE bid = 207;

-- 8.3 DELETE (2 examples - cleaning up the temporary test records)
DELETE FROM SAILORS WHERE sid = 107;
DELETE FROM BOAT WHERE bid = 207;

-- ----------------------------------------------------------------------------
-- SECTION 9: DQL / SELECT QUERIES
-- Covers: SELECT *, specific columns, WHERE, DISTINCT, LIKE, BETWEEN, IN,
--         NOT IN, IS NULL, ORDER BY ASC, ORDER BY DESC
-- ----------------------------------------------------------------------------
-- 9.1 SELECT specific columns with WHERE
SELECT sname, rating FROM SAILORS WHERE rating >= 8;

-- 9.2 DISTINCT
SELECT DISTINCT color FROM BOAT;

-- 9.3 LIKE (Sailors whose name starts with 'A' or ends with 'a')
SELECT sid, sname FROM SAILORS WHERE sname LIKE 'A%' OR sname LIKE '%a';

-- 9.4 BETWEEN (Sailors aged between 25 and 40)
SELECT sid, sname, age FROM SAILORS WHERE age BETWEEN 25.0 AND 40.0;

-- 9.5 IN (Boats that are Red or Green)
SELECT bid, bname, color FROM BOAT WHERE color IN ('Red', 'Green');

-- 9.6 NOT IN (Boats that are neither Red nor Green)
SELECT bid, bname, color FROM BOAT WHERE color NOT IN ('Red', 'Green');

-- 9.7 IS NULL (Sailors whose age is not recorded)
SELECT sid, sname, age FROM SAILORS WHERE age IS NULL;

-- 9.8 ORDER BY ASC
SELECT sid, sname, age FROM SAILORS ORDER BY age ASC;

-- 9.9 ORDER BY DESC
SELECT sid, sname, rating FROM SAILORS ORDER BY rating DESC, sname ASC;

-- ----------------------------------------------------------------------------
-- SECTION 10: SET OPERATIONS (UNION vs UNION ALL)
-- ----------------------------------------------------------------------------
-- 10.1 UNION: Sailors who reserved a Red boat OR a Green boat (NO duplicates)
SELECT S.sid, S.sname
FROM SAILORS S
JOIN RESERVES R ON S.sid = R.sid
JOIN BOAT B ON R.bid = B.bid
WHERE B.color = 'Red'
UNION
SELECT S.sid, S.sname
FROM SAILORS S
JOIN RESERVES R ON S.sid = R.sid
JOIN BOAT B ON R.bid = B.bid
WHERE B.color = 'Green';

-- 10.2 UNION ALL: Same query keeping duplicates (Sailor 101 appears multiple times)
SELECT S.sid, S.sname
FROM SAILORS S
JOIN RESERVES R ON S.sid = R.sid
JOIN BOAT B ON R.bid = B.bid
WHERE B.color = 'Red'
UNION ALL
SELECT S.sid, S.sname
FROM SAILORS S
JOIN RESERVES R ON S.sid = R.sid
JOIN BOAT B ON R.bid = B.bid
WHERE B.color = 'Green';

-- ----------------------------------------------------------------------------
-- SECTION 11: SUBQUERIES (Nested, Correlated, EXISTS, NOT EXISTS, IN)
-- ----------------------------------------------------------------------------
-- 11.1 Nested Query: Sailors with rating higher than the average rating
SELECT sid, sname, rating
FROM SAILORS
WHERE rating > (SELECT AVG(rating) FROM SAILORS);

-- 11.2 IN with Subquery: Names of sailors who have reserved boat 201
SELECT sname
FROM SAILORS
WHERE sid IN (SELECT sid FROM RESERVES WHERE bid = 201);

-- 11.3 Correlated Nested Query: Sailors whose rating is above the average
--      rating of sailors older than 25
SELECT S1.sid, S1.sname, S1.rating
FROM SAILORS S1
WHERE S1.rating >= (
    SELECT AVG(S2.rating)
    FROM SAILORS S2
    WHERE S2.age IS NOT NULL AND S2.age <= S1.age
);

-- 11.4 EXISTS: Sailors who have made at least one reservation
SELECT S.sid, S.sname
FROM SAILORS S
WHERE EXISTS (
    SELECT 1 FROM RESERVES R WHERE R.sid = S.sid
);

-- 11.5 NOT EXISTS: Sailors who have NEVER reserved any boat
SELECT S.sid, S.sname
FROM SAILORS S
WHERE NOT EXISTS (
    SELECT 1 FROM RESERVES R WHERE R.sid = S.sid
);

-- ----------------------------------------------------------------------------
-- SECTION 12: JOIN OPERATIONS
-- Covers: INNER, LEFT, RIGHT, CROSS, SELF, Multiple-table JOIN
-- ----------------------------------------------------------------------------
-- 12.1 INNER JOIN: Sailors and their reserved boat IDs
SELECT S.sid, S.sname, R.bid, R.rdate
FROM SAILORS S
INNER JOIN RESERVES R ON S.sid = R.sid;

-- 12.2 LEFT JOIN: All sailors, including those with NO reservations
SELECT S.sid, S.sname, R.bid, R.rdate
FROM SAILORS S
LEFT JOIN RESERVES R ON S.sid = R.sid;

-- 12.3 RIGHT JOIN: All boats, including those NEVER reserved
SELECT R.sid, B.bid, B.bname, B.color
FROM RESERVES R
RIGHT JOIN BOAT B ON R.bid = B.bid;

-- 12.4 CROSS JOIN: Every sailor paired with every boat (Cartesian product)
SELECT S.sname, B.bname
FROM SAILORS S
CROSS JOIN BOAT B
LIMIT 10;

-- 12.5 SELF JOIN: Pairs of different sailors who have the exact same rating
SELECT S1.sname AS sailor_1, S2.sname AS sailor_2, S1.rating
FROM SAILORS S1
JOIN SAILORS S2 ON S1.rating = S2.rating AND S1.sid < S2.sid;

-- 12.6 Multiple-table JOIN: Sailor name, boat name, color, and reservation date
SELECT S.sname, B.bname, B.color, R.rdate
FROM SAILORS S
INNER JOIN RESERVES R ON S.sid = R.sid
INNER JOIN BOAT B ON R.bid = B.bid
ORDER BY R.rdate;

-- ----------------------------------------------------------------------------
-- SECTION 13: AGGREGATE FUNCTIONS (COUNT, SUM, AVG, MIN, MAX)
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)    AS total_sailors,
    COUNT(age)  AS sailors_with_known_age,
    SUM(rating) AS total_rating_points,
    ROUND(AVG(age), 2) AS average_age,
    MIN(age)    AS youngest_age,
    MAX(age)    AS oldest_age
FROM SAILORS;

-- ----------------------------------------------------------------------------
-- SECTION 14: GROUPING OPERATIONS (GROUP BY, Multiple Columns, HAVING)
-- ----------------------------------------------------------------------------
-- 14.1 GROUP BY with aggregate function: Count of reservations per sailor
SELECT sid, COUNT(bid) AS total_reservations
FROM RESERVES
GROUP BY sid;

-- 14.2 GROUP BY with HAVING: Ratings having more than 1 sailor
SELECT rating, COUNT(*) AS sailor_count, ROUND(AVG(age), 1) AS avg_age
FROM SAILORS
GROUP BY rating
HAVING COUNT(*) > 1;

-- 14.3 GROUP BY with multiple columns: Reservations grouped by boat color and sailor
SELECT B.color, S.sname, COUNT(*) AS times_reserved
FROM RESERVES R
JOIN SAILORS S ON R.sid = S.sid
JOIN BOAT B ON R.bid = B.bid
GROUP BY B.color, S.sname
HAVING COUNT(*) >= 1
ORDER BY times_reserved DESC;

-- ----------------------------------------------------------------------------
-- SECTION 15: DCL QUERIES (ADMIN-ONLY: RUN AS ROOT / sudo mariadb)
-- Demonstrates: CREATE USER, GRANT, SHOW GRANTS, REVOKE
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'sailor_user'@'localhost' IDENTIFIED BY 'Sailor@123';
GRANT SELECT, INSERT ON sailors_db.* TO 'sailor_user'@'localhost';
SHOW GRANTS FOR 'sailor_user'@'localhost';
REVOKE INSERT ON sailors_db.* FROM 'sailor_user'@'localhost';
SHOW GRANTS FOR 'sailor_user'@'localhost';
FLUSH PRIVILEGES;
