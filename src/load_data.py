import pandas as pd
import sqlite3

# Load REAL dataset
df = pd.read_csv(
    "data/Brazilian E-Commerce Public Dataset by Olist.csv"
)

# Create SQLite database
conn = sqlite3.connect("ecommerce.db")

# Write dataset into SQL table
df.to_sql(
    "ecommerce_data",
    conn,
    if_exists="replace",
    index=False
)
print("Dataset loaded into SQLite database!")

# Preview columns
print(df.columns)

conn.close()