# Library Management System - SQL Project

## Overview
This project focuses on managing and analyzing a library system using SQL. It includes tasks such as data cleaning, CRUD operations, advanced SQL queries, and stored procedures to handle book issuance, returns, and member management. The project also generates reports on branch performance, overdue books, and active members.

## Tasks Performed
1. **Data Cleaning**: Verified and corrected data types for tables like `issued_status`, `return_status`, and `members`.
2. **CRUD Operations**: Inserted new book records, updated member addresses, and deleted issued records.
3. **Data Analysis**: Analyzed rental income by category, identified overdue books, and generated branch performance reports.
4. **Advanced SQL**: Created stored procedures for book issuance and return management, and used CTAS to generate summary tables.
5. **Reports**: Generated reports on active members, top-performing employees, and overdue book fines.

# Library Management System - SQL Project

## Business Problems and Tasks

### Data Cleaning and Preparation
1. **Verify Data Import**: Check if all records were imported correctly by counting rows in each table.
2. **Check Data Types**: Ensure columns like `issued_date`, `return_date`, and `reg_date` are in the correct format (`DATE`).
3. **Modify Data Types**: Convert `issued_date`, `return_date`, and `reg_date` to `DATE` type.
4. **Handle Missing Values**: Check for null values and clean the dataset.

### CRUD Operations
5. **Insert New Book Record**: Add a new book to the `books` table.
6. **Update Member Address**: Modify a member's address in the `members` table.
7. **Delete Issued Record**: Remove a record from the `issued_status` table.

### Data Analysis and Insights
8. **Retrieve Books Issued by an Employee**: Find all books issued by a specific employee.
9. **Identify Members with Multiple Issued Books**: Use `GROUP BY` to find members who issued more than one book.
10. **Retrieve Books in a Specific Category**: List all books in the "Classic" category.
11. **Calculate Total Rental Income by Category**: Find the total rental income for each category, ordered by highest income.
12. **List Members Registered in the Last 360 Days**: Identify recently registered members.
13. **List Employees with Branch Details**: Display employees along with their branch manager's name and branch details.
14. **Create a Table of Expensive Books**: Generate a table of books with rental prices above a specific threshold.
15. **Retrieve Books Not Yet Returned**: List books that are still issued and not returned.

### Advanced SQL Operations
16. **Identify Overdue Books**: Find members with books overdue by more than 30 days.
17. **Update Book Status on Return**: Automatically update the status of returned books to "yes".
18. **Generate Branch Performance Reports**: Create a report showing the number of books issued, returned, and total revenue per branch.
19. **Create a Table of Active Members**: Generate a table of members who issued at least one book in the last 400 days.
20. **Find Top 3 Employees by Book Issues**: Identify employees who processed the most book issues.
21. **Create a Stored Procedure for Book Issuance**: Automate the process of issuing books and updating their status.
22. **Calculate Overdue Fines**: Create a table listing members with overdue books and calculate fines.

---


## GitHub Repository
[Library Management Project Repository](https://github.com/haseeb-505/library_management_project.git)

---
