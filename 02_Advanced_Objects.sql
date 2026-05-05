-- PHẦN 1: ADVANCED DATABASE OBJECTS
-- 1.1 — INDEX
USE Restaurant;

-- Index 1: Tim kiem khach hang theo so dien thoai
-- Ly do: Nhan vien thuong tra cuu khach qua SDT
CREATE INDEX idx_customer_phone
    ON Customers(PhoneNumber);

-- Index 2: Tim kiem mon an theo ten
-- Ly do: Khach hay goi mon theo ten
CREATE INDEX idx_dish_name
    ON MenuItems(DishName);

-- Index 3: Tim kiem dat ban theo ngay gio
-- Ly do: Query lich dat ban theo ngay rat pho bien
CREATE INDEX idx_reservation_datetime
    ON Reservations(DateTime);

-- Index 4: Tim kiem dat ban theo khach hang
-- Ly do: Xem lich su dat ban cua 1 khach
CREATE INDEX idx_reservation_customer
    ON Reservations(CustomerID);

-- Kiem tra index hoat dong bang EXPLAIN
-- Cot "key" co ten index = dang dung index
EXPLAIN SELECT * FROM Customers WHERE PhoneNumber = '0901234567';
EXPLAIN SELECT DishName, Price FROM MenuItems WHERE DishName = 'Pho Bo Truyen Thong';
EXPLAIN SELECT * FROM Reservations WHERE DATE(DateTime) = CURDATE();
EXPLAIN SELECT * FROM Reservations WHERE CustomerID = 1;
--------------------------------------------------------------------------------------
-- 1.2 — VIEW
-- View 1: Lich dat ban hom nay
-- Ly do: Nhan vien can xem nhanh ai dat ban hom nay
CREATE VIEW vw_TodayReservations AS
SELECT
    r.ReservationID,
    c.CustomerName,
    c.PhoneNumber,
    t.TableNumber,
    r.DateTime,
    r.GuestCount
FROM Reservations r
JOIN Customers c ON r.CustomerID = c.CustomerID
JOIN `Tables`  t ON r.TableID    = t.TableID
WHERE DATE(r.DateTime) = CURDATE();

-- View 2: Cac ban dang trong
-- Ly do: Thu ngan can biet ban nao con trong de xep cho
CREATE VIEW vw_AvailableTables AS
SELECT TableID, TableNumber, Status
FROM `Tables`
WHERE Status = 'available';

-- View 3: Top 5 mon ban chay nhat
-- Ly do: Quan ly can biet mon nao dang duoc ua chuong
CREATE VIEW vw_TopSellingDishes AS
SELECT
    m.DishID,
    m.DishName,
    m.Price,
    SUM(d.Quantity)                AS TotalSold,
    SUM(d.Quantity * d.UnitPrice)  AS TotalRevenue
FROM InvoiceDetails d
JOIN MenuItems m ON d.DishID = m.DishID
GROUP BY m.DishID, m.DishName, m.Price
ORDER BY TotalSold DESC
LIMIT 5;

-- View 4: Doanh thu theo tung ngay
-- Ly do: Bao cao doanh thu hang ngay cho quan ly
CREATE VIEW vw_DailyRevenue AS
SELECT
    DATE(PaymentDate)  AS RevenueDate,
    COUNT(InvoiceID)   AS TotalInvoices,
    SUM(TotalAmount)   AS TotalRevenue
FROM Invoices
GROUP BY DATE(PaymentDate)
ORDER BY RevenueDate DESC;

-- Cach dung view (don gian nhu query bang thuong)
SELECT * FROM vw_TodayReservations;
SELECT * FROM vw_AvailableTables;
SELECT * FROM vw_TopSellingDishes;
SELECT * FROM vw_DailyRevenue;
---------------------------------------------------------------------------------
-- 1.3 — STORED PROCEDURE
DELIMITER $$

-- Procedure 1: Dat ban moi
-- Ly do: Tu dong kiem tra ban co trong khong truoc khi dat
CREATE PROCEDURE sp_MakeReservation(
    IN  p_CustomerID  INT,
    IN  p_TableID     INT,
    IN  p_DateTime    DATETIME,
    IN  p_GuestCount  INT,
    OUT p_Message     VARCHAR(100)
)
BEGIN
    DECLARE v_Status VARCHAR(20);

    -- Kiem tra trang thai ban
    SELECT Status INTO v_Status
    FROM `Tables`
    WHERE TableID = p_TableID;

    IF v_Status IS NULL THEN
        SET p_Message = 'ERROR: Table not found';
    ELSEIF v_Status != 'available' THEN
        SET p_Message = 'ERROR: Table is not available';
    ELSE
        INSERT INTO Reservations (CustomerID, TableID, DateTime, GuestCount)
        VALUES (p_CustomerID, p_TableID, p_DateTime, p_GuestCount);

        UPDATE `Tables` SET Status = 'reserved'
        WHERE TableID = p_TableID;

        SET p_Message = CONCAT('SUCCESS: ReservationID = ', LAST_INSERT_ID());
    END IF;
END$$

