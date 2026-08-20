-- ============================================================
-- Experiment 2: Relational Schema for Indian E-Commerce Platform
-- Converted from the ER diagram in Experiment 1
-- Engine: InnoDB (required for FOREIGN KEY enforcement)
-- ============================================================

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ------------------------------------------------------------
-- 1. CUSTOMER  (strong entity)
-- ------------------------------------------------------------
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Multi-valued attribute: Customer phone numbers
CREATE TABLE Customer_Phone (
    customer_id INT NOT NULL,
    phone       VARCHAR(15) NOT NULL,
    PRIMARY KEY (customer_id, phone),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. ADDRESS  (weak entity - depends on Customer)
-- ------------------------------------------------------------
CREATE TABLE Address (
    customer_id INT NOT NULL,
    address_id  INT NOT NULL,          -- partial key
    street      VARCHAR(100) NOT NULL,
    city        VARCHAR(50)  NOT NULL,
    state       VARCHAR(50)  NOT NULL,
    pincode     VARCHAR(10)  NOT NULL,
    PRIMARY KEY (customer_id, address_id),   -- composite key of weak entity
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. CATEGORY  (strong entity)
-- ------------------------------------------------------------
CREATE TABLE Category (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. SELLER  (strong entity)
-- ------------------------------------------------------------
CREATE TABLE Seller (
    seller_id   INT AUTO_INCREMENT PRIMARY KEY,
    seller_name VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Seller_Phone (
    seller_id INT NOT NULL,
    phone     VARCHAR(15) NOT NULL,
    PRIMARY KEY (seller_id, phone),
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. PRODUCT  (strong entity, with specialization)
-- ------------------------------------------------------------
CREATE TABLE Product (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    stock        INT NOT NULL DEFAULT 0,
    category_id  INT NULL,
    seller_id    INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- Specialization: Electronics (disjoint subtype of Product)
CREATE TABLE Electronics (
    product_id      INT PRIMARY KEY,
    warranty_period INT,               -- in months
    brand           VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- Specialization: Clothing (disjoint subtype of Product)
CREATE TABLE Clothing (
    product_id INT PRIMARY KEY,
    size       VARCHAR(10),
    fabric     VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. ORDER  (strong entity)   -- "Order" is a reserved word in MySQL
-- ------------------------------------------------------------
CREATE TABLE Orders (
    order_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_date   DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    customer_id  INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. ORDER_ITEM  (weak entity - depends on Orders)
-- ------------------------------------------------------------
CREATE TABLE Order_Item (
    order_id   INT NOT NULL,
    item_no    INT NOT NULL,           -- partial key
    quantity   INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    product_id INT NULL,
    PRIMARY KEY (order_id, item_no),   -- composite key of weak entity
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 8. PAYMENT  (strong entity, 1:1 with Orders)
-- ------------------------------------------------------------
CREATE TABLE Payment (
    payment_id   INT AUTO_INCREMENT PRIMARY KEY,
    amount       DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_mode VARCHAR(20) NOT NULL,
    order_id     INT NOT NULL UNIQUE,   -- UNIQUE enforces the 1:1 cardinality
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 9. DELIVERY  (strong entity, 1:1 with Orders)
-- ------------------------------------------------------------
CREATE TABLE Delivery (
    delivery_id      INT AUTO_INCREMENT PRIMARY KEY,
    delivery_date    DATE,
    status           VARCHAR(20) NOT NULL,
    tracking_number  VARCHAR(30) UNIQUE,
    order_id         INT NOT NULL UNIQUE,   -- UNIQUE enforces the 1:1 cardinality
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO Customer (first_name, last_name, email) VALUES
('Aarav', 'Sharma', 'aarav.sharma@example.com'),
('Priya', 'Iyer',   'priya.iyer@example.com');

INSERT INTO Customer_Phone (customer_id, phone) VALUES
(1, '9876543210'),
(1, '9123456780'),
(2, '9988776655');

INSERT INTO Address (customer_id, address_id, street, city, state, pincode) VALUES
(1, 1, '12 MG Road', 'Lucknow', 'Uttar Pradesh', '226001'),
(2, 1, '45 Anna Salai', 'Chennai', 'Tamil Nadu', '600002');

INSERT INTO Category (category_name) VALUES
('Electronics'), ('Clothing'), ('Groceries');

INSERT INTO Seller (seller_name, email) VALUES
('TechBazaar Pvt Ltd', 'contact@techbazaar.com'),
('FashionHub India', 'support@fashionhub.in');

INSERT INTO Seller_Phone (seller_id, phone) VALUES
(1, '011-40001234'),
(2, '022-50005678');

INSERT INTO Product (product_name, price, stock, category_id, seller_id) VALUES
('Wireless Earbuds X200', 2499.00, 50, 1, 1),
('Cotton Kurta - Blue', 899.00, 100, 2, 2);

INSERT INTO Electronics (product_id, warranty_period, brand) VALUES
(1, 12, 'SoundWave');

INSERT INTO Clothing (product_id, size, fabric) VALUES
(2, 'M', 'Cotton');

INSERT INTO Orders (order_date, total_amount, customer_id) VALUES
('2026-08-01', 3398.00, 1);

INSERT INTO Order_Item (order_id, item_no, quantity, unit_price, product_id) VALUES
(1, 1, 1, 2499.00, 1),
(1, 2, 1, 899.00, 2);

INSERT INTO Payment (amount, payment_date, payment_mode, order_id) VALUES
(3398.00, '2026-08-01', 'UPI', 1);

INSERT INTO Delivery (delivery_date, status, tracking_number, order_id) VALUES
('2026-08-05', 'Shipped', 'TRK123456789', 1);


-- ============================================================
-- DEMONSTRATING REFERENTIAL INTEGRITY (run these one at a time
-- and observe the error MySQL raises for each)
-- ============================================================

-- (a) INSERT violation: order_id 999 does not exist in Orders
-- Expected: Error 1452 - Cannot add or update a child row:
--           a foreign key constraint fails (order_id FK)
-- INSERT INTO Order_Item (order_id, item_no, quantity, unit_price, product_id)
-- VALUES (999, 1, 2, 500.00, 1);

-- (b) INSERT violation: product_id 999 does not exist in Product
-- Expected: Error 1452 - foreign key constraint fails (product_id FK)
-- INSERT INTO Order_Item (order_id, item_no, quantity, unit_price, product_id)
-- VALUES (1, 3, 1, 100.00, 999);

-- (c) UNIQUE violation: this order already has a payment (1:1 constraint)
-- Expected: Error 1062 - Duplicate entry '1' for key 'order_id'
-- INSERT INTO Payment (amount, payment_date, payment_mode, order_id)
-- VALUES (500.00, '2026-08-02', 'Cash', 1);

-- (d) ON DELETE SET NULL demonstration: delete a Category
-- Expected: Product.category_id for its products becomes NULL, rows survive
-- DELETE FROM Category WHERE category_id = 1;
-- SELECT * FROM Product WHERE product_id = 1;   -- category_id is now NULL

-- (e) ON DELETE CASCADE demonstration: delete a Customer
-- Expected: their Address, Customer_Phone, Orders rows are deleted
--           automatically, which in turn cascades to Order_Item,
--           Payment, and Delivery for those orders
-- DELETE FROM Customer WHERE customer_id = 1;
-- SELECT * FROM Orders WHERE customer_id = 1;    -- empty result
-- SELECT * FROM Payment WHERE order_id = 1;      -- empty result

-- (f) NOT NULL violation: order_date is required
-- Expected: Error 1364 - Field 'order_date' doesn't have a default value
-- INSERT INTO Orders (total_amount, customer_id) VALUES (500.00, 1);