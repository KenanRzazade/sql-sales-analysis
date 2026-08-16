"""
Generates a small synthetic e-commerce sales dataset for the SQL portfolio project.
Run once to (re)create customers.csv, products.csv, orders.csv, order_items.csv.
"""
import numpy as np
import pandas as pd
from datetime import datetime, timedelta

rng = np.random.default_rng(42)

# ---- Customers ----
n_customers = 120
regions = ["North America", "Europe", "Asia", "Middle East", "South America"]
segments = ["Consumer", "Small Business", "Enterprise"]

customers = pd.DataFrame({
    "customer_id": range(1, n_customers + 1),
    "region": rng.choice(regions, n_customers, p=[0.30, 0.28, 0.20, 0.12, 0.10]),
    "segment": rng.choice(segments, n_customers, p=[0.55, 0.30, 0.15]),
    "signup_date": [
        (datetime(2023, 1, 1) + timedelta(days=int(d)))
        .strftime("%Y-%m-%d")
        for d in rng.integers(0, 700, n_customers)
    ],
})

# ---- Products ----
categories = {
    "Electronics": ["Wireless Mouse", "Mechanical Keyboard", "USB-C Hub", "Webcam", "Monitor Stand"],
    "Office Supplies": ["Notebook Set", "Desk Organizer", "Sticky Notes", "Whiteboard", "Pen Pack"],
    "Furniture": ["Office Chair", "Standing Desk", "Bookshelf", "Filing Cabinet", "Desk Lamp"],
    "Software": ["Analytics License", "Design Suite", "Cloud Storage Plan", "Antivirus Bundle", "VPN Subscription"],
}
rows = []
pid = 1
for cat, items in categories.items():
    for item in items:
        base_price = rng.uniform(8, 450)
        rows.append((pid, item, cat, round(base_price, 2)))
        pid += 1
products = pd.DataFrame(rows, columns=["product_id", "product_name", "category", "unit_price"])

# ---- Orders & Order Items ----
n_orders = 900
order_dates = [
    datetime(2024, 1, 1) + timedelta(days=int(d))
    for d in rng.integers(0, 545, n_orders)  # spans 2024-01-01 .. 2025-06-29
]
order_customer = rng.choice(customers["customer_id"], n_orders)

orders = pd.DataFrame({
    "order_id": range(1, n_orders + 1),
    "customer_id": order_customer,
    "order_date": [d.strftime("%Y-%m-%d") for d in order_dates],
    "status": rng.choice(
        ["Completed", "Completed", "Completed", "Completed", "Cancelled", "Refunded"],
        n_orders,
    ),
})

item_rows = []
item_id = 1
for order_id in orders["order_id"]:
    n_items = rng.integers(1, 5)
    chosen = rng.choice(products["product_id"], n_items, replace=False)
    for prod_id in chosen:
        qty = int(rng.integers(1, 6))
        price = float(products.loc[products.product_id == prod_id, "unit_price"].iloc[0])
        # small random discount noise
        discount = rng.choice([0, 0, 0, 0.05, 0.10, 0.15], p=[0.6, 0.1, 0.1, 0.1, 0.05, 0.05])
        item_rows.append((item_id, order_id, int(prod_id), qty, price, discount))
        item_id += 1

order_items = pd.DataFrame(
    item_rows,
    columns=["order_item_id", "order_id", "product_id", "quantity", "unit_price", "discount"],
)

customers.to_csv("customers.csv", index=False)
products.to_csv("products.csv", index=False)
orders.to_csv("orders.csv", index=False)
order_items.to_csv("order_items.csv", index=False)

print("Generated:")
print(f"  customers.csv   {len(customers)} rows")
print(f"  products.csv    {len(products)} rows")
print(f"  orders.csv      {len(orders)} rows")
print(f"  order_items.csv {len(order_items)} rows")
