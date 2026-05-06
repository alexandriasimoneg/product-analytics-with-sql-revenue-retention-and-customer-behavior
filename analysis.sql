--- Preview adataset
SELECT *
FROM ecommerce_data
LIMIT 10;

--- View schema
PRAGMA table_info(ecommerce_data);

--- Count customers 
SELECT
    COUNT(DISTINCT customer_id)
FROM ecommerce_data;

-- Total Revenue
SELECT
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM ecommerce_data;

-- Unique Customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM ecommerce_data;

-- Top Spending Customers
SELECT
    customer_unique_id,
    ROUND(SUM(payment_value), 2) AS total_spent
FROM ecommerce_data
GROUP BY customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- Repeat Purchasers
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_data
GROUP BY customer_unique_id
HAVING total_orders > 1
ORDER BY total_orders DESC;

-- Revenue by Product Category
SELECT
    product_category_name,
    ROUND(SUM(payment_value), 2) AS revenue
FROM ecommerce_data
GROUP BY product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- Average Delivery Time
SELECT
    ROUND(
        AVG(
            julianday(order_delivered_customer_date) -
            julianday(order_purchase_timestamp)
        ),
        2
    ) AS avg_delivery_days
FROM ecommerce_data
WHERE order_delivered_customer_date IS NOT NULL;

-- Monthly Revenue Trend
SELECT
    "month/year_of_purchase",
    ROUND(SUM(payment_value), 2) AS monthly_revenue
FROM ecommerce_data
GROUP BY "month/year_of_purchase"
ORDER BY year_of_purchase, month_of_purchase;

-- Repeat Purchase Rate
WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM ecommerce_data
    GROUP BY customer_unique_id
)

SELECT
    COUNT(
        CASE
            WHEN total_orders > 1 THEN 1
        END
    ) * 100.0 / COUNT(*) AS repeat_purchase_rate
FROM customer_orders;

-- Average Order Value
SELECT
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM ecommerce_data;

-- Revenue by Payment Type
SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM ecommerce_data
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- Top States by Revenue
SELECT
    customer_state,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM ecommerce_data
GROUP BY customer_state
ORDER BY total_revenue DESC
LIMIT 10;

-- Late Deliveries
SELECT
    COUNT(*) AS late_deliveries
FROM ecommerce_data
WHERE
    order_delivered_customer_date >
    order_estimated_delivery_date;

-- Customer Order Frequency Distribution
SELECT
    total_orders,
    COUNT(*) AS customer_count
FROM (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM ecommerce_data
    GROUP BY customer_unique_id
)
GROUP BY total_orders
ORDER BY total_orders;

-- Repeat Purchase Behavior by Delivery Performance

WITH customer_delivery AS (
    SELECT
        customer_unique_id,

        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 'Late'
            ELSE 'On Time'
        END AS delivery_status,

        COUNT(DISTINCT order_id) AS total_orders

    FROM ecommerce_data

    WHERE order_delivered_customer_date IS NOT NULL

    GROUP BY customer_unique_id
)

SELECT
    delivery_status,
    AVG(total_orders) AS avg_orders_per_customer
FROM customer_delivery
GROUP BY delivery_status;

-- Revenue Contribution by Customer Type

WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(payment_value) AS total_revenue
    FROM ecommerce_data
    GROUP BY customer_unique_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,

    ROUND(SUM(total_revenue), 2) AS revenue,

    COUNT(*) AS customers

FROM customer_orders

GROUP BY customer_type;

-- Customer Revenue Ranking

WITH customer_revenue AS (
    SELECT
        customer_unique_id,
        SUM(payment_value) AS total_revenue
    FROM ecommerce_data
    GROUP BY customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_revenue, 2) AS total_revenue,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank

FROM customer_revenue
LIMIT 20;

-- Business Performance Snapshot

WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM ecommerce_data
    GROUP BY customer_unique_id
),

repeat_metrics AS (
    SELECT
        ROUND(
            COUNT(
                CASE
                    WHEN total_orders > 1 THEN 1
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS repeat_purchase_rate
    FROM customer_orders
)

SELECT

    COUNT(DISTINCT customer_unique_id)
        AS total_customers,

    ROUND(SUM(payment_value), 2)
        AS total_revenue,

    ROUND(AVG(payment_value), 2)
        AS avg_order_value,

    (
        SELECT repeat_purchase_rate
        FROM repeat_metrics
    ) AS repeat_purchase_rate

FROM ecommerce_data;

-- Monthly Revenue Growth Rate

WITH monthly_revenue AS (
    SELECT
        "month/year_of_purchase" AS month,
        year_of_purchase,

        CASE month_of_purchase
            WHEN 'January' THEN 1
            WHEN 'February' THEN 2
            WHEN 'March' THEN 3
            WHEN 'April' THEN 4
            WHEN 'May' THEN 5
            WHEN 'June' THEN 6
            WHEN 'July' THEN 7
            WHEN 'August' THEN 8
            WHEN 'September' THEN 9
            WHEN 'October' THEN 10
            WHEN 'November' THEN 11
            WHEN 'December' THEN 12
        END AS month_num,

        SUM(payment_value) AS revenue

    FROM ecommerce_data

    GROUP BY
        year_of_purchase,
        month_of_purchase
)

SELECT
    month,

    ROUND(revenue, 2) AS revenue,

    ROUND(
        revenue - LAG(revenue) OVER (
            ORDER BY year_of_purchase, month_num
        ),
        2
    ) AS revenue_change

FROM monthly_revenue

ORDER BY year_of_purchase, month_num;