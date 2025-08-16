-- 1. Detecting Unusual Transactions (Z-Score)
WITH customer_stats AS (
    SELECT 
        customer_id,
        AVG(amount) AS avg_amount,
        STDDEV(amount) AS std_amount
    FROM transactions
    GROUP BY customer_id
)
SELECT 
    t.transaction_id,
    t.customer_id,
    t.amount,
    (t.amount - cs.avg_amount) / cs.std_amount AS z_score
FROM transactions t
JOIN customer_stats cs ON t.customer_id = cs.customer_id
WHERE ABS((t.amount - cs.avg_amount) / cs.std_amount) > 3;

-- 2. Velocity-Based Fraud (Multiple Transactions in Short Time)
SELECT 
    t1.customer_id,
    COUNT(*) AS rapid_transactions
FROM transactions t1
JOIN transactions t2 ON t1.customer_id = t2.customer_id
WHERE t1.transaction_id != t2.transaction_id
AND ABS(EXTRACT(EPOCH FROM (t1.transaction_time - t2.transaction_time))) < 3600
GROUP BY t1.customer_id
HAVING COUNT(*) > 5;

-- 3. Geolocation Mismatch (Transactions Far from Home)
SELECT 
    t.transaction_id,
    t.customer_id,
    t.location AS transaction_location,
    c.home_city,
    ST_DISTANCE(t.location, c.home_location) AS distance_km
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE ST_DISTANCE(t.location, c.home_location) > 500; -- 500 km from home