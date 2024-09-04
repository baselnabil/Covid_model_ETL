-- Active: 1725273956848@@127.0.0.1@5432@dw
CREATE TABLE IF NOT EXISTS order_dim(
    order_id SERIAL PRIMARY KEY , 
    invoice_id INT NOT NULL,
    product_line VARCHAR(50),
    unit_price INT NOT NULL , 
    quantity INT NOT NULL , 
    payment_method VARCHAR(50) NOT NULL ,
    rating INT );

DROP 

CREATE TABLE IF NOT EXISTS junk_dim (
    junk_id SERIAL PRIMARY KEY , 
    customer_sex VARCHAR(9) ,
    branch CHAR(4) ,
    customer_type VARCHAR(9)
);