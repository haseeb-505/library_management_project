

-- Check by counting the records of each table to see if the complete data was imported or not

select COUNT(*) from library_system.books;
select COUNT(*) from library_system.branch;
select COUNT(*) from library_system.employees;
select COUNT(*) from library_system.issued_status;
select COUNT(*) from library_system.return_status;

-- Now we check the data types of fields/columns in each table
-- books
SHOW COLUMNS FROM library_system.books;
-- everything in books table is ok, let's move to next table

-- branch
SHOW COLUMNS FROM library_system.branch;
-- everything in branch table is ok as well, let's move to next table

-- employees
SHOW COLUMNS FROM library_system.employees;
-- this is also good to go, let's move next

-- issued_status
SHOW COLUMNS FROM library_system.issued_status;
-- need to change issued_date to date type, it already is text
ALTER TABLE library_system.issued_status
	MODIFY COLUMN issued_date DATE;

-- Check the table again
SHOW COLUMNS FROM library_system.issued_status;

-- check for returned_status
SHOW COLUMNS FROM library_system.return_status;
-- change the return_date type to date,alter

ALTER TABLE library_system.return_status
	MODIFY COLUMN return_date DATE;

SHOW COLUMNS FROM library_system.return_status;

-- members table
SHOW COLUMNS FROM library_system.members;
-- need to change reg_date to only date while it is in datetime format.

ALTER TABLE library_system.members
	MODIFY COLUMN reg_date DATE;

-- check the table again
SHOW COLUMNS FROM library_system.issued_status;

-- Show the table

select * from library_system.books;
select * from library_system.branch;
select * from library_system.employees;
select * from library_system.issued_status;
select * from library_system.return_status;

-- CRUD operations

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO library_system.books(isbn, book_title, category, rental_price, status, author, publisher)
	VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM library_system.books;

-- 2 update an existing member's address
-- SELECT * FROM library_system.members;

SET SQL_SAFE_UPDATES = 0;

UPDATE library_system.members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM library_system.members
WHERE member_id = 'C103';

-- Task 3: Delete the record with issued_id = 'IS121' from the issued_status table.

SET SQL_SAFE_UPDATES = 0;
DELETE FROM library_system.issued_status
WHERE issued_id = 'IS121';

SET SQL_SAFE_UPDATES = 1;

-- Task 4: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM library_system.issued_status WHERE issued_emp_id = 'E101';

-- 5 Use GROUP BY to find members who have issued more than one book.

-- count of issued_member_ids
SELECT issued_member_id, COUNT(issued_member_id)
FROM library_system.issued_status 
GROUP BY issued_member_id;
-- final query
SELECT issued_member_id, COUNT(issued_member_id)
FROM library_system.issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_member_id) > 1;

-- create table as select

-- 6 Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt

SELECT issued_id, COUNT(issued_id)
FROM library_system.issued_status
GROUP BY issued_id;
-- issued_id is unique

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) as total_issued_books
FROM library_system.issued_status AS ist
JOIN  library_system.books AS b
	ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title
ORDER BY total_issued_books DESC
; 

-- Data Analysis and Findings

-- 7 Retrieve All Books in a Specific Category
SELECT * FROM library_system.books WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category order by most income first:
-- SELECT * FROM library_system.issued_status;
-- SELECT status, count(status) FROM library_system.books group by status; 
SELECT b.category, 
	SUM(rental_price) AS total_rental_price, 
    COUNT(*) as total_rent_books_category
FROM library_system.books as b
JOIN library_system.issued_status as ist
	ON b.isbn = ist.issued_book_isbn
GROUP BY category
ORDER BY total_rental_price DESC;

-- 9 List Members Who Registered in the Last 360 Days
SELECT * 
FROM library_system.members
WHERE reg_date >= CURDATE() - INTERVAL 360 DAY;

-- 10 List Employees with Their Branch Manager's Name and their branch details.

SELECT empl.emp_id, empl.emp_name, empl.position, empl.salary, brn.*, empl2.emp_name
FROM library_system.employees as empl
JOIN library_system.branch as brn
 ON empl.branch_id = brn.branch_id
JOIN library_system.employees as empl2
ON empl2.emp_id = brn.manager_id
;

-- 11 Task 11. Create a Table of Books with Rental Price Above a Certain Threshold, say 6
CREATE TABLE expensive_books AS
SELECT * FROM library_system.books
WHERE rental_price > 6;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM library_system.issued_status;
SELECT * FROM library_system.return_status;

