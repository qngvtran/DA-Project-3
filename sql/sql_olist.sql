-----------------------------------------------------------------
-- Q1. Overall business snapshot: orders, revenue, and average order value (delivered orders only — cancelled/unavailable orders never generated real revenue).
--
SELECT COUNT(DISTINCT o.order_id) AS delivered_orders,
ROUND(SUM(oi.item_total), 2) AS total_revenue,
ROUND(AVG(oi.item_total), 2) AS avg_item_value
FROM fact_orders o
    JOIN fact_order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';
-----------------------------------------------------------------
-- Q2. Monthly revenue and order count trend.
--
SELECT o.order_month,
COUNT(DISTINCT o.order_id) AS orders,
ROUND(SUM(oi.item_total), 2) AS revenue
FROM fact_orders o
    JOIN fact_order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_month
ORDER BY o.order_month;
-----------------------------------------------------------------
-- Q3. Top 10 product categories by revenue.
--
SELECT p.category,
COUNT(*) AS items_sold,
ROUND(SUM(oi.item_total), 2) AS revenue
FROM fact_order_items oi
    JOIN dim_products p ON p.product_id = oi.product_id
    JOIN fact_orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 10;
-----------------------------------------------------------------
-- Q4. Delivery performance: what % of orders arrive late, and by how many days on average when they do?
--
SELECT COUNT(*) AS delivered_orders,
COUNT(*) FILTER (
    WHERE is_late
) AS late_orders,
ROUND(
    100.0 * COUNT(*) FILTER (
        WHERE is_late
    ) / COUNT(*),
    2
) AS pct_late,
ROUND(
    AVG(delivery_delta_days) FILTER (
        WHERE is_late
    ),
    1
) AS avg_days_late_when_late,
ROUND(AVG(delivery_days_actual), 1) AS avg_delivery_days
FROM fact_orders
WHERE order_status = 'delivered';
-----------------------------------------------------------------
-- Q5. Which states have the worst delivery performance? (join to dim_customers for the delivery destination state)
--
SELECT c.customer_state,
COUNT(*) AS delivered_orders,
ROUND(
    100.0 * COUNT(*) FILTER (
        WHERE o.is_late
    ) / COUNT(*),
    2
) AS pct_late,
ROUND(AVG(o.delivery_days_actual), 1) AS avg_delivery_days
FROM fact_orders o
    JOIN dim_customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(*) > 100 -- ignore tiny states with unreliable rates
ORDER BY pct_late DESC
LIMIT 10;
-----------------------------------------------------------------
-- Q6. Does delivery lateness actually hurt review scores? (a classic "does operations affect customer experience" check)
--
SELECT o.is_late,
COUNT(*) AS orders,
ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM fact_orders o
    JOIN fact_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.is_late;
-----------------------------------------------------------------
-- Q7. Payment method breakdown: usage and average order value.
--
SELECT payment_type,
COUNT(*) AS payments,
ROUND(AVG(payment_value), 2) AS avg_payment_value,
ROUND(AVG(payment_installments), 1) AS avg_installments
FROM fact_payments
GROUP BY payment_type
ORDER BY payments DESC;
-----------------------------------------------------------------
-- Q8. Top 10 sellers by revenue, with their average review score (a seller-performance leaderboard combining two fact tables)
--
SELECT oi.seller_id,
s.seller_state,
COUNT(DISTINCT oi.order_id) AS orders,
ROUND(SUM(oi.item_total), 2) AS revenue,
ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM fact_order_items oi
    JOIN dim_sellers s ON s.seller_id = oi.seller_id
    JOIN fact_orders o ON o.order_id = oi.order_id
    AND o.order_status = 'delivered'
    LEFT JOIN fact_reviews r ON r.order_id = oi.order_id
GROUP BY oi.seller_id,
    s.seller_state
ORDER BY revenue DESC
LIMIT 10;
-----------------------------------------------------------------
-- Q9. Review score distribution, and what fraction of reviews come with a written comment at each score level.
--
SELECT review_score,
COUNT(*) AS reviews,
ROUND(
    100.0 * COUNT(*) FILTER (
        WHERE has_comment
    ) / COUNT(*),
    1
) AS pct_with_comment,
ROUND(AVG(response_time_days), 1) AS avg_response_time_days
FROM fact_reviews
GROUP BY review_score
ORDER BY review_score;
-----------------------------------------------------------------
-- Q10. Which Brazilian states generate the most revenue per capita of customers? (revenue per customer, not just total revenue - normalizes for state size)
--
SELECT c.customer_state,
COUNT(DISTINCT c.customer_id) AS customers,
ROUND(SUM(oi.item_total), 2) AS total_revenue,
ROUND(
    SUM(oi.item_total) / COUNT(DISTINCT c.customer_id),
    2
) AS revenue_per_customer
FROM fact_orders o
    JOIN dim_customers c ON c.customer_id = o.customer_id
    JOIN fact_order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(DISTINCT c.customer_id) > 50
ORDER BY revenue_per_customer DESC
LIMIT 10;
-----------------------------------------------------------------
-- Q11. Running (cumulative) monthly revenue
--
SELECT o.order_month,
ROUND(SUM(oi.item_total), 2) AS monthly_revenue,
ROUND(
    SUM(SUM(oi.item_total)) OVER (
        ORDER BY o.order_month
    ),
    2
) AS cumulative_revenue
FROM fact_orders o
    JOIN fact_order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_month
ORDER BY o.order_month;
-----------------------------------------------------------------
-- Q12. Rank product categories within each customer state by revenue, to find each region's #1 category
--
SELECT customer_state,
category,
revenue
FROM (
        SELECT c.customer_state,
            p.category,
            SUM(oi.item_total) AS revenue,
            RANK() OVER (
                PARTITION BY c.customer_state
                ORDER BY SUM(oi.item_total) DESC
            ) AS rnk
        FROM fact_orders o
            JOIN dim_customers c ON c.customer_id = o.customer_id
            JOIN fact_order_items oi ON oi.order_id = o.order_id
            JOIN dim_products p ON p.product_id = oi.product_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_state,
            p.category
    ) ranked
WHERE rnk = 1
ORDER BY revenue DESC
LIMIT 15;