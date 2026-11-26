-- ============================================================================
-- DATABASE 2: INSURANCE DATABASE (JSSSTU DBMS LAB)
-- Compatible with: MariaDB / MySQL on Linux
-- Execution: sudo mariadb < insurance.sql
-- ============================================================================
-- PROBLEM STATEMENT:
-- Design and implement an Insurance Database with PERSON, CAR, ACCIDENT,
-- OWNS, and PARTICIPATED tables. Enforce primary keys, foreign keys, and
-- constraints. Populate each table with at least 5 records and demonstrate
-- all syllabus SQL topics.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1 & 2: DATABASE CREATION
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS insurance_db;
CREATE DATABASE insurance_db;
USE insurance_db;

-- ----------------------------------------------------------------------------
-- SECTION 3 & 4: TABLE CREATION WITH PRIMARY KEYS, FOREIGN KEYS & CONSTRAINTS
-- ----------------------------------------------------------------------------
CREATE TABLE PERSON (
    driver_id VARCHAR(10) PRIMARY KEY,
    name      VARCHAR(50) NOT NULL,
    address   VARCHAR(100) DEFAULT 'Mysuru'
);

CREATE TABLE CAR (
    regno VARCHAR(15) PRIMARY KEY,
    model VARCHAR(30) NOT NULL,
    year  INT CHECK (year >= 1990 AND year <= 2030)
);

CREATE TABLE ACCIDENT (
    report_number INT PRIMARY KEY,
    acc_date      DATE NOT NULL,
    location      VARCHAR(60) NOT NULL
);

CREATE TABLE OWNS (
    driver_id VARCHAR(10),
    regno     VARCHAR(15),
    PRIMARY KEY (driver_id, regno),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (regno)     REFERENCES CAR(regno)        ON DELETE CASCADE
);