SELECT * FROM library_system.issued_status AS ist
LEFT JOIN library_system.return_status AS rst
	ON rst.issued_id = ist.issued_id
WHERE rst.return_id is NULL
;

-- ** Advance SQL Operations**

-- 13 Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

-- First we see, after how much time, other members are returning books
SELECT ist.issued_member_id, mbr.member_name, ist.issued_book_name, 
	ist.issued_date, rtn.return_date,
	DATEDIFF(rtn.return_date, ist.issued_date) as return_days,
    AVG(DATEDIFF(rtn.return_date, ist.issued_date)) OVER(PARTITION BY mbr.member_name) as avg_return_days
FROM library_system.issued_status as ist
JOIN library_system.return_status as rtn
	ON ist.issued_id = rtn.issued_id
JOIN library_system.members as mbr
	ON ist.issued_member_id = mbr.member_id
;
    
-- SELECT * FROM library_system.members;    
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.
    
SELECT ist.issued_member_id, mbr.member_name, ist.issued_book_name, 
	ist.issued_date, rtn.return_date,
	DATEDIFF(CURDATE(), ist.issued_date) as overdue_days,
    AVG(DATEDIFF(CURDATE(), ist.issued_date)) OVER() as avg_overdue_days
FROM library_system.issued_status as ist
JOIN library_system.members as mbr
	ON ist.issued_member_id = mbr.member_id
LEFT JOIN library_system.return_status as rtn
	ON ist.issued_id = rtn.issued_id
WHERE 
	rtn.return_date is NULL
    AND
 	DATEDIFF(CURDATE(), ist.issued_date) > 1
ORDER BY ist.issued_member_id
;
-- above query is okay to perform the desired task

SELECT ist.issued_id, ist.issued_member_id, 
	mbr.member_name, ist.issued_book_name,
	ist.issued_date, rtn.return_date,
    DATEDIFF(CURDATE(), ist.issued_date) as overdue_days
FROM library_system.issued_status as ist
JOIN library_system.members as mbr
	ON mbr.member_id = ist.issued_member_id
LEFT JOIN library_system.return_status as rtn
	ON ist.issued_id = rtn.issued_id
WHERE rtn.return_date is NULL
	AND
    DATEDIFF(CURDATE(), ist.issued_date) > 30
ORDER BY ist.issued_date ASC
;

-- 14 Write a query to update the status of books in the books table to 
-- "Yes" when they are returned (based on entries in the return_status table).

DELIMITER $$
DROP PROCEDURE IF EXISTS add_return_records$$

CREATE PROCEDURE add_return_records(
	IN p_return_id VARCHAR(15),
    IN p_issued_id VARCHAR(15),
    IN p_book_quality VARCHAR(15)
)

BEGIN
	DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(50);
    
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);
    
    SELECT issued_book_isbn, issued_book_name 
        INTO
        v_isbn, v_book_name
    FROM library_system.issued_status AS ist
    WHERE ist.issued_id = p_issued_id;
    
    -- update book status
    UPDATE books
    SET books.status = 'yes'
    WHERE isbn = v_isbn;
    
    -- Print message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END $$

DELIMITER ;

-- Testing FUNCTION add_return_records
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';
SELECT * FROM issued_status WHERE issued_book_isbn = '978-0-307-58837-1';
SELECT * FROM return_status WHERE issued_id = 'IS135';

DESC library_system.return_status;

-- add column
-- ALTER TABLE library_system.return_status ADD COLUMN book_quality TEXT;

-- calling function
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function
CALL add_return_records('RS148', 'IS140', 'Good');

-- 15 Create a query that generates a performance report for each branch, 
-- showing the number of books issued, the number of books returned, 
-- and the total revenue generated from book rentals.

CREATE TABLE branch_reports AS
SELECT brn.branch_id, 
	brn.manager_id, 
    COUNT(ist.issued_id) AS total_issued_books,
    COUNT(rtn.return_id) AS number_of_books_returned,
    SUM(CASE WHEN rtn.return_id IS NULL THEN 1 ELSE 0 END) AS not_returned,
    SUM(bk.rental_price) AS total_revnue
FROM library_system.branch AS brn
JOIN library_system.employees AS empl1
	ON brn.branch_id = empl1.branch_id
JOIN library_system.issued_status AS ist
	ON ist.issued_emp_id = empl1.emp_id
JOIN library_system.books AS bk
	ON  bk.isbn = ist.issued_book_isbn
