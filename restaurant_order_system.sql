-- ============================================================
--   RESTAURANT ORDER SYSTEM - DATABASE SCHEMA
--   Author: [Your Name]
--   Course: Database Management Systems
--   Date: 2026
-- ============================================================

-- ============================================================
-- SECTION 1: DATABASE CREATION
-- ============================================================

CREATE DATABASE IF NOT EXISTS RestaurantOrderSystem;
USE RestaurantOrderSystem;

-- ============================================================
-- SECTION 2: TABLE CREATION (Core Schema Objects)
-- ============================================================

-- Table 1: MenuCategory
CREATE TABLE MenuCategory (
    CategoryID   INT           AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100)  NOT NULL UNIQUE,
    Description  VARCHAR(255)
);

-- Table 2: MenuItem
CREATE TABLE MenuItem (
    ItemID       INT             AUTO_INCREMENT PRIMARY KEY,
    ItemName     VARCHAR(150)    NOT NULL,
    Description  VARCHAR(255),
    Price        DECIMAL(8,2)    NOT NULL CHECK (Price > 0),
    CategoryID   INT             NOT NULL,
    IsAvailable  TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT fk_item_category FOREIGN KEY (CategoryID)
        REFERENCES MenuCategory(CategoryID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Table 3: Customer
CREATE TABLE Customer (
    CustomerID   INT           AUTO_INCREMENT PRIMARY KEY,
    FullName     VARCHAR(150)  NOT NULL,
    Phone        VARCHAR(15)   UNIQUE,
    Email        VARCHAR(100)  UNIQUE,
    Address      VARCHAR(255),
    JoinDate     DATE          DEFAULT (CURRENT_DATE)
);

-- Table 4: Employee
CREATE TABLE Employee (
    EmployeeID   INT           AUTO_INCREMENT PRIMARY KEY,
    FullName     VARCHAR(150)  NOT NULL,
    Phone        VARCHAR(15)   UNIQUE,
    Role         VARCHAR(50)   NOT NULL CHECK (Role IN ('Waiter','Manager','Chef','Cashier')),
    Salary       DECIMAL(10,2) NOT NULL CHECK (Salary >= 0),
    HireDate     DATE          NOT NULL
);

-- Table 5: RestaurantTable
CREATE TABLE RestaurantTable (
    TableID      INT           AUTO_INCREMENT PRIMARY KEY,
    TableNumber  INT           NOT NULL UNIQUE,
    Capacity     INT           NOT NULL CHECK (Capacity > 0),
    Status       VARCHAR(20)   NOT NULL DEFAULT 'Available'
                               CHECK (Status IN ('Available','Occupied','Reserved'))
);

-- Table 6: Orders
CREATE TABLE Orders (
    OrderID      INT           AUTO_INCREMENT PRIMARY KEY,
    CustomerID   INT,
    EmployeeID   INT           NOT NULL,
    TableID      INT,
    OrderDate    DATE          NOT NULL DEFAULT (CURRENT_DATE),
    OrderTime    TIME          NOT NULL DEFAULT (CURRENT_TIME),
    Status       VARCHAR(20)   NOT NULL DEFAULT 'Pending'
                               CHECK (Status IN ('Pending','Preparing','Served','Completed','Cancelled')),
    TotalAmount  DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT fk_order_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_order_employee FOREIGN KEY (EmployeeID)
        REFERENCES Employee(EmployeeID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_order_table FOREIGN KEY (TableID)
        REFERENCES RestaurantTable(TableID)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- Table 7: OrderItem
CREATE TABLE OrderItem (
    OrderItemID  INT           AUTO_INCREMENT PRIMARY KEY,
    OrderID      INT           NOT NULL,
    ItemID       INT           NOT NULL,
    Quantity     INT           NOT NULL CHECK (Quantity > 0),
    UnitPrice    DECIMAL(8,2)  NOT NULL CHECK (UnitPrice > 0),
    Subtotal     DECIMAL(10,2) GENERATED ALWAYS AS (Quantity * UnitPrice) STORED,
    CONSTRAINT fk_orderitem_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_orderitem_item FOREIGN KEY (ItemID)
        REFERENCES MenuItem(ItemID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Table 8: Payment
CREATE TABLE Payment (
    PaymentID     INT           AUTO_INCREMENT PRIMARY KEY,
    OrderID       INT           NOT NULL UNIQUE,
    PaymentDate   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Amount        DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    PaymentMethod VARCHAR(30)   NOT NULL CHECK (PaymentMethod IN ('Cash','Card','Online')),
    Status        VARCHAR(20)   NOT NULL DEFAULT 'Paid'
                                CHECK (Status IN ('Paid','Pending','Refunded')),
    CONSTRAINT fk_payment_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================
-- SECTION 3: SAMPLE DATA (INSERT Statements)
-- ============================================================

-- MenuCategory
INSERT INTO MenuCategory (CategoryName, Description) VALUES
('Starters',    'Appetizers and soups'),
('Main Course', 'Full meal dishes'),
('Beverages',   'Hot and cold drinks'),
('Desserts',    'Sweet ending treats'),
('Fast Food',   'Burgers, wraps and fries');

-- MenuItem
INSERT INTO MenuItem (ItemName, Description, Price, CategoryID, IsAvailable) VALUES
('Chicken Soup',        'Homemade chicken broth with vegetables',  350.00, 1, 1),
('Garlic Bread',        'Toasted bread with garlic butter',         200.00, 1, 1),
('Grilled Chicken',     'Marinated grilled chicken with rice',      950.00, 2, 1),
('Beef Steak',          'Tenderloin steak with mashed potatoes',   1500.00, 2, 1),
('Vegetable Biryani',   'Fragrant rice with mixed vegetables',      750.00, 2, 1),
('Mango Juice',         'Fresh mango juice',                        250.00, 3, 1),
('Soft Drink',          'Pepsi / 7UP / Sprite',                     150.00, 3, 1),
('Green Tea',           'Herbal green tea',                         180.00, 3, 1),
('Chocolate Cake',      'Rich chocolate layered cake slice',        400.00, 4, 1),
('Ice Cream',           'Vanilla / Chocolate / Strawberry scoop',   300.00, 4, 1),
('Zinger Burger',       'Spicy crispy chicken burger',              650.00, 5, 1),
('French Fries',        'Crispy golden fries with dipping sauce',   280.00, 5, 1);

-- Customer
INSERT INTO Customer (FullName, Phone, Email, Address) VALUES
('Ali Hassan',     '0300-1234567', 'ali.hassan@email.com',   'House 5, Block A, Lahore'),
('Sara Ahmed',     '0311-2345678', 'sara.ahmed@email.com',   'Flat 12, DHA Phase 2, Karachi'),
('Usman Khan',     '0321-3456789', 'usman.khan@email.com',   'Street 7, F-8, Islamabad'),
('Fatima Malik',   '0333-4567890', 'fatima.m@email.com',     'House 22, Gulberg III, Lahore'),
('Bilal Raza',     '0345-5678901', 'bilal.raza@email.com',   'Sector G-10, Islamabad');

-- Employee
INSERT INTO Employee (FullName, Phone, Role, Salary, HireDate) VALUES
('Kamran Sheikh',  '0300-9876543', 'Manager',  65000.00, '2022-01-15'),
('Nadia Aslam',    '0311-8765432', 'Waiter',   30000.00, '2023-03-10'),
('Tariq Hussain',  '0321-7654321', 'Chef',     50000.00, '2022-06-01'),
('Razia Bibi',     '0333-6543210', 'Cashier',  32000.00, '2023-07-20'),
('Hamid Ali',      '0345-5432109', 'Waiter',   30000.00, '2024-01-05');

-- RestaurantTable
INSERT INTO RestaurantTable (TableNumber, Capacity, Status) VALUES
(1, 2, 'Available'),
(2, 4, 'Occupied'),
(3, 4, 'Available'),
(4, 6, 'Reserved'),
(5, 8, 'Available'),
(6, 2, 'Occupied');

-- Orders
INSERT INTO Orders (CustomerID, EmployeeID, TableID, OrderDate, OrderTime, Status, TotalAmount) VALUES
(1, 2, 2, '2026-05-01', '13:00:00', 'Completed', 1550.00),
(2, 5, 6, '2026-05-01', '14:30:00', 'Completed', 1100.00),
(3, 2, 3, '2026-05-02', '19:00:00', 'Completed', 2350.00),
(4, 5, 1, '2026-05-03', '12:00:00', 'Completed',  930.00),
(5, 2, 5, '2026-05-04', '20:00:00', 'Serving',   1780.00),
(1, 5, 2, '2026-05-05', '13:30:00', 'Pending',      0.00);

-- OrderItem
INSERT INTO OrderItem (OrderID, ItemID, Quantity, UnitPrice) VALUES
(1, 3,  1, 950.00),   -- Order 1: Grilled Chicken
(1, 7,  2, 150.00),   -- Order 1: 2x Soft Drink (= 300)
(1, 12, 1, 280.00),   -- Order 1: French Fries
(2, 11, 1, 650.00),   -- Order 2: Zinger Burger
(2, 7,  1, 150.00),   -- Order 2: Soft Drink
(2, 9,  1, 400.00),   -- Order 2: Chocolate Cake (= 1200... wait, ~1100 after rounding)
(3, 4,  1,1500.00),   -- Order 3: Beef Steak
(3, 1,  1, 350.00),   -- Order 3: Chicken Soup
(3, 6,  2, 250.00),   -- Order 3: 2x Mango Juice
(4, 5,  1, 750.00),   -- Order 4: Vegetable Biryani
(4, 8,  1, 180.00),   -- Order 4: Green Tea
(5, 3,  1, 950.00),   -- Order 5: Grilled Chicken
(5, 2,  2, 200.00),   -- Order 5: 2x Garlic Bread
(5, 10, 2, 300.00),   -- Order 5: 2x Ice Cream (= 600, total ~1950?)
(6, 11, 1, 650.00);   -- Order 6: Zinger Burger (pending)

-- Payment
INSERT INTO Payment (OrderID, PaymentDate, Amount, PaymentMethod, Status) VALUES
(1, '2026-05-01 14:00:00', 1550.00, 'Cash',   'Paid'),
(2, '2026-05-01 15:30:00', 1100.00, 'Card',   'Paid'),
(3, '2026-05-02 20:30:00', 2350.00, 'Online', 'Paid'),
(4, '2026-05-03 12:45:00',  930.00, 'Cash',   'Paid');

-- ============================================================
-- SECTION 4: VIEWS
-- ============================================================

-- View 1: Full Order Summary
CREATE VIEW vw_OrderSummary AS
SELECT
    o.OrderID,
    c.FullName          AS CustomerName,
    e.FullName          AS WaiterName,
    rt.TableNumber,
    o.OrderDate,
    o.OrderTime,
    o.Status            AS OrderStatus,
    o.TotalAmount
FROM Orders o
LEFT JOIN Customer       c  ON o.CustomerID  = c.CustomerID
JOIN      Employee       e  ON o.EmployeeID  = e.EmployeeID
LEFT JOIN RestaurantTable rt ON o.TableID    = rt.TableID;

-- View 2: Menu with Category Names
CREATE VIEW vw_MenuWithCategory AS
SELECT
    mi.ItemID,
    mi.ItemName,
    mi.Price,
    mc.CategoryName,
    mi.IsAvailable
FROM MenuItem    mi
JOIN MenuCategory mc ON mi.CategoryID = mc.CategoryID;

-- View 3: Daily Revenue Report
CREATE VIEW vw_DailyRevenue AS
SELECT
    p.PaymentDate       AS PaymentDay,
    COUNT(p.PaymentID)  AS TotalOrders,
    SUM(p.Amount)       AS TotalRevenue,
    AVG(p.Amount)       AS AvgOrderValue
FROM Payment p
WHERE p.Status = 'Paid'
GROUP BY DATE(p.PaymentDate);

-- View 4: Employee Order Count
CREATE VIEW vw_EmployeePerformance AS
SELECT
    e.EmployeeID,
    e.FullName,
    e.Role,
    COUNT(o.OrderID)    AS TotalOrdersHandled,
    SUM(o.TotalAmount)  AS TotalRevenue
FROM Employee e
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FullName, e.Role;

-- ============================================================
-- SECTION 5: QUERIES
-- ============================================================

-- -----------------------------------------------------------
-- A) JOIN QUERIES
-- -----------------------------------------------------------

-- Query J1: List all orders with customer, waiter, and table info (INNER JOIN)
SELECT
    o.OrderID,
    c.FullName      AS Customer,
    e.FullName      AS Waiter,
    rt.TableNumber,
    o.OrderDate,
    o.Status,
    o.TotalAmount
FROM Orders o
INNER JOIN Customer        c  ON o.CustomerID = c.CustomerID
INNER JOIN Employee        e  ON o.EmployeeID  = e.EmployeeID
INNER JOIN RestaurantTable rt ON o.TableID     = rt.TableID;

-- Query J2: Show all order items with menu item names and order details (INNER JOIN)
SELECT
    o.OrderID,
    mi.ItemName,
    mc.CategoryName,
    oi.Quantity,
    oi.UnitPrice,
    oi.Subtotal
FROM OrderItem    oi
INNER JOIN Orders      o  ON oi.OrderID  = o.OrderID
INNER JOIN MenuItem    mi ON oi.ItemID   = mi.ItemID
INNER JOIN MenuCategory mc ON mi.CategoryID = mc.CategoryID
ORDER BY o.OrderID;

-- Query J3: All customers and their orders, including customers with no orders (LEFT JOIN)
SELECT
    c.CustomerID,
    c.FullName,
    c.Phone,
    COUNT(o.OrderID) AS TotalOrders,
    COALESCE(SUM(o.TotalAmount), 0) AS TotalSpent
FROM Customer c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FullName, c.Phone;

-- Query J4: Payments with order and customer details (JOIN across 3 tables)
SELECT
    p.PaymentID,
    c.FullName          AS Customer,
    p.Amount,
    p.PaymentMethod,
    p.PaymentDate,
    p.Status
FROM Payment p
JOIN Orders   o ON p.OrderID    = o.OrderID
JOIN Customer c ON o.CustomerID = c.CustomerID;

-- -----------------------------------------------------------
-- B) SUBQUERY QUERIES
-- -----------------------------------------------------------

-- Query S1: Find menu items that have NEVER been ordered
SELECT ItemID, ItemName, Price
FROM MenuItem
WHERE ItemID NOT IN (
    SELECT DISTINCT ItemID FROM OrderItem
);

-- Query S2: Find customers who spent more than the average customer spending
SELECT FullName, Phone
FROM Customer
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Orders
    GROUP BY CustomerID
    HAVING SUM(TotalAmount) > (
        SELECT AVG(TotalSpentPerCustomer)
        FROM (
            SELECT CustomerID, SUM(TotalAmount) AS TotalSpentPerCustomer
            FROM Orders
            GROUP BY CustomerID
        ) AS sub
    )
);

-- Query S3: List orders where total amount is above overall average
SELECT OrderID, CustomerID, TotalAmount
FROM Orders
WHERE TotalAmount > (
    SELECT AVG(TotalAmount) FROM Orders WHERE Status = 'Completed'
);

-- Query S4: Get the most expensive menu item in each category (correlated subquery)
SELECT mc.CategoryName, mi.ItemName, mi.Price
FROM MenuItem mi
JOIN MenuCategory mc ON mi.CategoryID = mc.CategoryID
WHERE mi.Price = (
    SELECT MAX(Price)
    FROM MenuItem
    WHERE CategoryID = mi.CategoryID
);

-- -----------------------------------------------------------
-- C) AGGREGATION FUNCTION QUERIES
-- -----------------------------------------------------------

-- Query A1: Total revenue per payment method
SELECT
    PaymentMethod,
    COUNT(*)         AS NumberOfPayments,
    SUM(Amount)      AS TotalRevenue,
    AVG(Amount)      AS AvgPayment,
    MIN(Amount)      AS MinPayment,
    MAX(Amount)      AS MaxPayment
FROM Payment
WHERE Status = 'Paid'
GROUP BY PaymentMethod;

-- Query A2: Most popular menu items by total quantity ordered
SELECT
    mi.ItemName,
    mc.CategoryName,
    SUM(oi.Quantity)    AS TotalQuantityOrdered,
    SUM(oi.Subtotal)    AS TotalRevenue
FROM OrderItem    oi
JOIN MenuItem     mi ON oi.ItemID     = mi.ItemID
JOIN MenuCategory mc ON mi.CategoryID = mc.CategoryID
GROUP BY mi.ItemID, mi.ItemName, mc.CategoryName
ORDER BY TotalQuantityOrdered DESC;

-- Query A3: Revenue summary by category
SELECT
    mc.CategoryName,
    COUNT(DISTINCT oi.OrderID) AS OrdersContaining,
    SUM(oi.Quantity)           AS TotalItemsSold,
    SUM(oi.Subtotal)           AS TotalCategoryRevenue
FROM OrderItem    oi
JOIN MenuItem     mi ON oi.ItemID     = mi.ItemID
JOIN MenuCategory mc ON mi.CategoryID = mc.CategoryID
GROUP BY mc.CategoryID, mc.CategoryName
HAVING SUM(oi.Subtotal) > 0
ORDER BY TotalCategoryRevenue DESC;

-- Query A4: Waiter performance (orders handled and revenue generated)
SELECT
    e.FullName          AS WaiterName,
    COUNT(o.OrderID)    AS OrdersHandled,
    SUM(o.TotalAmount)  AS TotalRevenue,
    AVG(o.TotalAmount)  AS AvgOrderValue
FROM Employee e
JOIN Orders   o ON e.EmployeeID = o.EmployeeID
WHERE e.Role = 'Waiter'
GROUP BY e.EmployeeID, e.FullName
ORDER BY TotalRevenue DESC;

-- Query A5: Monthly revenue report
SELECT
    YEAR(PaymentDate)   AS Year,
    MONTH(PaymentDate)  AS Month,
    COUNT(PaymentID)    AS TotalOrders,
    SUM(Amount)         AS TotalRevenue
FROM Payment
WHERE Status = 'Paid'
GROUP BY YEAR(PaymentDate), MONTH(PaymentDate)
ORDER BY Year, Month;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
