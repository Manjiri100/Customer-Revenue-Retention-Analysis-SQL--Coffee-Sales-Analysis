-- CUSTOMER REVENUE & RETENTION ANALYSIS
-- Monday Coffee Sales Analysis using SQL

-- PROJECT OBJECTIVE
-- Analyze sales data to find top Indian cities for coffee shop expansion
-- based on revenue, customers, orders, and product demand

-- DATABASE CREATION
CREATE DATABASE MondayCoffeeDB;
USE MondayCoffeeDB;

-- TABLE: CUSTOMERS
CREATE TABLE Customers (
CustomerID INT PRIMARY KEY AUTO_INCREMENT,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Email VARCHAR(100) UNIQUE NOT NULL,
PhoneNumber VARCHAR(20),
Address VARCHAR(255),
City VARCHAR(50),
Country VARCHAR(50),
CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLE: PRODUCTS
CREATE TABLE Products (
ProductID INT PRIMARY KEY AUTO_INCREMENT,
ProductName VARCHAR(100) NOT NULL,
Category VARCHAR(50),
Price DECIMAL(10,2) NOT NULL,
StockQuantity INT DEFAULT 0,
CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLE: SALES
CREATE TABLE Sales (
SaleID INT PRIMARY KEY AUTO_INCREMENT,
CustomerID INT,
ProductID INT,
Quantity INT NOT NULL,
SaleDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
TotalAmount DECIMAL(10,2),
Rating DECIMAL(3,2),
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- TRIGGER: AUTO CALCULATE TOTAL AMOUNT
DELIMITER //

CREATE TRIGGER trg_Calculate_TotalAmount
BEFORE INSERT ON Sales
FOR EACH ROW
BEGIN
DECLARE product_price DECIMAL(10,2);

SELECT Price
INTO product_price
FROM Products
WHERE ProductID = NEW.ProductID;

SET NEW.TotalAmount = NEW.Quantity * product_price;
END //

DELIMITER ;

-- NULL CHECK: CUSTOMERS
SELECT
SUM(CASE WHEN FirstName IS NULL THEN 1 ELSE 0 END) AS Null_FirstName,
SUM(CASE WHEN LastName IS NULL THEN 1 ELSE 0 END) AS Null_LastName,
SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END) AS Null_Email,
SUM(CASE WHEN PhoneNumber IS NULL THEN 1 ELSE 0 END) AS Null_Phone
FROM Customers;

-- NULL CHECK: SALES
SELECT *
FROM Sales
WHERE CustomerID IS NULL
OR ProductID IS NULL
OR Quantity IS NULL;

-- DUPLICATE CHECK
SELECT Email,
FirstName,
LastName,
COUNT(*) AS DuplicateCount
FROM Customers
GROUP BY Email, FirstName, LastName
HAVING COUNT(*) > 1;

-- DATA VALIDATION
SELECT s.SaleID,
s.TotalAmount,
(p.Price * s.Quantity) AS ExpectedAmount
FROM Sales s
JOIN Products p
ON s.ProductID = p.ProductID
WHERE s.TotalAmount <> (p.Price * s.Quantity);

-- SALES REPORT
SELECT s.SaleID,
s.SaleDate,
c.CustomerID,
c.FirstName,
c.LastName,
c.Email,
c.City,
p.ProductName,
p.Category,
s.Quantity,
p.Price,
(s.Quantity * p.Price) AS CalculatedAmount,
s.TotalAmount
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
JOIN Products p
ON s.ProductID = p.ProductID;

-- TOTAL SALES BY CITY
SELECT c.City,
SUM(s.TotalAmount) AS TotalSales
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY TotalSales DESC;

-- TOTAL TRANSACTIONS BY CITY
SELECT c.City,
COUNT(s.SaleID) AS TotalTransactions
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City;

-- UNIQUE CUSTOMERS BY CITY
SELECT c.City,
COUNT(DISTINCT s.CustomerID) AS UniqueCustomers
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City;

-- AVERAGE ORDER VALUE BY CITY
SELECT c.City,
AVG(s.TotalAmount) AS AvgOrderValue
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City;

-- PRODUCT DEMAND BY CITY
SELECT c.City,
p.ProductName,
SUM(s.Quantity) AS TotalDemand
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
JOIN Products p
ON s.ProductID = p.ProductID
GROUP BY c.City, p.ProductName;

-- MONTHLY SALES TREND
SELECT DATE_FORMAT(SaleDate, '%Y-%m') AS SalesMonth,
SUM(TotalAmount) AS MonthlySales
FROM Sales
GROUP BY DATE_FORMAT(SaleDate, '%Y-%m')
ORDER BY SalesMonth;

-- CUSTOMER RATING ANALYSIS
SELECT c.City,
AVG(s.Rating) AS AvgRating
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City;

-- TOP 3 CITIES BY SALES
SELECT c.City,
SUM(s.TotalAmount) AS TotalSales
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY TotalSales DESC
LIMIT 3;

-- TOP 3 CITIES BY CUSTOMERS
SELECT c.City,
COUNT(DISTINCT s.CustomerID) AS UniqueCustomers
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY UniqueCustomers DESC
LIMIT 3;

-- TOP 3 CITIES BY ORDERS
SELECT c.City,
COUNT(s.SaleID) AS TotalOrders
FROM Sales s
JOIN Customers c
ON s.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY TotalOrders DESC
LIMIT 3;

-- FINAL INSIGHTS
-- Expand in top cities with high sales and customers
-- Optimize product mix based on demand
-- Introduce loyalty programs
-- Improve inventory planning using trends
-- Track ratings for customer experience improvement
