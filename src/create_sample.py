import pandas as pd

# Load full dataset
df = pd.read_csv("data/Brazilian E-Commerce Public Dataset by Olist.csv")

# Create sample
sample_df = df.sample(5000, random_state=42)

# Save sample
sample_df.to_csv("data/olist_sample.csv", index=False)

print("Sample dataset created!")