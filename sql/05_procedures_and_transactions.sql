USE restaurant_billing;

DELIMITER $$

-- Close an order, mark its bill as paid, and free its table atomically.
-- If any statement fails, the transaction is rolled back.
CREATE PROCEDURE sp_close_bill(IN p_order_id INT)
BEGIN
    DECLARE v_bill_status VARCHAR(10);
    DECLARE v_table_id INT;
    DECLARE v_not_found BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT b.bill_status, o.table_id
      INTO v_bill_status, v_table_id
    FROM bills b
    JOIN orders o ON o.order_id = b.order_id
    WHERE b.order_id = p_order_id
    FOR UPDATE;

    IF v_not_found THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order or bill not found';
    END IF;

    IF v_bill_status = 'PAID' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This bill has already been paid';
    END IF;

    UPDATE bills
    SET bill_status = 'PAID',
        paid_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;

    UPDATE orders
    SET order_status = 'CLOSED'
    WHERE order_id = p_order_id;

    UPDATE restaurant_tables
    SET table_status = 'AVAILABLE'
    WHERE table_id = v_table_id;

    COMMIT;
END$$

DELIMITER ;

-- Example:
-- CALL sp_close_bill(1);
