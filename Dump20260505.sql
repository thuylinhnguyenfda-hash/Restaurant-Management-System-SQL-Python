CREATE DATABASE  IF NOT EXISTS `restaurant` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `restaurant`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: restaurant
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `CustomerID` int NOT NULL AUTO_INCREMENT,
  `CustomerName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PhoneNumber` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`CustomerID`),
  UNIQUE KEY `PhoneNumber` (`PhoneNumber`),
  KEY `idx_customer_phone` (`PhoneNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Nguyen Van An','0901234567','12 Nguyen Hue, Quan 1, TP. HCM'),(2,'Tran Thi Bich','0912345678','45 Le Loi, Hoan Kiem, Ha Noi'),(3,'Le Van Cuong','0923456789','78 Tran Hung Dao, Hai Chau, Da Nang'),(4,'Pham Thi Dung','0934567890','23 Ly Thuong Kiet, Dong Da, Ha Noi'),(5,'Hoang Van Minh','0945678901','56 Pham Ngu Lao, Quan 1, TP. HCM'),(6,'Nguyễn Thị Thùy Linh','0984114894','Đà Nẵng');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoicedetails`
--

DROP TABLE IF EXISTS `invoicedetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoicedetails` (
  `DetailID` int NOT NULL AUTO_INCREMENT,
  `InvoiceID` int NOT NULL,
  `DishID` int NOT NULL,
  `Quantity` int NOT NULL,
  `UnitPrice` decimal(10,2) NOT NULL,
  PRIMARY KEY (`DetailID`),
  KEY `InvoiceID` (`InvoiceID`),
  KEY `DishID` (`DishID`),
  CONSTRAINT `invoicedetails_ibfk_1` FOREIGN KEY (`InvoiceID`) REFERENCES `invoices` (`InvoiceID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `invoicedetails_ibfk_2` FOREIGN KEY (`DishID`) REFERENCES `menuitems` (`DishID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `invoicedetails_chk_1` CHECK ((`Quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoicedetails`
--

LOCK TABLES `invoicedetails` WRITE;
/*!40000 ALTER TABLE `invoicedetails` DISABLE KEYS */;
INSERT INTO `invoicedetails` VALUES (1,1,1,2,65000.00),(2,1,3,1,45000.00),(3,2,2,3,55000.00),(4,3,5,2,30000.00),(5,4,4,2,180000.00),(6,7,1,1,65000.00),(7,7,2,2,55000.00),(8,7,6,2,92000.00);
/*!40000 ALTER TABLE `invoicedetails` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_UpdateInvoiceTotal` AFTER INSERT ON `invoicedetails` FOR EACH ROW BEGIN
    UPDATE Invoices
    SET TotalAmount = (
        SELECT SUM(Quantity * UnitPrice)
        FROM InvoiceDetails
        WHERE InvoiceID = NEW.InvoiceID
    )
    WHERE InvoiceID = NEW.InvoiceID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `InvoiceID` int NOT NULL AUTO_INCREMENT,
  `CustomerID` int NOT NULL,
  `TableID` int NOT NULL,
  `TotalAmount` decimal(10,2) DEFAULT '0.00',
  `PaymentDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`InvoiceID`),
  KEY `CustomerID` (`CustomerID`),
  KEY `TableID` (`TableID`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`TableID`) REFERENCES `tables` (`TableID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,1,2,175000.00,'2026-04-28 20:00:00'),(2,2,3,220000.00,'2026-04-29 21:00:00'),(3,3,5,130000.00,'2026-04-30 14:00:00'),(4,4,1,360000.00,'2026-05-01 20:30:00'),(5,5,4,95000.00,'2026-05-02 21:00:00'),(7,6,6,359000.00,'2026-05-04 16:21:12'),(8,1,1,0.00,'2026-05-05 00:13:53'),(9,1,1,0.00,'2026-05-05 00:16:30');
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_AfterInsertInvoice` AFTER INSERT ON `invoices` FOR EACH ROW BEGIN
    UPDATE `Tables`
    SET Status = 'available'
    WHERE TableID = NEW.TableID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `menuitems`
--

DROP TABLE IF EXISTS `menuitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menuitems` (
  `DishID` int NOT NULL AUTO_INCREMENT,
  `DishName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`DishID`),
  KEY `idx_dish_name` (`DishName`),
  CONSTRAINT `menuitems_chk_1` CHECK ((`Price` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menuitems`
--

LOCK TABLES `menuitems` WRITE;
/*!40000 ALTER TABLE `menuitems` DISABLE KEYS */;
INSERT INTO `menuitems` VALUES (1,'Pho Bo Truyen Thong',65000.00),(2,'Com Tam Suon Nuong',55000.00),(3,'Goi Cuon Tom Thit',45000.00),(4,'Lau Thai Chua Cay',180000.00),(5,'Ca Phe Sua Da',30000.00),(6,'Bò xá xíu',92000.00);
/*!40000 ALTER TABLE `menuitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations` (
  `ReservationID` int NOT NULL AUTO_INCREMENT,
  `CustomerID` int NOT NULL,
  `TableID` int NOT NULL,
  `DateTime` datetime NOT NULL,
  `GuestCount` int NOT NULL,
  PRIMARY KEY (`ReservationID`),
  KEY `TableID` (`TableID`),
  KEY `idx_reservation_datetime` (`DateTime`),
  KEY `idx_reservation_customer` (`CustomerID`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`TableID`) REFERENCES `tables` (`TableID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `reservations_chk_1` CHECK ((`GuestCount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
INSERT INTO `reservations` VALUES (1,1,2,'2026-05-10 18:00:00',3),(2,2,3,'2026-05-10 19:00:00',2),(3,3,5,'2026-05-11 12:00:00',4),(4,4,1,'2026-05-11 18:30:00',5),(5,5,4,'2026-05-12 19:00:00',6),(7,6,6,'2026-05-04 16:20:00',2),(8,1,1,'2026-05-15 18:00:00',4);
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_ValidateDateTime` BEFORE INSERT ON `reservations` FOR EACH ROW BEGIN
    IF NEW.DateTime < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot make reservation in the past!';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_AfterInsertReservation` AFTER INSERT ON `reservations` FOR EACH ROW BEGIN
    UPDATE `Tables`
    SET Status = 'reserved'
    WHERE TableID = NEW.TableID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tables`
--

DROP TABLE IF EXISTS `tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tables` (
  `TableID` int NOT NULL AUTO_INCREMENT,
  `TableNumber` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Status` enum('available','reserved','occupied') COLLATE utf8mb4_unicode_ci DEFAULT 'available',
  PRIMARY KEY (`TableID`),
  UNIQUE KEY `TableNumber` (`TableNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tables`
--

LOCK TABLES `tables` WRITE;
/*!40000 ALTER TABLE `tables` DISABLE KEYS */;
INSERT INTO `tables` VALUES (1,'T001','available'),(2,'T002','reserved'),(3,'T003','available'),(4,'T004','occupied'),(5,'T005','available'),(6,'T006','available');
/*!40000 ALTER TABLE `tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_availabletables`
--

DROP TABLE IF EXISTS `vw_availabletables`;
/*!50001 DROP VIEW IF EXISTS `vw_availabletables`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_availabletables` AS SELECT 
 1 AS `TableID`,
 1 AS `TableNumber`,
 1 AS `Status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_dailyrevenue`
--

DROP TABLE IF EXISTS `vw_dailyrevenue`;
/*!50001 DROP VIEW IF EXISTS `vw_dailyrevenue`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_dailyrevenue` AS SELECT 
 1 AS `RevenueDate`,
 1 AS `TotalInvoices`,
 1 AS `TotalRevenue`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_todayreservations`
--

DROP TABLE IF EXISTS `vw_todayreservations`;
/*!50001 DROP VIEW IF EXISTS `vw_todayreservations`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_todayreservations` AS SELECT 
 1 AS `ReservationID`,
 1 AS `CustomerName`,
 1 AS `PhoneNumber`,
 1 AS `TableNumber`,
 1 AS `DateTime`,
 1 AS `GuestCount`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_topsellingdishes`
--

DROP TABLE IF EXISTS `vw_topsellingdishes`;
/*!50001 DROP VIEW IF EXISTS `vw_topsellingdishes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_topsellingdishes` AS SELECT 
 1 AS `DishID`,
 1 AS `DishName`,
 1 AS `Price`,
 1 AS `TotalSold`,
 1 AS `TotalRevenue`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'restaurant'
--

--
-- Dumping routines for database 'restaurant'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_ServiceCharge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_ServiceCharge`(p_Amount DECIMAL(10,2)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    RETURN p_Amount * 0.05;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_TotalWithTax` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_TotalWithTax`(p_Amount DECIMAL(10,2)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_service DECIMAL(10,2);
    DECLARE v_vat     DECIMAL(10,2);
    SET v_service = p_Amount * 0.05;
    SET v_vat     = (p_Amount + v_service) * 0.08;
    RETURN p_Amount + v_service + v_vat;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GenerateInvoice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GenerateInvoice`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_MakeReservation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_MakeReservation`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_availabletables`
--

/*!50001 DROP VIEW IF EXISTS `vw_availabletables`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_availabletables` AS select `tables`.`TableID` AS `TableID`,`tables`.`TableNumber` AS `TableNumber`,`tables`.`Status` AS `Status` from `tables` where (`tables`.`Status` = 'available') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_dailyrevenue`
--

/*!50001 DROP VIEW IF EXISTS `vw_dailyrevenue`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_dailyrevenue` AS select cast(`invoices`.`PaymentDate` as date) AS `RevenueDate`,count(`invoices`.`InvoiceID`) AS `TotalInvoices`,sum(`invoices`.`TotalAmount`) AS `TotalRevenue` from `invoices` group by cast(`invoices`.`PaymentDate` as date) order by `RevenueDate` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_todayreservations`
--

/*!50001 DROP VIEW IF EXISTS `vw_todayreservations`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_todayreservations` AS select `r`.`ReservationID` AS `ReservationID`,`c`.`CustomerName` AS `CustomerName`,`c`.`PhoneNumber` AS `PhoneNumber`,`t`.`TableNumber` AS `TableNumber`,`r`.`DateTime` AS `DateTime`,`r`.`GuestCount` AS `GuestCount` from ((`reservations` `r` join `customers` `c` on((`r`.`CustomerID` = `c`.`CustomerID`))) join `tables` `t` on((`r`.`TableID` = `t`.`TableID`))) where (cast(`r`.`DateTime` as date) = curdate()) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_topsellingdishes`
--

/*!50001 DROP VIEW IF EXISTS `vw_topsellingdishes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_topsellingdishes` AS select `m`.`DishID` AS `DishID`,`m`.`DishName` AS `DishName`,`m`.`Price` AS `Price`,sum(`d`.`Quantity`) AS `TotalSold`,sum((`d`.`Quantity` * `d`.`UnitPrice`)) AS `TotalRevenue` from (`invoicedetails` `d` join `menuitems` `m` on((`d`.`DishID` = `m`.`DishID`))) group by `m`.`DishID`,`m`.`DishName`,`m`.`Price` order by `TotalSold` desc limit 5 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-05  6:40:05
