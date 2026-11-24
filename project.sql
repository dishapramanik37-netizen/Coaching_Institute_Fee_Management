DROP DATABASE IF EXISTS coaching_fee_management;
CREATE DATABASE coaching_fee_management;
USE coaching_fee_management;

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(80) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    city VARCHAR(50) NOT NULL,
    joined_date DATE NOT NULL
);

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(80) NOT NULL UNIQUE,
    duration_months INT NOT NULL CHECK (duration_months > 0),
    total_fee DECIMAL(10,2) NOT NULL CHECK (total_fee > 0)
);

CREATE TABLE batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    batch_name VARCHAR(50) NOT NULL UNIQUE,
    timing VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    batch_id INT NOT NULL,
    enroll_date DATE NOT NULL,
    due_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (due_amount >= 0),
    status ENUM('ACTIVE', 'COMPLETED', 'DROPPED') NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

CREATE TABLE fee_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid > 0),
    payment_date DATE NOT NULL,
    payment_mode ENUM('CASH', 'UPI', 'CARD', 'BANK_TRANSFER') NOT NULL DEFAULT 'UPI',
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

CREATE INDEX idx_students_city ON students(city);
CREATE INDEX idx_payments_date ON fee_payments(payment_date);

INSERT INTO students (full_name, email, phone, city, joined_date) VALUES
('Ananya Sen', 'ananya.sen@example.com', '9830011101', 'Kolkata', '2026-07-01'),
('Rahul Das', 'rahul.das@example.com', '9830011102', 'Howrah', '2026-07-02'),
('Priya Ghosh', 'priya.ghosh@example.com', '9830011103', 'Kolkata', '2026-07-05'),
('Arjun Mitra', 'arjun.mitra@example.com', '9830011104', 'Durgapur', '2026-07-10'),
('Sneha Roy', 'sneha.roy@example.com', '9830011105', 'Kolkata', '2026-07-12'),
('Imran Sheikh', 'imran.sheikh@example.com', '9830011106', 'Siliguri', '2026-07-15'),
('Debjani Paul', 'debjani.paul@example.com', '9830011107', 'Howrah', '2026-07-18'),
('Rohit Banerjee', 'rohit.banerjee@example.com', '9830011108', 'Kolkata', '2026-07-20'),
('Sourav Bose', 'sourav.bose@example.com', '9830011109', 'Barasat', '2026-07-22'),
('Megha Chatterjee', 'megha.c@example.com', '9830011110', 'Kolkata', '2026-07-25');

INSERT INTO courses (course_name, duration_months, total_fee) VALUES
('Python', 3, 10000.00),
('Java', 4, 12000.00),
('C++', 3, 9000.00),
('Web Development', 6, 18000.00),
('Generative AI', 4, 20000.00);

INSERT INTO batches (course_id, batch_name, timing, start_date) VALUES
(1, 'Batch A', '09:00 AM - 11:00 AM', '2026-08-01'),
(2, 'Batch B', '11:30 AM - 01:30 PM', '2026-08-02'),
(3, 'Batch C', '03:00 PM - 05:00 PM', '2026-08-04'),
(4, 'Batch D', '06:00 PM - 08:00 PM', '2026-08-05'),
(5, 'Batch E', '10:00 AM - 01:00 PM', '2026-08-08'),
(1, 'Batch F', '07:00 PM - 09:00 PM', '2026-08-10');

DELIMITER $$
CREATE TRIGGER trg_enrollments_before_insert
BEFORE INSERT ON enrollments
FOR EACH ROW
BEGIN
    DECLARE v_course_fee DECIMAL(10,2);
    SELECT c.total_fee INTO v_course_fee
    FROM batches b
    JOIN courses c ON c.course_id = b.course_id
    WHERE b.batch_id = NEW.batch_id;
    
    SET NEW.due_amount = v_course_fee;
END$$

CREATE TRIGGER trg_payments_before_insert
BEFORE INSERT ON fee_payments
FOR EACH ROW
BEGIN
    DECLARE v_due DECIMAL(10,2);
    SELECT due_amount INTO v_due
    FROM enrollments
    WHERE enrollment_id = NEW.enrollment_id;
    
    IF NEW.amount_paid > v_due THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment rejected: Amount exceeds pending due fee';
    END IF;
END$$

CREATE TRIGGER trg_payments_after_insert
AFTER INSERT ON fee_payments
FOR EACH ROW
BEGIN
    UPDATE enrollments
    SET due_amount = due_amount - NEW.amount_paid
    WHERE enrollment_id = NEW.enrollment_id;
END$$
DELIMITER ;

INSERT INTO enrollments (student_id, batch_id, enroll_date) VALUES
(1, 1, '2026-08-01'), -- Python (10000)
(2, 2, '2026-08-02'), -- Java (12000)
(3, 3, '2026-08-04'), -- C++ (9000)
(4, 4, '2026-08-05'), -- Web Development (18000)
(5, 5, '2026-08-08'), -- Generative AI (20000)
(6, 4, '2026-08-06'), -- Web Development (18000)
(7, 5, '2026-08-09'), -- Generative AI (20000)
(8, 2, '2026-08-03'), -- Java (12000)
(9, 6, '2026-08-10'); -- Python (10000)

INSERT INTO fee_payments (enrollment_id, amount_paid, payment_date, payment_mode) VALUES
(1, 6000.00,  '2026-08-01', 'UPI'),
(1, 4000.00,  '2026-09-05', 'BANK_TRANSFER'),
(2, 6000.00,  '2026-08-02', 'CASH'),
(3, 5000.00,  '2026-08-04', 'CARD'),
(3, 4000.00,  '2026-09-10', 'UPI'),
(4, 10000.00, '2026-08-05', 'UPI'),
(5, 10000.00, '2026-08-08', 'BANK_TRANSFER'),
(5, 10000.00, '2026-10-01', 'UPI'),
(6, 9000.00,  '2026-08-06', 'CASH'),
(7, 8000.00,  '2026-08-09', 'UPI'),
(8, 6000.00,  '2026-08-03', 'CASH'),
(9, 5000.00,  '2026-08-10', 'UPI');

CREATE VIEW v_pending_fees AS
SELECT e.enrollment_id,
       s.full_name AS student_name,
       s.phone,
       c.course_name,
       b.batch_name,
       c.total_fee,
       (c.total_fee - e.due_amount) AS total_paid,
       e.due_amount AS pending_fee
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN batches b ON b.batch_id = e.batch_id
JOIN courses c ON c.course_id = b.course_id
WHERE e.due_amount > 0;

CREATE VIEW v_course_revenue AS
SELECT c.course_name,
       COUNT(e.enrollment_id) AS total_students,
       SUM(c.total_fee - e.due_amount) AS collected_fee,
       SUM(e.due_amount) AS pending_fee
FROM courses c
LEFT JOIN batches b ON b.course_id = c.course_id
LEFT JOIN enrollments e ON e.batch_id = b.batch_id
GROUP BY c.course_id, c.course_name;
