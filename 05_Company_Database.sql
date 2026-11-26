-- ============================================================================
-- DATABASE 5: COMPANY DATABASE (JSSSTU DBMS LAB)
-- Compatible with: MariaDB / MySQL on Linux
-- Execution: sudo mariadb < company.sql
-- ============================================================================
-- PROBLEM STATEMENT:
-- Design and implement a Company Database with EMPLOYEE, DEPARTMENT,
-- DLOCATION, PROJECT, and WORKS_ON tables. Properly handle the circular
-- foreign key relationship between EMPLOYEE(DNo) and DEPARTMENT(MgrSSN).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1 & 2: DATABASE CREATION
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS company_db;
CREATE DATABASE company_db;
USE company_db;

-- ----------------------------------------------------------------------------
-- SECTION 3 & 4: TABLE CREATION & CIRCULAR FOREIGN KEY HANDLING
-- Step A: Create DEPARTMENT first WITHOUT the MgrSSN foreign key.
-- Step B: Create EMPLOYEE referencing DEPARTMENT(DNo) and EMPLOYEE(SSN).
-- Step C: Insert DEPARTMENT (with MgrSSN = NULL) and EMPLOYEE records.
-- Step D: Update DEPARTMENT.MgrSSN and ADD the foreign key via ALTER TABLE.
-- ----------------------------------------------------------------------------
CREATE TABLE DEPARTMENT (
    DNo          INT PRIMARY KEY,
    DName        VARCHAR(40) NOT NULL UNIQUE,
    MgrSSN       VARCHAR(10),
    MgrStartDate DATE
);

CREATE TABLE EMPLOYEE (
    SSN      VARCHAR(10) PRIMARY KEY,
    Name     VARCHAR(50) NOT NULL,
    Address  VARCHAR(100) DEFAULT 'Bengaluru',
    Sex      CHAR(1) CHECK (Sex IN ('M', 'F')),
    Salary   DECIMAL(10,2) NOT NULL CHECK (Salary >= 15000),
    SuperSSN VARCHAR(10),
    DNo      INT,
    FOREIGN KEY (SuperSSN) REFERENCES EMPLOYEE(SSN) ON DELETE SET NULL,
    FOREIGN KEY (DNo)      REFERENCES DEPARTMENT(DNo) ON DELETE SET NULL
);

CREATE TABLE DLOCATION (
    DNo       INT,
    DLocation VARCHAR(40),
    PRIMARY KEY (DNo, DLocation),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE PROJECT (
    PNo       INT PRIMARY KEY,
    PName     VARCHAR(50) NOT NULL UNIQUE,
    PLocation VARCHAR(40) NOT NULL,
    DNo       INT NOT NULL,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE WORKS_ON (
    SSN   VARCHAR(10),
    PNo   INT,
    Hours DECIMAL(4,1) CHECK (Hours >= 0),
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE,
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)  ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- SECTION 5: SAMPLE INSERT STATEMENTS (AT LEAST 5 RECORDS PER TABLE)
-- ----------------------------------------------------------------------------
-- Step C1: Insert Departments with MgrSSN = NULL initially
INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) VALUES
(1, 'Accounts',   NULL, '2020-01-10'),
(2, 'Research',   NULL, '2019-06-15'),
(3, 'HR',         NULL, '2021-03-01'),
(4, 'IT',         NULL, '2018-09-20'),
(5, 'Marketing',  NULL, '2022-04-12');

-- Step C2: Insert Employees (Top supervisor first so SuperSSN FK is valid)
INSERT INTO EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo) VALUES
('E01', 'Suresh Scott',  'Mysuru',    'M', 900000.00, NULL,  1),
('E02', 'Meenakshi Rao', 'Bengaluru', 'F', 850000.00, 'E01', 2),
('E03', 'Rajesh Scott',  'Mysuru',    'M', 650000.00, 'E02', 4),
('E04', 'Anitha Nair',   'Mangaluru', 'F', 620000.00, 'E01', 3),
('E05', 'Prakash Gowda', 'Bengaluru', 'M', 700000.00, 'E02', 5),
('E06', 'Divya Shetty',  'Mysuru',    'F', 550000.00, 'E03', 4);

