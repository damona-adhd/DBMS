# DBMS Lab — 5 Complete SQL Programs

Five independent, single-file SQL programs for MariaDB / MySQL on Linux. Each file contains the complete database creation, table definitions (with primary & foreign keys), sample inserts (5+ rows per table), DDL, DML, DQL (`SELECT`, `WHERE`, `LIKE`, `BETWEEN`, `ORDER BY`), Set Operations (`UNION`, `UNION ALL`), Subqueries (`EXISTS`, `NOT EXISTS`, Nested & Correlated), `JOIN`s, Aggregate Functions, `GROUP BY` / `HAVING`, and DCL (`GRANT`, `REVOKE`).

## Programs

| # | Program File | Database Name |
| :--- | :--- | :--- |
| 1 | [01_Sailors_Database.sql](./01_Sailors_Database.sql) | `sailors_db` |
| 2 | [02_Insurance_Database.sql](./02_Insurance_Database.sql) | `insurance_db` |
| 3 | [03_Order_Processing_Database.sql](./03_Order_Processing_Database.sql) | `order_processing_db` |
| 4 | [04_Student_Enrollment_Book_Adoption_Database.sql](./04_Student_Enrollment_Book_Adoption_Database.sql) | `student_enrollment_db` |
| 5 | [05_Company_Database.sql](./05_Company_Database.sql) | `company_db` |

## How to Run on Ubuntu Linux (MariaDB)

Run any program with a single command:

```bash
sudo mariadb < 01_Sailors_Database.sql
sudo mariadb < 02_Insurance_Database.sql
sudo mariadb < 03_Order_Processing_Database.sql
sudo mariadb < 04_Student_Enrollment_Book_Adoption_Database.sql
sudo mariadb < 05_Company_Database.sql
```
