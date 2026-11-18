USE restaurant_billing;

DELIMITER $$

-- When a new order is created, create its bill and occupy its table.
CREATE TRIGGER trg_orders_after_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO bills (order_id, subtotal, tax_rate, tax_amount, total_amount)
    VALUES (NEW.order_id, 0.00, 5.00, 0.00, 0.00);

    UPDATE restaurant_tables
    SET table_status = 'OCCUPIED'
    WHERE table_id = NEW.table_id;
END$$

-- Snapshot the current menu price so later menu-price changes
-- do not change the price of an already placed order.
CREATE TRIGGER trg_order_items_before_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE current_price DECIMAL(10,2);
    DECLARE item_is_available BOOLEAN;

    SELECT price, is_available
      INTO current_price, item_is_available
    FROM menu_items
    WHERE item_id = NEW.item_id;

    IF item_is_available = FALSE THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This menu item is currently unavailable';
    END IF;

    SET NEW.unit_price = current_price;
    SET NEW.line_total = current_price * NEW.quantity;
END$$

-- Recalculate the bill after each item is added.
CREATE TRIGGER trg_order_items_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE bills
    SET subtotal = (
            SELECT COALESCE(SUM(line_total), 0.00)
            FROM order_items
            WHERE order_id = NEW.order_id
        ),
        tax_amount = ROUND(
            (
                SELECT COALESCE(SUM(line_total), 0.00)
                FROM order_items
                WHERE order_id = NEW.order_id
            ) * tax_rate / 100,
            2
        ),
        total_amount = ROUND(
            (
                SELECT COALESCE(SUM(line_total), 0.00)
                FROM order_items
                WHERE order_id = NEW.order_id
            ) * (1 + tax_rate / 100),
            2
        )
    WHERE order_id = NEW.order_id;
END$$

DELIMITER ;
