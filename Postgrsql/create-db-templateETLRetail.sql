-- Active: 1721872569477@@127.0.0.1@5432
CREATE DATABASE

create table date_dim (
    date_id int not null PRIMARY KEY,
    date date not null,
    year int not null,
    month int not null,
    day int not null,
    is_holiday boolean not null,
    month_name VARCHAR(200) not null,
    day_name VARCHAR(200) not null,
    quarter int not null
);

ALTER TABLE date_dim ALTER COLUMN date TYPE VARCHAR(255);

DO $$
DECLARE
    start_date DATE := '1/1/2019';
    end_date DATE := '3/31/2019'; 
    today DATE;
BEGIN
    today := start_date;
    WHILE today <= end_date LOOP 
        INSERT INTO date_dim
        (
            date_id,
            date, 
            year, 
            month, 
            day,
            is_holiday,
            month_name,
            day_name,
            quarter
        )
        VALUES
        (
            to_char(today, 'YYYYMMDD')::INTEGER,
            today,
            EXTRACT(YEAR FROM today),
            EXTRACT(MONTH FROM today),
            EXTRACT(DAY FROM today),
            CASE WHEN EXTRACT(ISODOW FROM today) IN (6, 7) THEN TRUE ELSE FALSE END, 
            to_char(today, 'Month'),
            to_char(today, 'Day'),
            EXTRACT(QUARTER FROM today) 
        );
        today := today + INTERVAL '1 day';
    END LOOP; -- Added END LOOP keyword
END $$;

select * from date_dim;

SELECT date_id from date_dim;

drop table date_dim;

CREATE TABLE IF NOT EXISTS order_dim (
    order_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    product_line VARCHAR(50),
    unit_price INT NOT NULL,
    quantity INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    rating INT
)

ALTER TABLE order_dim ALTER COLUMN invoice_id TYPE VARCHAR(255);

ALTER TABLE order_dim ALTER COLUMN unit_price TYPE DECIMAL(5, 2);

select * from order_dim;

drop table order_dim;

CREATE TABLE IF NOT EXISTS junk_dim (
    junk_id SERIAL PRIMARY KEY,
    customer_sex VARCHAR(9),
    branch CHAR(4),
    customer_type VARCHAR(9),
    gross_income FLOAT
);

ALTER TABLE junk_dim ALTER COLUMN gross_income TYPE DECIMAL(5, 2);

select * from junk_dim;

drop table junk_dim;

CREATE TABLE IF NOT EXISTS sales_fact (
    surrogate_key SERIAL PRIMARY KEY,
    date_id INT,
    junk_id INT,
    order_id INT,
    date date,
    Total FLOAT,
    quantity INT,
    unit_price FLOAT,
    gross_income FLOAT,
    FOREIGN KEY (date_id) REFERENCES date_dim (date_id),
    FOREIGN KEY (junk_id) REFERENCES junk_dim (junk_id),
    FOREIGN KEY (order_id) REFERENCES order_dim (order_id)
);

ALTER TABLE sales_fact ALTER COLUMN date TYPE VARCHAR(255);

ALTER TABLE sales_fact ALTER COLUMN unit_price TYPE DECIMAL(5, 2);

ALTER TABLE sales_fact ALTER COLUMN gross_income TYPE DECIMAL(5, 2);

ALTER TABLE sales_fact ALTER COLUMN Total TYPE DECIMAL(10, 2);

select * from sales_fact;

drop table sales_fact;

select * from date_dim;

-- Order_id
UPDATE sales_fact
SET
    order_id = od.order_id
FROM order_dim od
WHERE
    sales_fact.quantity = od.quantity
    AND sales_fact.order_id IS NULL;

-- Ensure proper indexes are in place
CREATE INDEX idx_sales_fact_quantity ON sales_fact (quantity);

CREATE INDEX idx_order_dim_quantity ON order_dim (quantity);

CREATE INDEX idx_sales_fact_order_id ON sales_fact (order_id);

CREATE INDEX idx_order_dim_order_id ON order_dim (order_id);

-- run this befor make update
EXPLAIN
ANALYZE
WITH
    cte AS (
        SELECT ctid
        FROM sales_fact
        WHERE
            order_id IS NULL
        ORDER BY ctid
        LIMIT 1000
    )