CREATE TABLE PARTICIPATED (
    driver_id     VARCHAR(10),
    regno         VARCHAR(15),
    report_number INT,
    damage_amount DECIMAL(10,2) CHECK (damage_amount >= 0),
    PRIMARY KEY (driver_id, regno, report_number),
    FOREIGN KEY (driver_id)     REFERENCES PERSON(driver_id)       ON DELETE CASCADE,
    FOREIGN KEY (regno)         REFERENCES CAR(regno)              ON DELETE CASCADE,
    FOREIGN KEY (report_number) REFERENCES ACCIDENT(report_number) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- SECTION 5: SAMPLE INSERT STATEMENTS (AT LEAST 5 RECORDS PER TABLE)
-- ----------------------------------------------------------------------------
INSERT INTO PERSON (driver_id, name, address) VALUES
('D01', 'Ramesh Kumar',  'Saraswathipuram, Mysuru'),
('D02', 'Sneha Rao',     'Kuvempunagar, Mysuru'),
('D03', 'Vikram Shetty', 'Vijayanagar, Mysuru'),
('D04', 'Ananya Nair',   'Indiranagar, Bengaluru'),
('D05', 'Kiran Gowda',   'Jayanagar, Mysuru'),
('D06', 'Meera Joshi',   NULL); -- NULL address to demonstrate IS NULL

INSERT INTO CAR (regno, model, year) VALUES
('KA09AB1001', 'Swift',   2020),
('KA09AB1002', 'Baleno',  2021),
('KA09AB1003', 'Creta',   2022),
('KA01CD2004', 'Nexon',   2023),
('KA09AB1005', 'Innova',  2019),
('KA09AB1006', 'i20',     2024); -- No accident record (for LEFT/RIGHT JOIN)

INSERT INTO ACCIDENT (report_number, acc_date, location) VALUES
(11, '2025-01-14', 'Ring Road, Mysuru'),
(12, '2025-03-22', 'Bannimantap, Mysuru'),
(13, '2025-06-10', 'MG Road, Bengaluru'),
(14, '2025-09-05', 'Hunsur Road, Mysuru'),
(15, '2026-01-19', 'Bogadi Road, Mysuru');

INSERT INTO OWNS (driver_id, regno) VALUES
('D01', 'KA09AB1001'),
('D02', 'KA09AB1002'),
('D03', 'KA09AB1003'),
('D04', 'KA01CD2004'),
('D05', 'KA09AB1005'),
('D01', 'KA09AB1006');

INSERT INTO PARTICIPATED (driver_id, regno, report_number, damage_amount) VALUES
('D01', 'KA09AB1001', 11, 15000.00),
('D02', 'KA09AB1002', 12, 25000.00),
('D03', 'KA09AB1003', 13, 40000.00),
('D04', 'KA01CD2004', 14, 18000.00),
('D05', 'KA09AB1005', 15, 32000.00),
('D01', 'KA09AB1001', 15, 12000.00);

-- ----------------------------------------------------------------------------
-- SECTION 6: DISPLAY ALL RECORDS
-- ----------------------------------------------------------------------------
SELECT * FROM PERSON;
SELECT * FROM CAR;
SELECT * FROM ACCIDENT;
SELECT * FROM OWNS;
SELECT * FROM PARTICIPATED;

-- ----------------------------------------------------------------------------
-- SECTION 7: DDL QUERIES
-- ----------------------------------------------------------------------------
-- 7.1 ADD COLUMN with UNIQUE constraint
ALTER TABLE PERSON ADD COLUMN license_no VARCHAR(20) UNIQUE;

-- 7.2 MODIFY COLUMN
ALTER TABLE PERSON MODIFY COLUMN license_no VARCHAR(30) DEFAULT 'PENDING';

-- 7.3 DROP COLUMN
ALTER TABLE PERSON DROP COLUMN license_no;

-- 7.4 DROP TABLE (on temporary demo table)
CREATE TABLE TEMP_CLAIM (claim_id INT PRIMARY KEY, status VARCHAR(20));
DROP TABLE TEMP_CLAIM;

-- 7.5 DROP DATABASE (on temporary demo database)
CREATE DATABASE temp_insurance_test;
DROP DATABASE temp_insurance_test;
USE insurance_db;

-- ----------------------------------------------------------------------------
-- SECTION 8: DML QUERIES (INSERT, UPDATE, DELETE - 2+ EXAMPLES EACH)
-- ----------------------------------------------------------------------------
-- 8.1 INSERT
INSERT INTO PERSON (driver_id, name, address) VALUES ('D07', 'Nikhil Verma', 'Hebbal, Mysuru');
INSERT INTO CAR (regno, model, year) VALUES ('KA09XY9999', 'Punch', 2024);

-- 8.2 UPDATE
UPDATE PARTICIPATED SET damage_amount = 20000.00 WHERE report_number = 11 AND regno = 'KA09AB1001';
UPDATE PERSON SET address = 'Gokulam, Mysuru' WHERE driver_id = 'D07';

-- 8.3 DELETE
DELETE FROM CAR WHERE regno = 'KA09XY9999';
DELETE FROM PERSON WHERE driver_id = 'D07';

-- ----------------------------------------------------------------------------
-- SECTION 9: DQL / SELECT QUERIES
-- ----------------------------------------------------------------------------
-- 9.1 Specific columns + WHERE
SELECT regno, model, year FROM CAR WHERE year >= 2021;

-- 9.2 DISTINCT
SELECT DISTINCT location FROM ACCIDENT;

-- 9.3 LIKE (Drivers living in Mysuru)
SELECT driver_id, name, address FROM PERSON WHERE address LIKE '%Mysuru%';

-- 9.4 BETWEEN (Accidents with damage between 15000 and 35000)
SELECT driver_id, regno, damage_amount FROM PARTICIPATED WHERE damage_amount BETWEEN 15000 AND 35000;

-- 9.5 IN
SELECT regno, model FROM CAR WHERE model IN ('Swift', 'Creta', 'Innova');

-- 9.6 NOT IN
SELECT regno, model FROM CAR WHERE model NOT IN ('Swift', 'Creta');

-- 9.7 IS NULL
SELECT driver_id, name FROM PERSON WHERE address IS NULL;

-- 9.8 ORDER BY ASC
SELECT report_number, acc_date, location FROM ACCIDENT ORDER BY acc_date ASC;

-- 9.9 ORDER BY DESC
SELECT driver_id, regno, damage_amount FROM PARTICIPATED ORDER BY damage_amount DESC;

-- ----------------------------------------------------------------------------
-- SECTION 10: SET OPERATIONS (UNION vs UNION ALL)
-- ----------------------------------------------------------------------------
-- 10.1 UNION: Drivers who own a car OR participated in an accident (unique list)
SELECT driver_id FROM OWNS
UNION
SELECT driver_id FROM PARTICIPATED;

-- 10.2 UNION ALL: Same query retaining duplicates
SELECT driver_id FROM OWNS
UNION ALL
SELECT driver_id FROM PARTICIPATED;

-- ----------------------------------------------------------------------------
-- SECTION 11: SUBQUERIES (Nested, Correlated, EXISTS, NOT EXISTS, IN)
-- ----------------------------------------------------------------------------
-- 11.1 Nested Query: Accidents with damage greater than average damage
SELECT report_number, driver_id, damage_amount
FROM PARTICIPATED
WHERE damage_amount > (SELECT AVG(damage_amount) FROM PARTICIPATED);

-- 11.2 IN with Subquery: Names of drivers who were in accidents in 2026
SELECT name
FROM PERSON
WHERE driver_id IN (
    SELECT P.driver_id
    FROM PARTICIPATED P
    JOIN ACCIDENT A ON P.report_number = A.report_number
    WHERE YEAR(A.acc_date) = 2026
);

-- 11.3 Correlated Nested Query: Cars whose damage exceeds the average damage
--      for that specific driver
SELECT P1.driver_id, P1.regno, P1.damage_amount
FROM PARTICIPATED P1
WHERE P1.damage_amount >= (
    SELECT AVG(P2.damage_amount)
    FROM PARTICIPATED P2
    WHERE P2.driver_id = P1.driver_id
);

-- 11.4 EXISTS: Drivers who have participated in at least one accident
SELECT P.driver_id, P.name
FROM PERSON P
WHERE EXISTS (
    SELECT 1 FROM PARTICIPATED PT WHERE PT.driver_id = P.driver_id
);

-- 11.5 NOT EXISTS: Drivers who have NEVER participated in an accident
SELECT P.driver_id, P.name
FROM PERSON P
WHERE NOT EXISTS (
    SELECT 1 FROM PARTICIPATED PT WHERE PT.driver_id = P.driver_id
);

-- ----------------------------------------------------------------------------
-- SECTION 12: JOIN OPERATIONS
-- ----------------------------------------------------------------------------
-- 12.1 INNER JOIN: Driver names and their owned car registration numbers
SELECT P.name, O.regno
FROM PERSON P
INNER JOIN OWNS O ON P.driver_id = O.driver_id;

-- 12.2 LEFT JOIN: All persons and any cars they own (includes Meera Joshi with NULL)
SELECT P.driver_id, P.name, O.regno
FROM PERSON P
LEFT JOIN OWNS O ON P.driver_id = O.driver_id;

-- 12.3 RIGHT JOIN: All cars and any accidents they participated in (includes KA09AB1006)
SELECT PT.report_number, C.regno, C.model
FROM PARTICIPATED PT
RIGHT JOIN CAR C ON PT.regno = C.regno;

-- 12.4 CROSS JOIN
SELECT P.name, C.model FROM PERSON P CROSS JOIN CAR C LIMIT 10;

-- 12.5 SELF JOIN: Pairs of different drivers involved in the same accident report
SELECT P1.driver_id AS driver_1, P2.driver_id AS driver_2, P1.report_number
FROM PARTICIPATED P1
JOIN PARTICIPATED P2
  ON P1.report_number = P2.report_number AND P1.driver_id < P2.driver_id;

-- 12.6 Multiple-table JOIN: Full accident report details
SELECT P.name, C.model, A.acc_date, A.location, PT.damage_amount
FROM PARTICIPATED PT
JOIN PERSON P   ON PT.driver_id = P.driver_id
JOIN CAR C      ON PT.regno = C.regno
JOIN ACCIDENT A ON PT.report_number = A.report_number
ORDER BY A.acc_date;

-- ----------------------------------------------------------------------------
-- SECTION 13: AGGREGATE FUNCTIONS
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)           AS total_participations,
    SUM(damage_amount) AS total_damage,
    ROUND(AVG(damage_amount), 2) AS avg_damage,
    MIN(damage_amount) AS min_damage,
    MAX(damage_amount) AS max_damage
