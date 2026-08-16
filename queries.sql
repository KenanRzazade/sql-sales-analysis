-- =====================================================================
-- Sales Performance Analysis — business questions answered in SQL
-- Revenue is always calculated net of discount:
--   net_revenue = quantity * unit_price * (1 - discount)
-- Only 'Completed' orders count toward revenue (Cancelled/Refunded excluded).
-- =====================================================================

-- 1. Monthly net revenue trend
SELECT
    strftime('%Y-%m', o.order_date)               AS month,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_revenue,
    COUNT(DISTINCT o.order_id)                     AS orders
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY month
ORDER BY month;

-- 2. Top 10 products by net revenue
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_revenue,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o   ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id
ORDER BY net_revenue DESC
LIMIT 10;

-- 3. Revenue by category and customer region
SELECT
    c.region,
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_revenue
FROM order_items oi
JOIN orders o     ON o.order_id = oi.order_id
JOIN customers c  ON c.customer_id = o.customer_id
JOIN products p   ON p.product_id = oi.product_id
WHERE o.status = 'Completed'
GROUP BY c.region, p.category
ORDER BY c.region, net_revenue DESC;

-- 4. Average order value and order count by customer segment
SELECT
    c.segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS net_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / COUNT(DISTINCT o.order_id), 2
    ) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN customers c    ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.segment
ORDER BY net_revenue DESC;

-- 5. WINDOW FUNCTION: running total + month-over-month growth %
WITH monthly AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS net_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
)
SELECT
    month,
    ROUND(net_revenue, 2) AS net_revenue,
    ROUND(SUM(net_revenue) OVER (ORDER BY month), 2) AS running_total,
    ROUND(
        100.0 * (net_revenue - LAG(net_revenue) OVER (ORDER BY month))
        / LAG(net_revenue) OVER (ORDER BY month), 1
    ) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 6. WINDOW FUNCTION: rank products within their category by revenue
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS net_revenue
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders o   ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_id
)
SELECT
    category,
    product_name,
    ROUND(net_revenue, 2) AS net_revenue,
    RANK() OVER (PARTITION BY category ORDER BY net_revenue DESC) AS rank_in_category
FROM product_revenue
ORDER BY category, rank_in_category;

-- 7. Cancellation / refund rate by region
SELECT
    c.region,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN o.status = 'Refunded' THEN 1 ELSE 0 END) AS refunded,
    ROUND(
        100.0 * SUM(CASE WHEN o.status IN ('Cancelled', 'Refunded') THEN 1 ELSE 0 END)
        / COUNT(*), 1
    ) AS problem_rate_pct
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY problem_rate_pct DESC;

-- 8. Top 5 customers by lifetime value (net revenue), with order count
SELECT
    c.customer_id,
    c.region,
    c.segment,
    COUNT(DISTINCT o.order_id) AS orders_placed,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS lifetime_value
FROM customers c
JOIN orders o        ON o.customer_id = c.customer_id
JOIN order_items oi  ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id
ORDER BY lifetime_value DESC
LIMIT 5;
