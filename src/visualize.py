import pandas as pd
import sqlite3
import matplotlib.pyplot as plt

# Connect to database
conn = sqlite3.connect("ecommerce.db")

# Query monthly revenue
query = """
SELECT
    "month/year_of_purchase" AS month,
    year_of_purchase,
    month_of_purchase,
    SUM(payment_value) AS revenue
FROM ecommerce_data
GROUP BY
    year_of_purchase,
    month_of_purchase
ORDER BY
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
    END
"""

df = pd.read_sql_query(query, conn)

# Plot
plt.figure(figsize=(12,6))
plt.plot(df["month"], df["revenue"])

plt.xticks(rotation=45)
plt.title("Monthly Revenue Trend")
plt.ylabel("Revenue")

plt.tight_layout()

plt.savefig("outputs/monthly_revenue_trend.png")

plt.show()


# Customer Order Frequency Distribution

query_orders = """
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
"""

orders_df = pd.read_sql_query(query_orders, conn)

# Plot
plt.figure(figsize=(8,5))

plt.bar(
    orders_df["total_orders"],
    orders_df["customer_count"]
)

plt.yscale("log")

plt.title("Customer Order Frequency Distribution")
plt.xlabel("Number of Orders")
plt.ylabel("Customer Count (Log Scale)")

plt.tight_layout()

plt.savefig(
    "outputs/customer_order_distribution.png"
)

plt.show()

# Revenue Contribution by Customer Type

query_customer_type = """
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

    ROUND(SUM(total_revenue), 2) AS revenue

FROM customer_orders

GROUP BY customer_type;
"""

customer_type_df = pd.read_sql_query(
    query_customer_type,
    conn
)

# Plot
plt.figure(figsize=(6,5))

plt.bar(
    customer_type_df["customer_type"],
    customer_type_df["revenue"]
)

plt.title("Revenue Contribution by Customer Type")
plt.ylabel("Revenue")

plt.tight_layout()

plt.savefig(
    "outputs/revenue_by_customer_type.png"
)

plt.show()

# KPI Summary Figure

fig, ax = plt.subplots(figsize=(10,4))

ax.axis("off")

kpi_text = f"""
Total Customers: 92,081

Total Revenue: $19.53M

Average Order Value: $172.24

Repeat Purchase Rate: 2.98%
"""

ax.text(
    0.5,
    0.5,
    kpi_text,
    ha="center",
    va="center",
    fontsize=16
)

plt.title("Business Performance Snapshot")

plt.savefig(
    "outputs/business_kpi_snapshot.png",
    bbox_inches="tight"
)

plt.show()

conn.close()