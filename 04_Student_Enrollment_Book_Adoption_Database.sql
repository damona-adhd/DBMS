-- ============================================================================
-- DATABASE 4: STUDENT ENROLLMENT & BOOK ADOPTION DATABASE (JSSSTU DBMS LAB)
-- Compatible with: MariaDB / MySQL on Linux
-- Execution: sudo mariadb < student.sql
-- ============================================================================
-- PROBLEM STATEMENT:
-- Design and implement a Student Enrollment and Book Adoption Database with
-- STUDENT, COURSE, ENROLL, BOOK_ADOPTION, and TEXT tables.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1 & 2: DATABASE CREATION
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS student_enrollment_db;
CREATE DATABASE student_enrollment_db;
USE student_enrollment_db;

-- ----------------------------------------------------------------------------
-- SECTION 3 & 4: TABLE CREATION WITH PRIMARY KEYS, FOREIGN KEYS & CONSTRAINTS
-- ----------------------------------------------------------------------------
CREATE TABLE STUDENT (
    regno VARCHAR(15) PRIMARY KEY,
    name  VARCHAR(50) NOT NULL,
    major VARCHAR(30) DEFAULT 'CS',
    bdate DATE
);

CREATE TABLE COURSE (
    course_no INT PRIMARY KEY,
    cname     VARCHAR(60) NOT NULL UNIQUE,
    dept      VARCHAR(30) NOT NULL
);

CREATE TABLE TEXT (
    book_ISBN  INT PRIMARY KEY,
    book_title VARCHAR(80) NOT NULL,
    publisher  VARCHAR(50) NOT NULL,
    author     VARCHAR(50) NOT NULL
);

CREATE TABLE ENROLL (
    regno     VARCHAR(15),
    course_no INT,
    sem       INT CHECK (sem BETWEEN 1 AND 8),
    marks     INT CHECK (marks BETWEEN 0 AND 100),
    PRIMARY KEY (regno, course_no, sem),
    FOREIGN KEY (regno)     REFERENCES STUDENT(regno)     ON DELETE CASCADE,
    FOREIGN KEY (course_no) REFERENCES COURSE(course_no)  ON DELETE CASCADE
);