-- Step D: Update MgrSSN in DEPARTMENT and add the circular FOREIGN KEY
UPDATE DEPARTMENT SET MgrSSN = 'E01' WHERE DNo = 1;
UPDATE DEPARTMENT SET MgrSSN = 'E02' WHERE DNo = 2;
UPDATE DEPARTMENT SET MgrSSN = 'E04' WHERE DNo = 3;
UPDATE DEPARTMENT SET MgrSSN = 'E03' WHERE DNo = 4;
UPDATE DEPARTMENT SET MgrSSN = 'E05' WHERE DNo = 5;

ALTER TABLE DEPARTMENT
ADD CONSTRAINT fk_dept_manager
FOREIGN KEY (MgrSSN) REFERENCES EMPLOYEE(SSN) ON DELETE SET NULL;

-- Insert remaining child tables
INSERT INTO DLOCATION (DNo, DLocation) VALUES
(1, 'Mysuru'),
(2, 'Bengaluru'),
(3, 'Mangaluru'),
(4, 'Bengaluru'),
(5, 'Mysuru');

INSERT INTO PROJECT (PNo, PName, PLocation, DNo) VALUES
(10, 'IoT',         'Bengaluru', 4),
(20, 'Payroll',     'Mysuru',    1),
(30, 'AI Chatbot',  'Bengaluru', 2),
(40, 'HR Portal',   'Mangaluru', 3),
(50, 'Ad Campaign', 'Mysuru',    5),
(60, 'Blockchain',  'Bengaluru', 4); -- Unassigned project for RIGHT JOIN demo

INSERT INTO WORKS_ON (SSN, PNo, Hours) VALUES
('E01', 20, 15.0),
('E02', 30, 25.0),
('E03', 10, 30.0),
('E04', 40, 20.0),
('E05', 50, 18.0),
('E06', 10, 35.0);

-- ----------------------------------------------------------------------------
-- SECTION 6: DISPLAY ALL RECORDS
-- ----------------------------------------------------------------------------
SELECT * FROM DEPARTMENT;
SELECT * FROM EMPLOYEE;
SELECT * FROM DLOCATION;
SELECT * FROM PROJECT;
SELECT * FROM WORKS_ON;

-- ----------------------------------------------------------------------------
-- SECTION 7: DDL QUERIES
-- ----------------------------------------------------------------------------
ALTER TABLE EMPLOYEE ADD COLUMN phone VARCHAR(15) DEFAULT '0000000000';
ALTER TABLE EMPLOYEE MODIFY COLUMN phone VARCHAR(20) NOT NULL DEFAULT '0000000000';
ALTER TABLE EMPLOYEE DROP COLUMN phone;

CREATE TABLE TEMP_BONUS (bonus_id INT PRIMARY KEY, amount DECIMAL(8,2));
DROP TABLE TEMP_BONUS;

CREATE DATABASE temp_company_test;
DROP DATABASE temp_company_test;
USE company_db;

-- ----------------------------------------------------------------------------
-- SECTION 8: DML QUERIES (INSERT, UPDATE, DELETE - 2+ EXAMPLES EACH)
-- ----------------------------------------------------------------------------
INSERT INTO EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo)
VALUES ('E07', 'Karan Bhat', 'Hubballi', 'M', 480000.00, 'E03', 4);
INSERT INTO PROJECT (PNo, PName, PLocation, DNo)
VALUES (70, 'Cloud Sync', 'Mysuru', 4);

UPDATE EMPLOYEE SET Salary = Salary * 1.10 WHERE SSN = 'E07';
UPDATE PROJECT SET PLocation = 'Bengaluru' WHERE PNo = 70;

DELETE FROM PROJECT WHERE PNo = 70;
DELETE FROM EMPLOYEE WHERE SSN = 'E07';

