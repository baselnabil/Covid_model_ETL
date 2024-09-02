-- Active: 1725273956848@@127.0.0.1@5432@dw
CREATE TABLE IF NOT EXISTS sales_fact (
    surrogate_key SERIAL PRIMARY KEY,
    date_id INT NOT NULL,
    cost FLOAT NOT NULL ,
    quantity INT NOT NULL ,
    unit_price FLOAT NOT NULL,
    gross_income FLOAT NOT NULL,
    FOREIGN KEY (date_id) REFERENCES date_dim(date_id)
);