CREATE TABLE BOOK_ADOPTION (
    course_no INT,
    sem       INT CHECK (sem BETWEEN 1 AND 8),
    book_ISBN INT,
    PRIMARY KEY (course_no, sem, book_ISBN),
    FOREIGN KEY (course_no) REFERENCES COURSE(course_no) ON DELETE CASCADE,
    FOREIGN KEY (book_ISBN) REFERENCES TEXT(book_ISBN)   ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- SECTION 5: SAMPLE INSERT STATEMENTS (AT LEAST 5 RECORDS PER TABLE)
-- ----------------------------------------------------------------------------
INSERT INTO STUDENT (regno, name, major, bdate) VALUES
('01JST23CS001', 'Aditi Rao',     'CS', '2005-04-12'),
('01JST23CS002', 'Bharat Kumar',  'CS', '2005-07-23'),
('01JST23IS003', 'Chetan Gowda',  'IS', '2004-11-05'),
('01JST23EC004', 'Deepika Nair',  'EC', '2005-02-18'),
('01JST23CS005', 'Eshwar Shetty', 'CS', '2005-09-30'),
('01JST23IS006', 'Fatima Begum',  'IS', NULL); -- NULL bdate & un-enrolled demo

INSERT INTO COURSE (course_no, cname, dept) VALUES
(101, 'Database Management Systems', 'CS'),
(102, 'Operating Systems',           'CS'),
(103, 'Data Structures',             'IS'),
(104, 'Digital Electronics',         'EC'),
(105, 'Computer Networks',           'CS'),
(106, 'Cloud Computing',             'IS'); -- No enrollments yet (RIGHT JOIN demo)

INSERT INTO TEXT (book_ISBN, book_title, publisher, author) VALUES
(9001, 'Fundamentals of Database Systems', 'Pearson',     'Elmasri & Navathe'),
(9002, 'Database System Concepts',         'McGraw-Hill', 'Silberschatz'),
(9003, 'Operating System Concepts',        'Wiley',       'Galvin'),
(9004, 'Data Structures Using C',          'Oxford',      'Reema Thareja'),
(9005, 'Digital Design',                   'Pearson',     'Morris Mano'),
(9006, 'Computer Networking',              'Pearson',     'Kurose & Ross');

INSERT INTO ENROLL (regno, course_no, sem, marks) VALUES
('01JST23CS001', 101, 4, 92),
('01JST23CS001', 102, 4, 85),
('01JST23CS002', 101, 4, 78),
('01JST23IS003', 103, 3, 88),
('01JST23EC004', 104, 3, 74),
('01JST23CS005', 105, 5, 95);

INSERT INTO BOOK_ADOPTION (course_no, sem, book_ISBN) VALUES
(101, 4, 9001),
(101, 4, 9002),
(102, 4, 9003),
(103, 3, 9004),
(104, 3, 9005),
(105, 5, 9006);

-- ----------------------------------------------------------------------------
-- SECTION 6: DISPLAY ALL RECORDS
-- ----------------------------------------------------------------------------
SELECT * FROM STUDENT;
SELECT * FROM COURSE;
SELECT * FROM TEXT;
SELECT * FROM ENROLL;
SELECT * FROM BOOK_ADOPTION;

-- ----------------------------------------------------------------------------
-- SECTION 7: DDL QUERIES
-- ----------------------------------------------------------------------------
ALTER TABLE STUDENT ADD COLUMN cgpa DECIMAL(3,2) DEFAULT 0.00;
ALTER TABLE STUDENT MODIFY COLUMN cgpa DECIMAL(4,2) NOT NULL DEFAULT 0.00;
ALTER TABLE STUDENT DROP COLUMN cgpa;

CREATE TABLE TEMP_LIBRARY_CARD (card_id INT PRIMARY KEY, regno VARCHAR(15));
DROP TABLE TEMP_LIBRARY_CARD;

CREATE DATABASE temp_student_test;
DROP DATABASE temp_student_test;
USE student_enrollment_db;

-- ----------------------------------------------------------------------------
-- SECTION 8: DML QUERIES (INSERT, UPDATE, DELETE - 2+ EXAMPLES EACH)
-- ----------------------------------------------------------------------------
INSERT INTO STUDENT (regno, name, major, bdate) VALUES ('01JST23CS007', 'Ganesh Pai', 'CS', '2005-01-15');
INSERT INTO TEXT (book_ISBN, book_title, publisher, author) VALUES (9007, 'SQL Pocket Guide', 'OReilly', 'Alice Zhao');

UPDATE STUDENT SET major = 'IS' WHERE regno = '01JST23CS007';
UPDATE TEXT SET publisher = 'O-Reilly Media' WHERE book_ISBN = 9007;

DELETE FROM TEXT WHERE book_ISBN = 9007;
DELETE FROM STUDENT WHERE regno = '01JST23CS007';

-- ----------------------------------------------------------------------------
-- SECTION 9: DQL / SELECT QUERIES
-- ----------------------------------------------------------------------------
SELECT regno, name, major FROM STUDENT WHERE major = 'CS';
SELECT DISTINCT publisher FROM TEXT;
SELECT book_ISBN, book_title FROM TEXT WHERE book_title LIKE '%Database%';
SELECT regno, course_no, marks FROM ENROLL WHERE marks BETWEEN 80 AND 95;
SELECT course_no, cname, dept FROM COURSE WHERE dept IN ('CS', 'IS');
SELECT course_no, cname, dept FROM COURSE WHERE dept NOT IN ('CS');
SELECT regno, name FROM STUDENT WHERE bdate IS NULL;
SELECT regno, name, bdate FROM STUDENT ORDER BY name ASC;
SELECT regno, course_no, marks FROM ENROLL ORDER BY marks DESC;

-- ----------------------------------------------------------------------------
-- SECTION 10: SET OPERATIONS (UNION vs UNION ALL)
-- ----------------------------------------------------------------------------
-- 10.1 UNION: All unique departments/majors across STUDENT and COURSE
SELECT major AS dept_code FROM STUDENT
UNION
SELECT dept AS dept_code FROM COURSE;

-- 10.2 UNION ALL: Same list retaining duplicates
SELECT major AS dept_code FROM STUDENT
UNION ALL
SELECT dept AS dept_code FROM COURSE;

-- ----------------------------------------------------------------------------
-- SECTION 11: SUBQUERIES (Nested, Correlated, EXISTS, NOT EXISTS, IN)
-- ----------------------------------------------------------------------------
-- 11.1 Nested Query: Students scoring above the overall average marks
SELECT regno, course_no, marks
FROM ENROLL
WHERE marks > (SELECT AVG(marks) FROM ENROLL);

-- 11.2 IN with Subquery: Courses that adopted books published by 'Pearson'
SELECT course_no, cname
FROM COURSE
WHERE course_no IN (
    SELECT BA.course_no
    FROM BOOK_ADOPTION BA
    JOIN TEXT T ON BA.book_ISBN = T.book_ISBN
    WHERE T.publisher = 'Pearson'
);

-- 11.3 Correlated Nested Query: Enrollments with marks >= average marks in that semester
SELECT E1.regno, E1.course_no, E1.sem, E1.marks
FROM ENROLL E1
WHERE E1.marks >= (
    SELECT AVG(E2.marks)
    FROM ENROLL E2
    WHERE E2.sem = E1.sem
);

-- 11.4 EXISTS: Students who are enrolled in at least one course
SELECT S.regno, S.name
FROM STUDENT S
WHERE EXISTS (
    SELECT 1 FROM ENROLL E WHERE E.regno = S.regno
);

-- 11.5 NOT EXISTS: Students not enrolled in any course
SELECT S.regno, S.name
FROM STUDENT S
WHERE NOT EXISTS (
    SELECT 1 FROM ENROLL E WHERE E.regno = S.regno
);

-- ----------------------------------------------------------------------------
-- SECTION 12: JOIN OPERATIONS
-- ----------------------------------------------------------------------------
-- 12.1 INNER JOIN: Students and their enrolled courses with marks
SELECT S.name, E.course_no, E.marks
FROM STUDENT S
INNER JOIN ENROLL E ON S.regno = E.regno;

-- 12.2 LEFT JOIN: All students including unenrolled (Fatima Begum)
SELECT S.regno, S.name, E.course_no, E.marks
FROM STUDENT S
LEFT JOIN ENROLL E ON S.regno = E.regno;

-- 12.3 RIGHT JOIN: All courses including those with no enrollments (Cloud Computing)
SELECT E.regno, C.course_no, C.cname
FROM ENROLL E
RIGHT JOIN COURSE C ON E.course_no = C.course_no;

-- 12.4 CROSS JOIN
SELECT S.name, C.cname FROM STUDENT S CROSS JOIN COURSE C LIMIT 10;

-- 12.5 SELF JOIN: Pairs of different students with the same major
SELECT S1.name AS student_1, S2.name AS student_2, S1.major
FROM STUDENT S1
JOIN STUDENT S2 ON S1.major = S2.major AND S1.regno < S2.regno;

-- 12.6 Multiple-table JOIN: Student, Course, Adopted Book, and Publisher
SELECT S.name, C.cname, T.book_title, T.publisher, E.marks
FROM STUDENT S
JOIN ENROLL E         ON S.regno = E.regno
JOIN COURSE C         ON E.course_no = C.course_no
JOIN BOOK_ADOPTION BA ON C.course_no = BA.course_no AND E.sem = BA.sem
JOIN TEXT T           ON BA.book_ISBN = T.book_ISBN
ORDER BY S.name;

-- ----------------------------------------------------------------------------
-- SECTION 13: AGGREGATE FUNCTIONS
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)   AS total_enrollments,
    SUM(marks) AS total_marks,
    ROUND(AVG(marks), 2) AS avg_marks,
    MIN(marks) AS lowest_marks,
    MAX(marks) AS highest_marks