-- ----------------------------------------------------------------------------
-- SECTION 9: DQL / SELECT QUERIES
-- ----------------------------------------------------------------------------
SELECT SSN, Name, Salary FROM EMPLOYEE WHERE Salary >= 650000;
SELECT DISTINCT Address FROM EMPLOYEE;
SELECT SSN, Name FROM EMPLOYEE WHERE Name LIKE '%Scott%';
SELECT SSN, Name, Salary FROM EMPLOYEE WHERE Salary BETWEEN 600000 AND 850000;
SELECT SSN, Name, DNo FROM EMPLOYEE WHERE DNo IN (1, 2, 4);
SELECT SSN, Name, DNo FROM EMPLOYEE WHERE DNo NOT IN (1, 2);
SELECT SSN, Name FROM EMPLOYEE WHERE SuperSSN IS NULL;
SELECT SSN, Name, Salary FROM EMPLOYEE ORDER BY Salary ASC;
SELECT SSN, Name, Salary FROM EMPLOYEE ORDER BY Salary DESC;

-- ----------------------------------------------------------------------------
-- SECTION 10: SET OPERATIONS (UNION vs UNION ALL)
-- Classic JSSSTU Query: Project numbers involving an employee named 'Scott'
-- either as a worker OR as the manager of the department controlling the project.
-- ----------------------------------------------------------------------------
-- 10.1 UNION (No duplicates)
SELECT P.PNo
FROM PROJECT P
JOIN DEPARTMENT D ON P.DNo = D.DNo
JOIN EMPLOYEE E   ON D.MgrSSN = E.SSN
WHERE E.Name LIKE '%Scott%'
UNION
SELECT W.PNo
FROM WORKS_ON W
JOIN EMPLOYEE E ON W.SSN = E.SSN
WHERE E.Name LIKE '%Scott%';

-- 10.2 UNION ALL (Keeps duplicates if Scott is both manager and worker)
SELECT P.PNo
FROM PROJECT P
JOIN DEPARTMENT D ON P.DNo = D.DNo
JOIN EMPLOYEE E   ON D.MgrSSN = E.SSN
WHERE E.Name LIKE '%Scott%'
UNION ALL
SELECT W.PNo
FROM WORKS_ON W
JOIN EMPLOYEE E ON W.SSN = E.SSN
WHERE E.Name LIKE '%Scott%';

-- ----------------------------------------------------------------------------
-- SECTION 11: SUBQUERIES (Nested, Correlated, EXISTS, NOT EXISTS, IN)
-- ----------------------------------------------------------------------------
-- 11.1 Nested Query: Employees earning more than the average salary
SELECT SSN, Name, Salary
FROM EMPLOYEE
WHERE Salary > (SELECT AVG(Salary) FROM EMPLOYEE);

-- 11.2 IN with Subquery: Employees working on the 'IoT' project
SELECT SSN, Name, Salary, ROUND(Salary * 1.10, 2) AS raised_salary_10pct
FROM EMPLOYEE
WHERE SSN IN (
    SELECT W.SSN
    FROM WORKS_ON W
    JOIN PROJECT P ON W.PNo = P.PNo
    WHERE P.PName = 'IoT'
);

-- 11.3 Correlated Nested Query: Employees earning >= average salary of their own dept
SELECT E1.SSN, E1.Name, E1.DNo, E1.Salary
FROM EMPLOYEE E1
WHERE E1.Salary >= (
    SELECT AVG(E2.Salary)
    FROM EMPLOYEE E2
    WHERE E2.DNo = E1.DNo
);

-- 11.4 EXISTS: Departments that control at least one project
SELECT D.DNo, D.DName
FROM DEPARTMENT D
WHERE EXISTS (
    SELECT 1 FROM PROJECT P WHERE P.DNo = D.DNo
);

-- 11.5 NOT EXISTS: Projects that currently have NO employees assigned
SELECT P.PNo, P.PName
FROM PROJECT P
WHERE NOT EXISTS (
    SELECT 1 FROM WORKS_ON W WHERE W.PNo = P.PNo
);