-- Procedure 2: Tao hoa don
-- Ly do: Tu dong tinh tong tien va luu hoa don
CREATE PROCEDURE sp_GenerateInvoice(
    IN  p_CustomerID INT,
    IN  p_TableID    INT,
    OUT p_InvoiceID  INT,
    OUT p_Message    VARCHAR(100)
)
BEGIN
    INSERT INTO Invoices (CustomerID, TableID, TotalAmount, PaymentDate)
    VALUES (p_CustomerID, p_TableID, 0, NOW());

    SET p_InvoiceID = LAST_INSERT_ID();

    UPDATE `Tables` SET Status = 'available'
    WHERE TableID = p_TableID;

    SET p_Message = CONCAT('SUCCESS: InvoiceID = ', p_InvoiceID);
END$$

DELIMITER ;

-- Cach goi procedure
CALL sp_MakeReservation(1, 1, '2026-05-15 18:00:00', 4, @msg);
SELECT @msg AS ResultMessage;

CALL sp_GenerateInvoice(1, 1, @inv_id, @msg);
SELECT @inv_id, @msg;

----------------------------------------------------------------------------
-- 1.4 — USER DEFINED FUNCTION
DELIMITER $$

-- Function 1: Tinh phi dich vu 5%
-- Ly do: Ap dung tu dong phi dich vu vao hoa don
CREATE FUNCTION fn_ServiceCharge(p_Amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_Amount * 0.05;
END$$

-- Function 2: Tinh tong tien sau thue VAT 8%
-- Ly do: Hien thi gia cuoi cung khach phai tra
CREATE FUNCTION fn_TotalWithTax(p_Amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_service DECIMAL(10,2);
    DECLARE v_vat     DECIMAL(10,2);
    SET v_service = p_Amount * 0.05;
    SET v_vat     = (p_Amount + v_service) * 0.08;
    RETURN p_Amount + v_service + v_vat;
END$$

DELIMITER ;

-- Dung function truc tiep trong SELECT
SELECT
    InvoiceID,
    TotalAmount,
    fn_ServiceCharge(TotalAmount) AS ServiceCharge,
    fn_TotalWithTax(TotalAmount)  AS FinalAmount
FROM Invoices;


-----------------------------------------------------------------------------------
-- 1.5 — TRIGGER
DELIMITER $$

-- Trigger 1: Sau khi dat ban -> tu cap nhat ban thanh 'reserved'
CREATE TRIGGER trg_AfterInsertReservation
AFTER INSERT ON Reservations
FOR EACH ROW
BEGIN
    UPDATE `Tables`
    SET Status = 'reserved'
    WHERE TableID = NEW.TableID;
END$$

-- Trigger 2: Sau khi tao hoa don -> tra ban ve 'available'
CREATE TRIGGER trg_AfterInsertInvoice
AFTER INSERT ON Invoices
FOR EACH ROW
BEGIN
    UPDATE `Tables`
    SET Status = 'available'
    WHERE TableID = NEW.TableID;
END$$

-- Trigger 3: Sau khi them InvoiceDetails -> tu cap nhat TotalAmount
CREATE TRIGGER trg_UpdateInvoiceTotal
AFTER INSERT ON InvoiceDetails
FOR EACH ROW
BEGIN
    UPDATE Invoices
    SET TotalAmount = (
        SELECT SUM(Quantity * UnitPrice)
        FROM InvoiceDetails
        WHERE InvoiceID = NEW.InvoiceID
    )
    WHERE InvoiceID = NEW.InvoiceID;
END$$

-- Trigger 4: Khong cho dat ban trong qua khu
CREATE TRIGGER trg_ValidateDateTime
BEFORE INSERT ON Reservations
FOR EACH ROW
BEGIN
    IF NEW.DateTime < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot make reservation in the past!';
    END IF;
END$$

DELIMITER ;

-- Kiem tra trigger hoat dong
SHOW TRIGGERS;

------------------------------------------------------------------------
-- PHẦN 2: DATABASE SECURITY 
-- -- Tao cac user
CREATE USER 'admin_user'@'localhost'   IDENTIFIED BY 'Admin@123';
CREATE USER 'cashier_user'@'localhost' IDENTIFIED BY 'Cashier@123';
CREATE USER 'waiter_user'@'localhost'  IDENTIFIED BY 'Waiter@123';

-- Admin: toan quyen
GRANT ALL PRIVILEGES ON Restaurant.* TO 'admin_user'@'localhost';

-- Cashier: xem + tao hoa don
GRANT SELECT, INSERT ON Restaurant.Invoices       TO 'cashier_user'@'localhost';
GRANT SELECT, INSERT ON Restaurant.InvoiceDetails TO 'cashier_user'@'localhost';
GRANT SELECT          ON Restaurant.Customers     TO 'cashier_user'@'localhost';
GRANT SELECT          ON Restaurant.MenuItems     TO 'cashier_user'@'localhost';
GRANT SELECT          ON Restaurant.`Tables`      TO 'cashier_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Restaurant.sp_GenerateInvoice TO 'cashier_user'@'localhost';

-- Waiter: xem menu + dat ban
GRANT SELECT          ON Restaurant.MenuItems     TO 'waiter_user'@'localhost';
GRANT SELECT          ON Restaurant.`Tables`      TO 'waiter_user'@'localhost';
GRANT SELECT, INSERT  ON Restaurant.Reservations  TO 'waiter_user'@'localhost';
GRANT EXECUTE ON PROCEDURE Restaurant.sp_MakeReservation TO 'waiter_user'@'localhost';

FLUSH PRIVILEGES;

-- Kiem tra quyen
SHOW GRANTS FOR 'cashier_user'@'localhost';
SHOW GRANTS FOR 'waiter_user'@'localhost';


