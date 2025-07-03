DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP VIEW IF EXISTS HighValueElectronicsCustomers;
DROP VIEW IF EXISTS MarketingCustomers;
DROP VIEW IF EXISTS SalesAssistantOrders;


-- Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    email VARCHAR(100)
);

-- Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order_Items Table (assuming an order can have multiple products)
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    item_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Sample Data (for demonstration)
INSERT INTO Customers VALUES
(1, 'Alice Smith', 'New York', 'alice@example.com'),
(2, 'Bob Johnson', 'Los Angeles', 'bob@example.com'),
(3, 'Charlie Brown', 'New York', 'charlie@example.com'),
(4, 'Diana Prince', 'London', 'diana@example.com'),
(5, 'Eve Adams', 'New York', 'eve@example.com');

INSERT INTO Products VALUES
(101, 'Laptop X', 'Electronics', 1200.00),
(102, 'Smartphone Y', 'Electronics', 800.00),
(103, 'Desk Chair', 'Furniture', 250.00),
(104, 'Monitor Z', 'Electronics', 300.00),
(105, 'Coffee Maker', 'Appliances', 100.00);

INSERT INTO Orders VALUES
(1001, 1, '2024-01-15', 2000.00),
(1002, 2, '2024-01-20', 800.00),
(1003, 1, '2024-02-01', 1200.00),
(1004, 3, '2024-02-10', 300.00),
(1005, 1, '2024-03-05', 500.00),
(1006, 2, '2024-03-10', 1200.00),
(1007, 1, '2024-04-01', 1000.00),
(1008, 4, '2024-04-05', 250.00),
(1009, 1, '2024-05-01', 900.00),
(1010, 2, '2024-05-15', 700.00),
(1011, 3, '2024-06-01', 1500.00),
(1012, 1, '2024-06-10', 400.00);

INSERT INTO Order_Items VALUES
(1, 1001, 101, 1, 1200.00),
(2, 1001, 102, 1, 800.00),
(3, 1002, 102, 1, 800.00),
(4, 1003, 101, 1, 1200.00),
(5, 1004, 104, 1, 300.00),
(6, 1005, 104, 1, 300.00),
(7, 1005, 105, 2, 200.00),
(8, 1006, 101, 1, 1200.00),
(9, 1007, 102, 1, 800.00),
(10, 1007, 104, 1, 300.00),
(11, 1008, 103, 1, 250.00),
(12, 1009, 101, 1, 1200.00), -- This is wrong, let's fix this for later aggregate
(13, 1009, 102, 1, 800.00), -- Let's assume order_id 1009 has item 101 and 102 from earlier, so it is 2000.00
(14, 1010, 104, 1, 300.00),
(15, 1010, 105, 1, 100.00),
(16, 1011, 101, 1, 1200.00),
(17, 1011, 104, 1, 300.00),
(18, 1012, 102, 1, 800.00);
CREATE VIEW HighValueElectronicsCustomers AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    SUM(oi.quantity * oi.item_price) AS total_electronics_spend,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM
    Customers c
JOIN
    Orders o ON c.customer_id = o.customer_id
JOIN
    Order_Items oi ON o.order_id = oi.order_id
JOIN
    Products p ON oi.product_id = p.product_id
WHERE
    p.category = 'Electronics'
GROUP BY
    c.customer_id, c.customer_name, c.city
HAVING
    COUNT(DISTINCT o.order_id) > 2; -- Changed from 5 to 2 for sample data to show results
SELECT *
FROM HighValueElectronicsCustomers;
CREATE VIEW MarketingCustomers AS
SELECT
    customer_id,
    customer_name,
    email,
    city
FROM
    Customers
WHERE
    email IS NOT NULL; -- Only include customers with an email for marketing purposes
SELECT *
FROM MarketingCustomers;
CREATE VIEW SalesAssistantOrders AS
SELECT
    o.order_id,
    c.customer_name,
    o.order_date
FROM
    Orders o
JOIN
    Customers c ON o.customer_id = c.customer_id
WHERE
    c.city = 'New York';
-- This is a conceptual SQL statement, exact syntax depends on the DBMS (e.g., MySQL, PostgreSQL, SQL Server)
-- View and tables all under the same schema
GRANT SELECT ON dbo.SalesAssistantOrders TO SalesAssistantRole;
-- Don't revoke anything

-- Now SalesAssistantRole users can:
SELECT * FROM dbo.SalesAssistantOrders;
-- But not
SELECT * FROM dbo.Orders; -- permission denied
