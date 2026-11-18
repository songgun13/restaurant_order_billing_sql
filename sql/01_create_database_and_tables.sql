CREATE DATABASE IF NOT EXISTS restaurant_billing;
USE restaurant_billing;

CREATE TABLE IF NOT EXISTS menu_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_menu_price CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS restaurant_tables (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL UNIQUE,
    capacity INT NOT NULL,
    table_status ENUM('AVAILABLE', 'OCCUPIED') NOT NULL DEFAULT 'AVAILABLE',
    CONSTRAINT chk_table_capacity CHECK (capacity > 0)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    table_id INT NOT NULL,
    order_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('OPEN', 'CLOSED', 'CANCELLED') NOT NULL DEFAULT 'OPEN',
    notes VARCHAR(255),
    CONSTRAINT fk_orders_table
        FOREIGN KEY (table_id) REFERENCES restaurant_tables(table_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_menu
        FOREIGN KEY (item_id) REFERENCES menu_items(item_id),
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (unit_price >= 0 AND line_total >= 0)
);

CREATE TABLE IF NOT EXISTS bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tax_rate DECIMAL(5,2) NOT NULL DEFAULT 5.00,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    bill_status ENUM('UNPAID', 'PAID') NOT NULL DEFAULT 'UNPAID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at DATETIME NULL,
    CONSTRAINT fk_bills_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT chk_bill_tax_rate CHECK (tax_rate >= 0),
    CONSTRAINT chk_bill_amounts CHECK (
        subtotal >= 0 AND tax_amount >= 0 AND total_amount >= 0
    )
);