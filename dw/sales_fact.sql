-- Active: 1725273956848@@127.0.0.1@5432@dw
CREATE TABLE IF NOT EXISTS sales_fact (
    surrogate_key SERIAL PRIMARY KEY,
    date_id INT NOT NULL,
    junk_id INT NOT NULL ,
    order_id INT NOT NULL ,
    cost FLOAT NOT NULL ,
    quantity INT NOT NULL ,
    unit_price FLOAT NOT NULL,
    gross_income FLOAT NOT NULL,
    FOREIGN KEY (date_id) REFERENCES date_dim(date_id),
    FOREIGN KEY (junk_id) REFERENCES junk_dim(junk_id),
    FOREIGN KEY (order_id) REFERENCES order_dim(order_id));

DROP TABLE sales_fact;