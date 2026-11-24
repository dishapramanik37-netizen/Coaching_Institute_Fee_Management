USE coaching_fee_management;

-- Q1. View all students from Kolkata ordered by join date
SELECT student_id, full_name, email, phone, joined_date
FROM students
WHERE city = 'Kolkata'
ORDER BY joined_date;

-- Q2. List all courses with fee above 10,000
SELECT course_name, duration_months, total_fee
FROM courses
WHERE total_fee > 10000
ORDER BY total_fee DESC;

-- Q3. Report 1: Total students enrolled per course (JOIN + GROUP BY)
SELECT c.course_name,
       COUNT(e.enrollment_id) AS total_students
FROM courses c
LEFT JOIN batches b ON b.course_id = c.course_id
LEFT JOIN enrollments e ON e.batch_id = b.batch_id
GROUP BY c.course_id, c.course_name
ORDER BY total_students DESC;

-- Q4. Report 2: Fees collected per month (DATE_FORMAT + SUM + GROUP BY)
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS payment_month,
       COUNT(payment_id) AS total_transactions,
       SUM(amount_paid) AS monthly_collection
FROM fee_payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY payment_month;

-- Q5. Report 3: Top fee defaulters (Students with highest pending dues)
SELECT s.full_name AS student_name,
       s.phone,
       c.course_name,
       b.batch_name,
       e.due_amount AS pending_fee
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN batches b ON b.batch_id = e.batch_id
JOIN courses c ON c.course_id = b.course_id
WHERE e.due_amount > 0
ORDER BY e.due_amount DESC
LIMIT 5;

-- Q6. Payment collection breakdown by payment mode (HAVING clause)
SELECT payment_mode,
       COUNT(payment_id) AS payment_count,
       SUM(amount_paid) AS total_amount
FROM fee_payments
GROUP BY payment_mode
HAVING SUM(amount_paid) >= 10000
ORDER BY total_amount DESC;

-- Q7. Subquery: Students who paid more than the average single instalment
SELECT DISTINCT s.full_name, fp.amount_paid, fp.payment_date
FROM fee_payments fp
JOIN enrollments e ON e.enrollment_id = fp.enrollment_id
JOIN students s ON s.student_id = e.student_id
WHERE fp.amount_paid > (SELECT AVG(amount_paid) FROM fee_payments)
ORDER BY fp.amount_paid DESC;

-- Q8. Students who have NOT enrolled in any batch yet (LEFT JOIN IS NULL)
SELECT s.student_id, s.full_name, s.email, s.city
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.student_id
WHERE e.enrollment_id IS NULL;

-- Q9. Querying our saved Views
SELECT * FROM v_pending_fees;
SELECT * FROM v_course_revenue;

-- Q10. Batch schedule with course name and enrolled student count
SELECT b.batch_name, c.course_name, b.timing, COUNT(e.enrollment_id) AS enrolled_count
FROM batches b
JOIN courses c ON c.course_id = b.course_id
LEFT JOIN enrollments e ON e.batch_id = b.batch_id
GROUP BY b.batch_id, b.batch_name, c.course_name, b.timing;

-- Q11. Update a student's city
UPDATE students
SET city = 'Salt Lake, Kolkata'
WHERE student_id = 10;

-- Q12. Mark enrollments with 0 due amount as COMPLETED
UPDATE enrollments
SET status = 'COMPLETED'
WHERE due_amount = 0.00 AND status = 'ACTIVE' AND enrollment_id > 0;

-- Q13. Safe demo delete using a temporary test student record
INSERT INTO students (full_name, email, phone, city, joined_date)
VALUES ('Test Student', 'test.delete@example.com', '9999900000', 'Kolkata', '2026-08-25');

DELETE FROM students
WHERE email = 'test.delete@example.com';

-- Q14. Transaction 1 (COMMIT): Enrol Student 10 (Megha) into Batch D (Web Development) and collect first instalment together
START TRANSACTION;

INSERT INTO enrollments (student_id, batch_id, enroll_date)
VALUES (10, 4, '2026-08-25');

SET @new_enroll_id = LAST_INSERT_ID();

INSERT INTO fee_payments (enrollment_id, amount_paid, payment_date, payment_mode)
VALUES (@new_enroll_id, 8000.00, '2026-08-25', 'UPI');

COMMIT;

-- Verify Megha's enrollment and remaining due (18000 - 8000 = 10000)
SELECT * FROM enrollments WHERE enrollment_id = @new_enroll_id;

-- Q15. Transaction 2 (ROLLBACK): Demo cancelling a mistaken payment entry
START TRANSACTION;

INSERT INTO fee_payments (enrollment_id, amount_paid, payment_date, payment_mode)
VALUES (4, 2000.00, '2026-08-26', 'CASH');

-- Undo the mistaken payment and restore due_amount automatically
ROLLBACK;

-- ----------------------------------------------------------
-- PART D: TRIGGER TEST (OVERPAYMENT REJECTION)
-- ----------------------------------------------------------
-- Uncomment the line below to test the BEFORE INSERT trigger error:
-- INSERT INTO fee_payments (enrollment_id, amount_paid, payment_date, payment_mode) VALUES (2, 50000.00, '2026-08-27', 'UPI');
