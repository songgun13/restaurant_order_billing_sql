USE restaurant_billing;

INSERT INTO menu_items (item_name, category, price, is_available) VALUES
('Veg Chow Mein', 'Chinese', 120.00, TRUE),
('Chicken Chow Mein', 'Chinese', 160.00, TRUE),
('Paneer Butter Masala', 'Indian', 220.00, TRUE),
('Butter Naan', 'Indian', 40.00, TRUE),
('Masala Dosa', 'South Indian', 100.00, TRUE),
('Cold Coffee', 'Beverages', 90.00, TRUE),
('Mineral Water', 'Beverages', 20.00, TRUE);

INSERT INTO restaurant_tables (table_number, capacity) VALUES
(1, 2), (2, 2), (3, 4), (4, 4), (5, 6);

-- Create two sample orders. The order trigger creates their bills
-- and marks the corresponding restaurant tables as OCCUPIED.
INSERT INTO orders (table_id, notes) VALUES
(1, 'Lunch order'),
(3, 'Family lunch');

-- Add items. The BEFORE INSERT trigger copies the current menu price.
-- The AFTER INSERT trigger updates the corresponding bill totals.
INSERT INTO order_items (order_id, item_id, quantity, unit_price, line_total) VALUES
(1, 1, 2, 0, 0),
(1, 6, 2, 0, 0),
(2, 3, 1, 0, 0),
(2, 4, 4, 0, 0),
(2, 7, 2, 0, 0);
