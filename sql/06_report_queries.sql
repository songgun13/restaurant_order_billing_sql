USE restaurant_billing;

-- 1. Best-selling dishes (ranked by quantity sold)
SELECT
    mi.item_id,
    mi.item_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN menu_items mi ON mi.item_id = oi.item_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status <> 'CANCELLED'
GROUP BY mi.item_id, mi.item_name
ORDER BY total_quantity_sold DESC;

-- 2. Revenue by day (paid bills only)
SELECT
    DATE(paid_at) AS sales_date,
    SUM(total_amount) AS daily_revenue
FROM bills
WHERE bill_status = 'PAID'
GROUP BY DATE(paid_at)
ORDER BY sales_date;

-- 3. Busiest hour (number of orders)
SELECT
    HOUR(order_datetime) AS order_hour,
    COUNT(*) AS total_orders
FROM orders
WHERE order_status <> 'CANCELLED'
GROUP BY HOUR(order_datetime)
ORDER BY total_orders DESC;

-- 4. Bill details for every table/order
SELECT * FROM v_bill_details
ORDER BY order_id, item_name;

-- 5. Current occupied tables
SELECT table_number, capacity, table_status
FROM restaurant_tables
WHERE table_status = 'OCCUPIED'
ORDER BY table_number;

-- 6. Revenue by menu category
SELECT
    mi.category,
    SUM(oi.line_total) AS category_revenue
FROM order_items oi
JOIN menu_items mi ON mi.item_id = oi.item_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'CLOSED'
GROUP BY mi.category
ORDER BY category_revenue DESC;

-- 7. Orders and their current bill status
SELECT
    o.order_id,
    rt.table_number,
    o.order_datetime,
    o.order_status,
    b.subtotal,
    b.tax_amount,
    b.total_amount,
    b.bill_status
FROM orders o
JOIN restaurant_tables rt ON rt.table_id = o.table_id
JOIN bills b ON b.order_id = o.order_id
ORDER BY o.order_datetime DESC;
