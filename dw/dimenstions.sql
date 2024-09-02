-- Active: 1725273956848@@127.0.0.1@5432@dw


-- --Invoice ID,
-- Branch,City,
-- Customer type,
-- Gender,
-- Product line,
-- Unit price,
-- Quantity,
-- Tax 5%,
-- Total,
-- Date,Time,
-- Payment,cogs,
-- gross margin percentage,
-- gross income,Rating
CREATE TABLE if not EXISTS customer_dim (
    customer_id  SERIAL PRIMARY KEY,
    invoice_id  int  , 
    gender VARCHAR(9) ,
    rating FLOAT ,
    customer_city VARCHAR(50) ,
    payment VARCHAR(50) not null ,
    customer_type VARCHAR(50)
);