FROM ENROLL;

-- ----------------------------------------------------------------------------
-- SECTION 14: GROUPING OPERATIONS
-- ----------------------------------------------------------------------------
-- 14.1 GROUP BY with aggregate: Number of books adopted per course
SELECT C.cname, COUNT(BA.book_ISBN) AS book_count
FROM COURSE C
JOIN BOOK_ADOPTION BA ON C.course_no = BA.course_no
GROUP BY C.cname;

-- 14.2 GROUP BY with HAVING: Courses adopting more than 1 textbook
SELECT course_no, COUNT(book_ISBN) AS total_books
FROM BOOK_ADOPTION
GROUP BY course_no
HAVING COUNT(book_ISBN) > 1;

-- 14.3 GROUP BY multiple columns: Average marks by department and semester
SELECT C.dept, E.sem, COUNT(*) AS student_count, ROUND(AVG(E.marks), 2) AS avg_marks
FROM ENROLL E
JOIN COURSE C ON E.course_no = C.course_no
GROUP BY C.dept, E.sem
HAVING AVG(E.marks) >= 70;

-- ----------------------------------------------------------------------------
-- SECTION 15: DCL QUERIES (ADMIN-ONLY)
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'student_user'@'localhost' IDENTIFIED BY 'Student@123';
GRANT SELECT, INSERT ON student_enrollment_db.* TO 'student_user'@'localhost';
SHOW GRANTS FOR 'student_user'@'localhost';
REVOKE INSERT ON student_enrollment_db.* FROM 'student_user'@'localhost';
SHOW GRANTS FOR 'student_user'@'localhost';
FLUSH PRIVILEGES;