FROM PARTICIPATED;

-- ----------------------------------------------------------------------------
-- SECTION 14: GROUPING OPERATIONS (GROUP BY, Multiple Columns, HAVING)
-- ----------------------------------------------------------------------------
-- 14.1 GROUP BY with aggregate: Total damage per driver
SELECT driver_id, COUNT(*) AS accident_count, SUM(damage_amount) AS total_damage
FROM PARTICIPATED
GROUP BY driver_id;

-- 14.2 GROUP BY with HAVING: Drivers with total damage > 25000
SELECT driver_id, SUM(damage_amount) AS total_damage
FROM PARTICIPATED
GROUP BY driver_id
HAVING SUM(damage_amount) > 25000;

-- 14.3 GROUP BY multiple columns: Accidents by year and location
SELECT YEAR(A.acc_date) AS acc_year, A.location, COUNT(*) AS vehicles_involved
FROM ACCIDENT A
JOIN PARTICIPATED PT ON A.report_number = PT.report_number
GROUP BY YEAR(A.acc_date), A.location
HAVING COUNT(*) >= 1;

-- ----------------------------------------------------------------------------
-- SECTION 15: DCL QUERIES (ADMIN-ONLY)
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'insurance_user'@'localhost' IDENTIFIED BY 'Insure@123';
GRANT SELECT, UPDATE ON insurance_db.* TO 'insurance_user'@'localhost';
SHOW GRANTS FOR 'insurance_user'@'localhost';
REVOKE UPDATE ON insurance_db.* FROM 'insurance_user'@'localhost';
SHOW GRANTS FOR 'insurance_user'@'localhost';
FLUSH PRIVILEGES;
