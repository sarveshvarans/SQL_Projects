-- 1. Monthly Sales Growth Rate
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(order_total) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
SELECT 
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND((revenue - LAG(revenue, 1) OVER (ORDER BY month)) / LAG(revenue, 1) OVER (ORDER BY month) * 100, 2) AS growth_rate
FROM monthly_sales;

-- 2. Customer Cohort Retention Analysis
WITH first_purchases AS (
    SELECT 
        customer_id,
        MIN(DATE_TRUNC('month', order_date)) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
monthly_activity AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', order_date) AS activity_month
    FROM orders
    GROUP BY customer_id, DATE_TRUNC('month', order_date)
SELECT 
    fc.cohort_month,
    ma.activity_month,
    COUNT(DISTINCT fc.customer_id) AS customers,
    ROUND(COUNT(DISTINCT ma.customer_id) * 100.0 / COUNT(DISTINCT fc.customer_id), 2) AS retention_rate
FROM first_purchases fc
LEFT JOIN monthly_activity ma ON fc.customer_id = ma.customer_id
GROUP BY fc.cohort_month, ma.activity_month
ORDER BY fc.cohort_month, ma.activity_month;

-- 3. Product Recommendation Engine (Collaborative Filtering)
SELECT 
    p1.product_id AS product_a,
    p2.product_id AS product_b,
    COUNT(DISTINCT o1.customer_id) AS co_purchases
FROM order_items o1
JOIN order_items o2 ON o1.order_id = o2.order_id AND o1.product_id < o2.product_id
GROUP BY p1.product_id, p2.product_id
HAVING COUNT(DISTINCT o1.customer_id) > 5
ORDER BY co_purchases DESC
LIMIT 10;