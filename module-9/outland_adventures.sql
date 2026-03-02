-- Outland Adventures Database
-- Group 3:
--      Amanda Brock
--      Miguel Fernandex Brazon
--      Ryan Barber
-- This script creates all tables and inserts sample data
-- based on the case study.

DROP DATABASE IF EXISTS outland_adventures;
CREATE DATABASE outland_adventures;
USE outland_adventures;

-- Creates a dedicated app user
DROP USER IF EXISTS 'outland_user'@'localhost';
CREATE USER 'outland_user'@'localhost'
  IDENTIFIED WITH mysql_native_password BY 'outlandpass';

GRANT ALL PRIVILEGES ON outland_adventures.* TO 'outland_user'@'localhost';
FLUSH PRIVILEGES;

-- Location table
-- Stores where trips take place (Africa, Asia, Southern Europe)
CREATE TABLE LOCATION (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  location_name VARCHAR(100) NOT NULL,
  country VARCHAR(80) NOT NULL,
  region VARCHAR(80) NOT NULL,
  description VARCHAR(255),
  UNIQUE (location_name)
);


-- Trip table
-- Each trip happens in one location
-- Stores dates, pricings, and difficulty level
CREATE TABLE TRIP (
  trip_id INT AUTO_INCREMENT PRIMARY KEY,
  location_id INT NOT NULL,
  trip_name VARCHAR(120) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  base_price DECIMAL(10,2) NOT NULL,
  difficulty_level ENUM('Easy','Moderate','Hard','Expert') NOT NULL,
  CONSTRAINT fk_trip_location
    FOREIGN KEY (location_id) REFERENCES LOCATION(location_id),
  CONSTRAINT chk_trip_dates CHECK (end_date >= start_date)
);


-- Employee table
-- Keeps track of staff members
-- Some employees get assigned to trips
CREATE TABLE EMPLOYEE (
  employee_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  role VARCHAR(60) NOT NULL,
  email VARCHAR(120) NOT NULL,
  hire_date DATE NOT NULL,
  UNIQUE (email)
);


-- Trip assignment table
-- Links table between trip and employee
-- Used because 1 trip can have muiltiple guides
CREATE TABLE TRIP_ASSIGNMENT (
  assignment_id INT AUTO_INCREMENT PRIMARY KEY,
  trip_id INT NOT NULL,
  employee_id INT NOT NULL,
  role_on_trip VARCHAR(60) NOT NULL,
  CONSTRAINT fk_assignment_trip
    FOREIGN KEY (trip_id) REFERENCES TRIP(trip_id),
  CONSTRAINT fk_assignment_employee
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id),
  UNIQUE (trip_id, employee_id)
);

-- Customer table
-- Basic info for people who book trips or order equipment
CREATE TABLE CUSTOMER (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  email VARCHAR(120) NOT NULL,
  phone VARCHAR(25),
  UNIQUE (email)
);


-- Booking table
-- Links customers to trips
-- Includes party size and booking status
CREATE TABLE BOOKING (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  trip_id INT NOT NULL,
  booking_date DATE NOT NULL,
  party_size INT NOT NULL,
  status ENUM('Pending','Confirmed','Cancelled') NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_booking_customer
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
  CONSTRAINT fk_booking_trip
    FOREIGN KEY (trip_id) REFERENCES TRIP(trip_id),
  CONSTRAINT chk_party_size CHECK (party_size > 0)
);


