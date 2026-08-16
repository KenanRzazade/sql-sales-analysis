# Sales Performance Analysis (SQL)

**Goal:** Answer real business questions — revenue trends, top products, customer
value, and order problem rates — using SQL on a relational e-commerce dataset.

## Dataset

A synthetic but realistic e-commerce dataset (generation script included, so it's
fully reproducible):

| Table | Rows | Description |
|---|---|---|
| `customers.csv` | 120 | region, segment, signup date |
| `products.csv` | 20 | 4 categories, unit price |
| `orders.csv` | 900 | order date, status (Completed / Cancelled / Refunded) |
| `order_items.csv` | 2,226 | line items: quantity, unit price, discount |

Schema (with foreign keys) is in [`schema.sql`](schema.sql). Regenerate the data
anytime with `python generate_data.py`.

## Business questions answered — [`queries.sql`](queries.sql)

1. Monthly net revenue trend
2. Top 10 products by net revenue
3. Revenue by category × region
4. Average order value by customer segment
5. **Window function:** running revenue total + month-over-month growth %
6. **Window function:** product rank within each category (`RANK() OVER (PARTITION BY ...)`)
7. Cancellation/refund rate by region
8. Top 5 customers by lifetime value

All revenue figures are **net of discount**: `quantity × unit_price × (1 − discount)`,
and only `Completed` orders count toward revenue — cancelled/refunded orders are
excluded so the numbers reflect actual realized sales.

## Key findings

- **Total realized revenue:** $929,733 across 599 completed orders.
- **Top product:** Wireless Mouse ($85,297 net revenue), followed closely by the
  VPN Subscription and Monitor Stand — Electronics and Software are the two
  strongest categories.
- **Customer segments:** Consumer accounts for the most total revenue ($536,588),
  but average order value is nearly identical across all three segments (~$1,530–$1,570) —
  the difference is purchase *frequency*, not order size. This suggests growth should
  focus on order frequency/retention rather than upsizing individual orders.
- **Order problems:** the Middle East region has the highest cancellation +
  refund rate (36.1%), notably above South America (28.3%) — worth investigating
  fulfillment or payment issues specific to that region.

## How to run it

```bash
# 1. (Re)generate the CSVs
python generate_data.py

# 2. Load into SQLite (or any SQL engine) and run the queries
sqlite3 sales.db < schema.sql
sqlite3 sales.db ".import --csv customers.csv customers" \
                 ".import --csv products.csv products" \
                 ".import --csv orders.csv orders" \
                 ".import --csv order_items.csv order_items"
sqlite3 sales.db < queries.sql
```

*(For PostgreSQL/MySQL, use the `\copy` / `LOAD DATA` examples noted at the
bottom of `schema.sql`.)*

## Tools used
`SQL` (window functions, CTEs, joins, aggregation) · `Python`/`pandas` for
reproducible synthetic data generation

---
<sub>Dataset is synthetic, generated for portfolio purposes; queries and analysis are original work.</sub>
