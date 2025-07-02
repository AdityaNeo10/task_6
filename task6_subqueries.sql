
-- Reset the database
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Create Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Products Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0
);

-- Create Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Create OrderItems Table
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Create Payments Table
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL,
    method ENUM('Credit Card', 'Debit Card', 'UPI', 'Cash on Delivery') NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- INSERT DATA

-- Insert Users
INSERT INTO Users (name, email, password) VALUES
('Aditya Kumar', 'aditya@example.com', 'pass123'),
('Rohit Mehra', 'rohit@example.com', 'rohit123'),
('Sana Shaikh', 'sana@example.com', 'sana456');

-- Insert Products (one product has NULL description)
INSERT INTO Products (name, description, price, stock) VALUES
('Laptop', '14-inch slim laptop', 799.99, 10),
('Wireless Mouse', NULL, 25.00, 50),
('Keyboard', 'Mechanical RGB keyboard', 45.00, 30);

-- Insert Orders
INSERT INTO Orders (user_id, status) VALUES
(1, 'Pending'),
(2, 'Shipped'),
(3, 'Delivered');

-- Insert OrderItems
INSERT INTO OrderItems (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 799.99),
(1, 2, 2, 50.00),
(2, 3, 1, 45.00);

-- Insert Payments
INSERT INTO Payments (order_id, amount, method) VALUES
(1, 849.99, 'Credit Card'),
(2, 45.00, 'UPI'),
(3, 45.00, 'Cash on Delivery');

-- 1. Select users who have placed at least one order (subquery in WHERE using IN)
SELECT name, email
FROM Users
WHERE user_id IN (
    SELECT DISTINCT user_id FROM Orders
);

-- 2. Get all products with price greater than the average product price (scalar subquery in WHERE)
SELECT * FROM Products
WHERE price > (
    SELECT AVG(price) FROM Products
);

-- 3. Show orders where the total order amount > 100 (correlated subquery in WHERE)
SELECT * FROM Orders
WHERE order_id IN (
    SELECT order_id
    FROM OrderItems
    GROUP BY order_id
    HAVING SUM(price * quantity) > 100
);

-- 4. Select users who have never placed an order (subquery with NOT EXISTS)
SELECT * FROM Users u
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o WHERE o.user_id = u.user_id
);

-- 5. Show each order along with its total amount (subquery in SELECT)
SELECT o.order_id, 
       o.user_id,
       (SELECT SUM(price * quantity) 
        FROM OrderItems oi 
        WHERE oi.order_id = o.order_id) AS total_amount
FROM Orders o;

-- 6. Show name and total amount spent by each user (subquery in SELECT with GROUP BY)
SELECT u.name,
       (SELECT SUM(p.amount) 
        FROM Payments p 
        JOIN Orders o ON p.order_id = o.order_id
        WHERE o.user_id = u.user_id) AS total_spent
FROM Users u;