-- Customer orders table
-- Stores equipment purchases made by customers
CREATE TABLE CUSTOMER_ORDER (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_type ENUM('Sale','Rental','Mixed') NOT NULL,
  order_date DATE NOT NULL,
  status ENUM('Pending','Paid','Shipped','Complete','Cancelled') NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_order_customer
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

-- Product table
-- Main equipment catalog
CREATE TABLE PRODUCT (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(120) NOT NULL,
  description VARCHAR(255),
  category VARCHAR(60) NOT NULL,
  sale_price DECIMAL(10,2),
  rental_price_day DECIMAL(10,2),
  is_rentable TINYINT(1) NOT NULL DEFAULT 0
);


-- Inventory_unit table
-- Tracks the actual physical items
-- Used mainly for rentals + checking item age
CREATE TABLE INVENTORY_UNIT (
  unit_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  serial_number VARCHAR(80) NOT NULL,
  acquired_date DATE NOT NULL,
  `condition` ENUM('New','Good','Fair','Retired') NOT NULL,
  CONSTRAINT fk_unit_product
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
  UNIQUE (serial_number)
);


-- Order line table
-- Breaks down each order into products or rentals
CREATE TABLE ORDER_LINE (
  line_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  unit_id INT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  rental_start_date DATE NULL,
  rental_end_date DATE NULL,
  CONSTRAINT fk_line_order
    FOREIGN KEY (order_id) REFERENCES CUSTOMER_ORDER(order_id),
  CONSTRAINT fk_line_product
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
  CONSTRAINT fk_line_unit
    FOREIGN KEY (unit_id) REFERENCES INVENTORY_UNIT(unit_id),
  CONSTRAINT chk_quantity CHECK (quantity > 0),
  CONSTRAINT chk_rental_dates CHECK (
    (rental_start_date IS NULL AND rental_end_date IS NULL)
    OR (rental_start_date IS NOT NULL AND rental_end_date IS NOT NULL AND rental_end_date >= rental_start_date)
  )
);


-- Data from case study

-- Locations in Africa, Asia, Southern Europe
INSERT INTO LOCATION (location_name, country, region, description) VALUES
('Mount Kilimanjaro', 'Tanzania', 'Africa', 'Iconic summit trek with high-altitude acclimatization routes.'),
('Atlas Mountains', 'Morocco', 'Africa', 'Rugged mountain trails near Berber villages and scenic valleys.'),
('Everest Base Camp', 'Nepal', 'Asia', 'Himalayan routes with teahouses, big views, and thin air.'),
('Annapurna Circuit', 'Nepal', 'Asia', 'Classic multi-day circuit with varied terrain and dramatic peaks.'),
('Dolomites', 'Italy', 'Southern Europe', 'Alpine traverses, jagged peaks, and postcard mountain huts.'),
('Camino de Santiago', 'Spain', 'Southern Europe', 'Long-distance walking route with villages, history, and lots of coffee.');

-- Employees
INSERT INTO EMPLOYEE (first_name, last_name, role, email, hire_date) VALUES
('Blythe', 'Timmerson', 'Founder', 'blythe.timmerson@outland.com', '2020-01-10'),
('Jim', 'Ford', 'Founder', 'jim.ford@outland.com', '2020-01-10'),
('John', 'MacNell', 'Guide', 'john.macnell@outland.com', '2020-03-01'),
('D.B.', 'Marland', 'Guide', 'db.marland@outland.com', '2020-03-01'),
('Anita', 'Gallegos', 'Marketing', 'anita.gallegos@outland.com', '2020-04-15'),
('Dimitrios', 'Stravopolous', 'Supplies', 'dimitrios.stravopolous@outland.com', '2020-04-20'),
('Mei', 'Wong', 'Ecommerce', 'mei.wong@outland.com', '2026-01-15');

-- Trips
INSERT INTO TRIP (location_id, trip_name, start_date, end_date, base_price, difficulty_level) VALUES
(1, 'Kilimanjaro Glow-Up', '2026-06-05', '2026-06-13', 2499.00, 'Expert'),
(2, 'Atlas Peak & Tagine Week', '2026-04-10', '2026-04-16', 1499.00, 'Hard'),
(3, 'Base Camp & Bad Decisions', '2026-03-20', '2026-03-30', 2399.00, 'Hard'),
(4, 'Annapurna After Dark', '2026-10-02', '2026-10-12', 2299.00, 'Hard'),
(5, 'Dolomites & Aperol Spritz', '2026-09-08', '2026-09-13', 1199.00, 'Moderate'),
(6, 'Camino, Coffee & Questionable Life Choices', '2026-05-01', '2026-05-07', 1099.00, 'Easy');

-- Trip assignments
-- Mac (employee_id 3) and Duke (employee_id 4)
INSERT INTO TRIP_ASSIGNMENT (trip_id, employee_id, role_on_trip) VALUES
(1, 3, 'Lead Guide'),
(1, 4, 'Assistant Guide'),
(2, 4, 'Lead Guide'),
(2, 3, 'Assistant Guide'),
(3, 3, 'Lead Guide'),
(4, 4, 'Lead Guide'),
(5, 3, 'Lead Guide'),
(6, 4, 'Lead Guide');

-- Customers
INSERT INTO CUSTOMER (first_name, last_name, email, phone) VALUES
('Ellen', 'Ripley', 'eripley@gmail.com', '555-111-1001'),
('Sarah', 'Connor', 'sconnor@gmail.com', '555-111-1002'),
('Indiana', 'Jones', 'ijones@gmail.com', '555-111-1003'),
('Lara', 'Croft', 'lcroft@gmail.com', '555-111-1004'),
('Diana', 'Prince', 'dprince@gmail.com', '555-111-1005'),
('Peter', 'Parker', 'pparker@gmail.com', '555-111-1006');

-- Bookings
INSERT INTO BOOKING (customer_id, trip_id, booking_date, party_size, status, total_amount) VALUES
(1, 1, '2026-02-01', 2, 'Confirmed', 4998.00),
(2, 2, '2026-02-03', 1, 'Confirmed', 1499.00),
(3, 3, '2026-02-05', 2, 'Pending', 4598.00),
(4, 4, '2026-02-07', 1, 'Confirmed', 1299.00),
(5, 5, '2026-02-10', 4, 'Confirmed', 3996.00),
(6, 6, '2026-02-12', 2, 'Cancelled', 2398.00),
(1, 2, '2026-02-14', 1, 'Confirmed', 1499.00),
(2, 5, '2026-02-16', 2, 'Confirmed', 1998.00);

-- Products
INSERT INTO PRODUCT (product_name, description, category, sale_price, rental_price_day, is_rentable) VALUES
('Hiking Backpack 50L', 'Adjustable backpack with rain cover.', 'Gear', 139.99, NULL, 0),
('Trekking Poles (Pair)', 'Adjustable poles with wrist straps.', 'Gear', 44.99, 6.00, 1),
('4-Season Tent', 'Wind-resistant tent for harsh weather.', 'Camping', 319.99, 22.00, 1),
('Sleeping Bag 0F', 'Cold-weather sleeping bag.', 'Camping', 179.99, 12.00, 1),
('Headlamp 300lm', 'Rechargeable headlamp with multiple modes.', 'Accessories', 29.99, 4.00, 1),
('Water Filter Bottle', 'Bottle with built-in filtration.', 'Accessories', 39.99, NULL, 0);

-- Inventory
INSERT INTO INVENTORY_UNIT (product_id, serial_number, acquired_date, `condition`) VALUES
(2, 'TP-1001',   '2019-06-12', 'Fair'),   -- >5 years old
(2, 'TP-1002',   '2023-10-01', 'Good'),
(3, 'TENT-2001', '2018-05-20', 'Fair'),   -- >5 years old
(3, 'TENT-2002', '2022-08-15', 'Good'),
(4, 'BAG-3001',  '2020-01-10', 'Good'),
(5, 'LAMP-4001', '2024-11-20', 'New');

-- Customer orders
INSERT INTO CUSTOMER_ORDER (customer_id, order_type, order_date, status, total_amount) VALUES
(1, 'Sale',   '2026-02-02', 'Paid',     179.98),
(2, 'Rental', '2026-02-06', 'Complete',  18.00),
(3, 'Mixed',  '2026-02-11', 'Paid',     53.99),
(4, 'Sale',   '2026-02-13', 'Shipped',   139.99),
(5, 'Rental', '2026-02-16', 'Cancelled', 44.00),
(6, 'Sale',   '2026-02-19', 'Paid',      39.99);

-- Order line sample data
-- Sales do not have unit id or rental dates but rentals do
INSERT INTO ORDER_LINE (order_id, product_id, unit_id, quantity, unit_price, rental_start_date, rental_end_date) VALUES
-- Order 1: sale of backpack and filter bottle
(1, 1, NULL, 1, 139.99, NULL, NULL),
(1, 6, NULL, 1, 39.99,  NULL, NULL),

-- Order 2: rental of trekking poles for 3 days
(2, 2, 2, 1, 6.00, '2026-02-06', '2026-02-08'),

-- Order 3: mixed purchase of sleeping bag and headlamp
(3, 4, 5,    1, 12.00, '2026-02-11', '2026-02-12'),
(3, 5, NULL, 1, 29.99, NULL, NULL),

-- Order 4: sale of backpack
(4, 1, NULL, 1, 139.99, NULL, NULL),

-- Order 5: rental of tent for 2 days
(5, 3, 4, 1, 22.00, '2026-02-16', '2026-02-17'),

-- Order 6: sale of filter bottle
(6, 6, NULL, 1, 39.99, NULL, NULL);


-- OPTIONAL: Optimization Queries 
-- Sales vs rentals vs mixed
SELECT
  order_type,
  COUNT(*) AS total_orders
FROM CUSTOMER_ORDER
GROUP BY order_type;

-- Bookings by region/location 
SELECT
  l.region,
  l.location_name,
  COUNT(b.booking_id) AS booking_count
FROM BOOKING b
JOIN TRIP t ON b.trip_id = t.trip_id
JOIN LOCATION l ON t.location_id = l.location_id
GROUP BY l.region, l.location_name
ORDER BY l.region, booking_count DESC;

-- Inventory items over 5 years old 
SELECT
  iu.unit_id,
  p.product_name,
  iu.serial_number,
  iu.acquired_date,
  iu.`condition`
FROM INVENTORY_UNIT iu
JOIN PRODUCT p ON iu.product_id = p.product_id
WHERE iu.acquired_date < (CURDATE() - INTERVAL 5 YEAR)
ORDER BY iu.acquired_date;