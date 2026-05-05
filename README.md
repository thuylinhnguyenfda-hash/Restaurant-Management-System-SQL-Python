# Restaurant-Management-System-SQL-Python

A comprehensive Console-based Restaurant Management System built with **Python** and **MySQL**. This project is developed to automate daily restaurant operations including table reservations, order entries, billing, and database analytics.

## Key Features
*   **Customer & Reservation Management:** Track customer details and handle table bookings with time validation.
*   **Automated Table Status:** Tables automatically update their status (`available`, `reserved`, `occupied`) using MySQL Triggers.
*   **Order & Billing Processing:** Add dishes to invoices and automatically calculate total amounts, service charges (5%), and VAT (8%).
*   **Advanced Database Objects:** Utilizes Views, Stored Procedures, Functions, and Indexes to optimize query performance and ensure data consistency.
*   **Role-Based Security:** Features distinct user roles (`admin_user`, `cashier_user`, `waiter_user`) with restricted database privileges.

## Technologies Used
*   **Language:** Python 3.x
*   **Database:** MySQL 8.4
*   **Libraries:** `mysql-connector-python`, `tabulate`, `datetime`, `os`

## Repository Structure
*   `app.py`: The main Python script containing the console-based application interface.
*   `01_Database_Schema.sql`: SQL script to initialize the database schema and insert sample datasets.
*   `02_Advanced_Objects.sql`: SQL script containing advanced objects (Views, Procedures, Functions, Triggers, Indexes) and Security configurations.
*   `Dump20260505.sql`: The complete database backup dump file.
*   `Final Report.pdf`: Full technical project report.

## How to Run
1. Execute the SQL scripts in your MySQL environment (run `01_Tao_Database.sql` first, followed by `02_Tao_Ham_Nang_Cao.sql`, or simply import `Dump20260505.sql`).
2. Update the database connection credentials in `app.py` (host, user, password).
3. Install dependencies: `pip install mysql-connector-python`
4. Run the application: `python app.py`

## Author
**Nguyễn Thị Thùy Linh**
* Data Science 66A
* Falculty of Data Science and Artificial Intelligence 
* National Economics University (NEU)
* Database Management Systems Course Project