-- ----------------------------------------------------------------------------
-- SECTION 12: JOIN OPERATIONS
-- ----------------------------------------------------------------------------
-- 12.1 INNER JOIN: Employees and their Department names
SELECT E.Name, D.DName, E.Salary
FROM EMPLOYEE E
INNER JOIN DEPARTMENT D ON E.DNo = D.DNo;

-- 12.2 LEFT JOIN: All employees and their supervisor's name (CEO has NULL supervisor)
SELECT E.Name AS employee, S.Name AS supervisor
FROM EMPLOYEE E
LEFT JOIN EMPLOYEE S ON E.SuperSSN = S.SSN;

-- 12.3 RIGHT JOIN: All projects including unassigned ones (Blockchain)
SELECT W.SSN, P.PNo, P.PName
FROM WORKS_ON W
RIGHT JOIN PROJECT P ON W.PNo = P.PNo;

-- 12.4 CROSS JOIN
SELECT D.DName, DL.DLocation FROM DEPARTMENT D CROSS JOIN DLOCATION DL LIMIT 10;

-- 12.5 SELF JOIN: Employee and their direct Manager/Supervisor
SELECT E.Name AS subordinate, S.Name AS supervisor
FROM EMPLOYEE E
JOIN EMPLOYEE S ON E.SuperSSN = S.SSN;

-- 12.6 Multiple-table JOIN: Employee, Department, Project, and Hours worked
SELECT E.Name, D.DName, P.PName, W.Hours
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
JOIN WORKS_ON W   ON E.SSN = W.SSN
JOIN PROJECT P    ON W.PNo = P.PNo
ORDER BY W.Hours DESC;

-- ----------------------------------------------------------------------------
-- SECTION 13: AGGREGATE FUNCTIONS
-- Classic JSSSTU Query: Sum, Max, Min, Avg salary of Accounts department
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)    AS emp_count,
    SUM(Salary) AS total_salary,
    ROUND(AVG(Salary), 2) AS avg_salary,
    MIN(Salary) AS min_salary,
    MAX(Salary) AS max_salary
FROM EMPLOYEE;

SELECT
    SUM(E.Salary) AS accounts_total_salary,
    MAX(E.Salary) AS accounts_max_salary,
    MIN(E.Salary) AS accounts_min_salary,
    AVG(E.Salary) AS accounts_avg_salary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
WHERE D.DName = 'Accounts';

-- ----------------------------------------------------------------------------
-- SECTION 14: GROUPING OPERATIONS
-- ----------------------------------------------------------------------------
-- 14.1 GROUP BY with aggregate: Employee count and avg salary per department
SELECT D.DName, COUNT(E.SSN) AS emp_count, ROUND(AVG(E.Salary), 2) AS avg_salary
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.DNo = E.DNo
GROUP BY D.DName;

-- 14.2 GROUP BY with HAVING: Departments with average salary > 650000
SELECT DNo, COUNT(*) AS emp_count, ROUND(AVG(Salary), 2) AS avg_salary
FROM EMPLOYEE
GROUP BY DNo
HAVING AVG(Salary) > 650000;

-- 14.3 GROUP BY multiple columns: Employee count by Department and Sex
SELECT DNo, Sex, COUNT(*) AS emp_count, SUM(Salary) AS total_salary
FROM EMPLOYEE
GROUP BY DNo, Sex
HAVING COUNT(*) >= 1;

-- ----------------------------------------------------------------------------
-- SECTION 15: DCL QUERIES (ADMIN-ONLY)
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'company_user'@'localhost' IDENTIFIED BY 'Company@123';
GRANT SELECT, INSERT ON company_db.* TO 'company_user'@'localhost';
SHOW GRANTS FOR 'company_user'@'localhost';
REVOKE INSERT ON company_db.* FROM 'company_user'@'localhost';
SHOW GRANTS FOR 'company_user'@'localhost';
FLUSH PRIVILEGES;
