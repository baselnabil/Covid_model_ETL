create table date_dim (
    date_id int not null PRIMARY KEY ,
    date date not null, 
    year int not null , 
    month int not null ,
    day int not null ,
    is_holiday boolean not null ,
    month_name VARCHAR(200) not null ,
    day_name VARCHAR(200) not null,
    quarter int not null
);

DO $$
DECLARE
    start_date DATE := '2018-01-01';
    end_date DATE := '2019-12-31'; 
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

TRUNCATE table date_dim;
SELECT date_id from date_dim;