UPDATE sales_fact sf
SET
    order_id = od.order_id
FROM order_dim od, cte
WHERE
    sf.ctid = cte.ctid
    AND sf.quantity = od.quantity
    AND sf.order_id IS NULL;

-- EXPLAIN
-- ANALYZE
-- UPDATE sales_fact sf
-- SET
--     order_id = od.order_id
-- FROM order_dim od
-- WHERE
--     sf.quantity = od.quantity
--     AND sf.order_id IS NULL;

VACUUM ANALYZE sales_fact;

VACUUM ANALYZE order_dim;

-- DO $$
-- DECLARE
--     batch_size INTEGER := 10000;
--     last_ctid tid;
--     rows_updated INTEGER;
-- BEGIN
--     last_ctid := '(0,0)';
--     LOOP
--         WITH cte AS (
--             SELECT ctid
--             FROM sales_fact
--             WHERE order_id IS NULL
--               AND ctid > last_ctid
--             ORDER BY ctid
--             LIMIT batch_size
--         )
--         UPDATE sales_fact sf
--         SET order_id = od.order_id
--         FROM order_dim od, cte
--         WHERE sf.ctid = cte.ctid
--           AND sf.quantity = od.quantity
--           AND sf.order_id IS NULL;

--         GET DIAGNOSTICS rows_updated = ROW_COUNT;

--         IF rows_updated < batch_size THEN
--             EXIT;
--         END IF;

--         SELECT MAX(ctid) INTO last_ctid FROM cte;
--     END LOOP;
-- END $$;

SELECT COUNT(*) FROM sales_fact WHERE order_id IS NULL;

SELECT COUNT(*) FROM sales_fact WHERE junk_id IS NULL;

SELECT COUNT(*) FROM sales_fact WHERE date_id IS NULL;

SELECT COUNT(*) FROM sales_fact WHERE date IS NuLL;

BEGIN;
-- Create indexes concurrently (this doesn't block reads/writes)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sales_fact_quantity ON sales_fact (quantity);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_dim_quantity ON order_dim (quantity);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sales_fact_order_id ON sales_fact (order_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_dim_order_id ON order_dim (order_id);

VACUUM ANALYZE sales_fact;

VACUUM ANALYZE order_dim;

-- Junk_dim
CREATE INDEX idx_sales_fact_junk_id ON sales_fact (junk_id);

CREATE INDEX idx_junk_dism_junk_id ON junk_dim (junk_id);

UPDATE sales_fact sf
SET
    junk_id = jd.junk_id
FROM junk_dim jd
WHERE
    sf.gross_income = jd.gross_income
    AND sf.junk_id IS NULL;

SELECT * FROM sales_fact WHERE junk_id IS NOT NULL;

-- date_dim

UPDATE sales_fact sf
SET
    date_id = dd.date_id
FROM date_dim dd
WHERE
    TO_CHAR(
        TO_DATE(TRIM(sf.date), 'MM/DD/YYYY'),
        'YYYY-MM-DD'
    ) = dd.date
    AND sf.date_id IS NULL;

CREATE INDEX idx_sales_fact_date ON sales_fact (date);

CREATE INDEX idx_date_dim_date ON date_dim (date);

CREATE INDEX idx_sales_fact_date_id ON sales_fact (date_id);

select * from sales_fact;

SELECT date FROM sales_fact LIMIT 10;

SELECT date FROM date_dim LIMIT 10;

-- This relation between fact and order _dim
SELECT sf.surrogate_key, sf.quantity, sf.order_id, od.product_line, od.unit_price
FROM sales_fact sf
    JOIN order_dim od ON sf.order_id = od.order_id
LIMIT 100;

-- This combine both fact and two dimensions
SELECT o.order_id, o.invoice_id, o.unit_price, o.quantity, o.payment_method, o.rating, j.junk_id, j.customer_sex, j.branch, j.customer_type
FROM
    sales_fact sf
    JOIN order_dim o ON sf.order_id = o.order_id
    JOIN junk_dim j ON sf.junk_id = j.junk_id;