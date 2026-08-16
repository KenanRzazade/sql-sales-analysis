-- Schema for the Sales Performance Analysis project
-- Compatible with PostgreSQL / SQLite / MySQL (minor type tweaks may be needed per engine)

CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    region        TEXT NOT NULL,
    segment       TEXT NOT NULL,
    signup_date   DATE NOT NULL
);

CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY,
    product_name  TEXT NOT NULL,
    category      TEXT NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date    DATE NOT NULL,
    status        TEXT NOT NULL CHECK (status IN ('Completed', 'Cancelled', 'Refunded'))
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER NOT NULL REFERENCES orders(order_id),
    product_id    INTEGER NOT NULL REFERENCES products(product_id),
    quantity      INTEGER NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL,
    discount      NUMERIC(4,2) NOT NULL DEFAULT 0  -- e.g. 0.10 = 10% off
);

-- Load data (PostgreSQL example — adjust path/COPY syntax for your engine):
-- \copy customers   FROM 'customers.csv'   DELIMITER ',' CSV HEADER;
-- \copy products    FROM 'products.csv'    DELIMITER ',' CSV HEADER;
-- \copy orders      FROM 'orders.csv'      DELIMITER ',' CSV HEADER;
-- \copy order_items FROM 'order_items.csv' DELIMITER ',' CSV HEADER;
