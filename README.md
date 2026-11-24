# Coaching Institute Fee Management System (MySQL)

## 1. Project Overview
A pure relational database project built in **MySQL** and **MySQL Workbench** to manage student admissions, course catalogs, batch schedules, fee instalments, and pending balances for a coaching institute.

## 2. Database Schema (`coaching_fee_management`)
The database consists of **5 normalized tables** connected via primary and foreign keys:
1. **`students`**: Stores student profiles (`student_id`, `full_name`, `email`, `phone`, `city`, `joined_date`).
2. **`courses`**: Stores available courses (`Python`, `Java`, `C++`, `Web Development`, `Generative AI`), durations, and total fees.
3. **`batches`**: Links batches (`Batch A` to `Batch F`) to specific courses along with class timings and start dates.
4. **`enrollments`**: Tracks which student is enrolled in which batch, their current `due_amount`, and enrollment `status`.
5. **`fee_payments`**: Records individual fee instalments (`amount_paid`, `payment_date`, `payment_mode`).

## 3. Key Features Implemented
- **Automated Triggers**:
  - `trg_enrollments_before_insert`: Automatically sets the initial `due_amount` equal to the course's `total_fee` when a student enrolls.
  - `trg_payments_before_insert`: Rejects any payment that exceeds the student's pending `due_amount`.
  - `trg_payments_after_insert`: Automatically deducts each instalment from the student's `due_amount` after payment.
- **Reporting Views**:
  - `v_pending_fees`: Displays all students with unpaid balances alongside their course, batch, total paid, and pending fee.
  - `v_course_revenue`: Summarizes total enrollments, collected revenue, and pending fees per course.
- **ACID Transactions**:
  - Demonstrates atomic enrollment + first instalment collection using `START TRANSACTION` and `COMMIT`, as well as safe error recovery using `ROLLBACK`.
- **CSV Import & Export**:
  - Imported new student records from `students_import.csv` and exported pending fee reports to `fee_report.csv`.

## 4. Project Files
- `project.sql` – Creates the database, tables, indexes, sample records, triggers, and views.
- `queries.sql` – Contains 10+ analytical `SELECT` reports, `UPDATE`/`DELETE` operations, and `COMMIT`/`ROLLBACK` transactions.
- `er_diagram.png` – Entity-Relationship diagram reverse-engineered from MySQL Workbench.
- `students_import.csv` – Sample CSV file used to bulk-import new students.
- `fee_report.csv` – Exported pending fees report generated from `v_pending_fees`.
- `Screenshots/` – Query execution screenshots showing views, monthly fee collections, and table schemas.

## 5. How to Run
1. Open **MySQL Workbench** and connect to your local MySQL server.
2. Open and execute `project.sql` (`Ctrl + Shift + Enter`) to build the database and load sample data.
3. Open and execute `queries.sql` to run the analytical reports and transaction demos.
