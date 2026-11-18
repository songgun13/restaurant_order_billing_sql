USE restaurant_billing;

CREATE OR REPLACE VIEW v_bill_details AS
SELECT
    b.bill_id,
    o.order_id,
    rt.table_number,
    o.order_datetime,
    mi.item_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    b.subtotal,
    b.tax_rate,
    b.tax_amount,
    b.total_amount,
    b.bill_status
FROM bills b
JOIN orders o ON o.order_id = b.order_id
JOIN restaurant_tables rt ON rt.table_id = o.table_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN menu_items mi ON mi.item_id = oi.item_id;

-- One row per order/bill, useful for a bill summary screen.
CREATE OR REPLACE VIEW v_bill_summary AS
SELECT
    b.bill_id,
    b.order_id,
    rt.table_number,
    o.order_datetime,
    b.subtotal,
    b.tax_rate,
    b.tax_amount,
    b.total_amount,
    b.bill_status,
    b.paid_at
FROM bills b
JOIN orders o ON o.order_id = b.order_id
JOIN restaurant_tables rt ON rt.table_id = o.table_id;