LEFT JOIN library_system.return_status AS rtn
	ON rtn.issued_id = ist.issued_id
GROUP BY 1,2
;

-- call the above table for results
SELECT * FROM branch_reports;

-- 16 Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 400 days.

DROP TABLE IF EXISTS active_members;

CREATE TABLE active_members AS
SELECT mbr.member_id, mbr.member_name, 
	mbr.reg_date, ist.issued_book_name,
	ist.issued_date, DATEDIFF(CURDATE(), ist.issued_date) AS days_to_last_issue
FROM library_system.members AS mbr
JOIN library_system.issued_status AS ist
	ON mbr.member_id = ist.issued_member_id
WHERE ist.issued_date >= CURDATE() - INTERVAL 14 month
;

-- call the table for results
SELECT * FROM active_members;

-- to get the unique members
SELECT DISTINCT active_members.member_id, active_members.member_name
FROM active_members
ORDER BY active_members.member_name ASC;


-- 17 Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

SELECT empl.emp_id, 
	empl.emp_name,
	COUNT(ist.issued_id) AS total_books_processed,
    empl.branch_id
FROM library_system.employees AS empl
JOIN library_system.issued_status AS ist
	ON empl.emp_id = ist.issued_emp_id
GROUP BY empl.emp_id, empl.emp_name, empl.branch_id
;

-- 	18 Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
-- Display the member name, book title, and the number of times they've issued damaged books.

-- Since there is no information about the condition of book, damaged, good, etc.,
-- Therefore, we skip this one.

-- 19 Create a stored procedure to manage the status of books in a library system.
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
-- The procedure should function as follows:
-- The stored procedure should take the book_id as an input parameter.
-- The procedure should first check if the book is available (status = 'yes').
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

DELIMITER $$

DROP PROCEDURE IF EXISTS issue_book;

CREATE PROCEDURE issue_book(
	IN p_issued_id VARCHAR(15),
    IN p_issued_member_id VARCHAR(15),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(15)
)

BEGIN
	DECLARE v_status VARCHAR(15);
    
    SELECT bk.status
		INTO 
			v_status
    FROM library_system.books AS bk
    WHERE bk.isbn = p_issued_book_isbn
    LIMIT 1;
    
    IF v_status IS NOT NULL AND v_status = 'yes' THEN
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES(p_issued_id, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);
    
		-- alot the book and update book status to no for not available
        UPDATE library_system.books AS bk
			SET bk.status = 'no'
		WHERE bk.isbn = p_issued_book_isbn;
        
        -- message for user
        SELECT CONCAT('Book records added successfully for book isbn :', p_issued_book_isbn) AS message;
	ELSE
		SELECT CONCAT('Sorry to inform you the book you have requested is unavailable book_isbn: ', p_issued_book_isbn) AS message;

	END IF;

END $$

DELIMITER ;

-- safe update satus changing
SET SQL_SAFE_UPDATES = 0;

-- calling the procedure
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
-- another record
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM library_system.books WHERE isbn = '978-0-375-41398-8';


-- 20 Write a CTAS query to create a new table that lists each member and the books
-- they have issued but not returned within 30 days.
-- The table should include: The number of overdue books.
-- The total fines, with each day's fine calculated at $0.50.
-- The number of books issued by each member.
-- The resulting table should show: Member ID Number of overdue books Total fines

CREATE TABLE overdue_books_fine_table AS
SELECT mbr.member_id, mbr.member_name, ist.issued_book_name,
	COUNT(ist.issued_id) AS total_non_returned_books,
	SUM(DATEDIFF(CURDATE(), ist.issued_date)) AS total_overdue_days,
    (COUNT(ist.issued_id) * SUM(DATEDIFF(CURDATE(), ist.issued_date)) * 0.05) AS fine_per_book
FROM library_system.members AS mbr
JOIN library_system.issued_status AS ist
	ON mbr.member_id = ist.issued_member_id
LEFT JOIN library_system.return_status AS rtn
	ON rtn.issued_id = ist.issued_id
WHERE rtn.return_id is NULL
GROUP BY mbr.member_id, mbr.member_name, ist.issued_book_name
;

-- Now we'll agregate on member_name to find the total fine he has to pay
SELECT member_id,member_name, 
	SUM(total_non_returned_books) AS overdue_books, 
    SUM(fine_per_book) AS total_fine
FROM overdue_books_fine_table
GROUP BY member_id, member_name
;








