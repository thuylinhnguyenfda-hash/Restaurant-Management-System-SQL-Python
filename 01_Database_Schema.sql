-- ============================================
-- BƯỚC 1: TẠO DATABASE
-- ============================================
CREATE DATABASE IF NOT EXISTS Restaurant
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE Restaurant;

-- ============================================
-- BƯỚC 2: TẠO CÁC BẢNG (đúng thứ tự - bảng cha trước, bảng con sau)
-- ============================================

-- BẢNG 1: Customers
CREATE TABLE Customers (
    CustomerID   INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    PhoneNumber  VARCHAR(15)  NOT NULL UNIQUE,
    Address      VARCHAR(255)
);

-- BẢNG 2: Tables
CREATE TABLE Tables (
    TableID      INT AUTO_INCREMENT PRIMARY KEY,
    TableNumber  VARCHAR(10)  NOT NULL UNIQUE,
    Status       ENUM('available', 'reserved', 'occupied') DEFAULT 'available'
);

-- BẢNG 3: MenuItems
CREATE TABLE MenuItems (
    DishID       INT AUTO_INCREMENT PRIMARY KEY,
    DishName     VARCHAR(100) NOT NULL,
    Price        DECIMAL(10,2) NOT NULL CHECK (Price >= 0)
);

-- BẢNG 4: Reservations (FK -> Customers, Tables)
CREATE TABLE Reservations (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID    INT      NOT NULL,
    TableID       INT      NOT NULL,
    DateTime      DATETIME NOT NULL,
    GuestCount    INT      NOT NULL CHECK (GuestCount > 0),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (TableID) REFERENCES Tables(TableID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- BẢNG 5: Invoices (FK -> Customers, Tables)
CREATE TABLE Invoices (
    InvoiceID     INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID    INT           NOT NULL,
    TableID       INT           NOT NULL,
    TotalAmount   DECIMAL(10,2) DEFAULT 0,
    PaymentDate   DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (TableID) REFERENCES Tables(TableID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- BẢNG 6: InvoiceDetails (FK -> Invoices, MenuItems)
CREATE TABLE InvoiceDetails (
    DetailID    INT AUTO_INCREMENT PRIMARY KEY,
    InvoiceID   INT           NOT NULL,
    DishID      INT           NOT NULL,
    Quantity    INT           NOT NULL CHECK (Quantity > 0),
    UnitPrice   DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (DishID) REFERENCES MenuItems(DishID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Customers
INSERT INTO Customers VALUES
(1, 'Nguyen Van An',   '0901234567', '12 Nguyen Hue, Quan 1, TP. HCM'),
(2, 'Tran Thi Bich',   '0912345678', '45 Le Loi, Hoan Kiem, Ha Noi'),
(3, 'Le Van Cuong',    '0923456789', '78 Tran Hung Dao, Hai Chau, Da Nang'),
(4, 'Pham Thi Dung',   '0934567890', '23 Ly Thuong Kiet, Dong Da, Ha Noi'),
(5, 'Hoang Van Minh',  '0945678901', '56 Pham Ngu Lao, Quan 1, TP. HCM');

-- Tables
INSERT INTO `Tables` VALUES
(1, 'T001', 'available'),
(2, 'T002', 'reserved'),
(3, 'T003', 'available'),
(4, 'T004', 'occupied'),
(5, 'T005', 'available');

-- MenuItems
INSERT INTO MenuItems VALUES
(1, 'Pho Bo Truyen Thong',  65000),
(2, 'Com Tam Suon Nuong',   55000),
(3, 'Goi Cuon Tom Thit',    45000),
(4, 'Lau Thai Chua Cay',   180000),
(5, 'Ca Phe Sua Da',        30000);

-- Reservations
INSERT INTO Reservations VALUES
(1, 1, 2, '2026-05-10 18:00:00', 3),
(2, 2, 3, '2026-05-10 19:00:00', 2),
(3, 3, 5, '2026-05-11 12:00:00', 4),
(4, 4, 1, '2026-05-11 18:30:00', 5),
(5, 5, 4, '2026-05-12 19:00:00', 6);

-- Invoices
INSERT INTO Invoices VALUES
(1, 1, 2, 175000, '2026-04-28 20:00:00'),
(2, 2, 3, 220000, '2026-04-29 21:00:00'),
(3, 3, 5, 130000, '2026-04-30 14:00:00'),
(4, 4, 1, 360000, '2026-05-01 20:30:00'),
(5, 5, 4,  95000, '2026-05-02 21:00:00');

-- InvoiceDetails
INSERT INTO InvoiceDetails VALUES
(1, 1, 1, 2, 65000),
(2, 1, 3, 1, 45000),
(3, 2, 2, 3, 55000),
(4, 3, 5, 2, 30000),
(5, 4, 4, 2, 180000);