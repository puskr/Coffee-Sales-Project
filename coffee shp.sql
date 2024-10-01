select sum(unit_price * transaction_qty) AS Total_Sales
from coffee_shop_sales
where
month(transaction_Date)=5

select * from coffee_shop_sales;

create table coffee_shop_sales
(
	transaction_id int,
	transaction_date date,
	transaction_time time,
	transaction_qty int,
	store_id int,
	store_location varchar(30),
	product_id int,
	unit_price decimal,
	product_category varchar(25),
	product_type varchar(50),
	product_detail varchar(50)
)

copy coffee_shop_sales 
from 'C:\Program Files\PostgreSQL\16\data\data_copy\coffee_shop_sales.csv'
delimiter ','
csv header;

--finding total sales of the month- here 3 = March

SELECT CAST(ROUND(SUM(unit_price * transaction_qty), 2) AS NUMERIC(10, 2)) AS Total_Sales
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 3;

--Finding month-on-month increase or decrease in sales

SELECT 
    EXTRACT(MONTH FROM transaction_date) AS month_sale,
    CAST(ROUND(SUM(unit_price * transaction_qty), 2) AS DECIMAL) AS total_sales,
    ROUND(
        (
            (
                SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) 
	OVER (ORDER BY EXTRACT(MONTH FROM transaction_date))
            ) / LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY EXTRACT(MONTH FROM transaction_date))
        ) * 100, 
        2
    ) AS mon_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    EXTRACT(MONTH FROM transaction_date) IN (4, 5)
GROUP BY 
    EXTRACT(MONTH FROM transaction_date)
ORDER BY 
    EXTRACT(MONTH FROM transaction_date);



--find all months sales, January to June

SELECT 
    EXTRACT(MONTH FROM transaction_date) AS month_sale,
    EXTRACT(YEAR FROM transaction_date) AS year_sale,
    SUM(unit_price * transaction_qty) AS total_sales
FROM 
    coffee_shop_sales
GROUP BY 
    EXTRACT(YEAR FROM transaction_date),
    EXTRACT(MONTH FROM transaction_date)
ORDER BY 
    EXTRACT(YEAR FROM transaction_date),
    EXTRACT(MONTH FROM transaction_date);


--another code with month name

SELECT 
    CASE EXTRACT(MONTH FROM transaction_date)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE 'Unknown'  -- Handle unexpected cases
    END AS month_name,
    EXTRACT(YEAR FROM transaction_date) AS year_sale,
    SUM(unit_price * transaction_qty) AS total_sales
FROM 
    coffee_shop_sales
GROUP BY 
    EXTRACT(YEAR FROM transaction_date),  -- Group by year
    EXTRACT(MONTH FROM transaction_date)  -- Group by month
ORDER BY 
    EXTRACT(YEAR FROM transaction_date),
    EXTRACT(MONTH FROM transaction_date);


--find the difference in sales between the selected month and the previous month.

WITH MonthlySales AS (
    SELECT 
        CASE EXTRACT(MONTH FROM transaction_date)
            WHEN 1 THEN 'January'
            WHEN 2 THEN 'February'
            WHEN 3 THEN 'March'
            WHEN 4 THEN 'April'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'June'
            ELSE 'Unknown'
        END AS month_sale,
        SUM(unit_price * transaction_qty) AS total_sales,
        LAG(SUM(unit_price * transaction_qty)) 
	OVER (ORDER BY EXTRACT(MONTH FROM transaction_date)) AS prev_month_sales
    FROM 
        coffee_shop_sales
    WHERE 
        EXTRACT(YEAR FROM transaction_date) = 2023
    GROUP BY 
        EXTRACT(MONTH FROM transaction_date)
)

SELECT 
    month_sale,
    total_sales,
    COALESCE(total_sales - prev_month_sales, 0) AS sales_difference
FROM 
    MonthlySales
ORDER BY 
    CASE month_sale
        WHEN 'January' THEN 1
        WHEN 'February' THEN 2
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        ELSE 7  -- 'Unknown' will appear at the end
    END;

--calculate the total number of orders for each month

select * from coffee_shop_sales

SELECT 
    count(transaction_id) AS total_qty,
     CASE EXTRACT(MONTH FROM transaction_date)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE 'Unknown'  -- Handle unexpected cases
    END AS month_name
FROM 
    coffee_shop_sales
GROUP BY  
        CASE EXTRACT(MONTH FROM transaction_date)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE 'Unknown'
    END
ORDER BY 
    MIN(EXTRACT(MONTH FROM transaction_date));  -- Optional: Order by the numerical month order


--determine the month-on-month increase or decrease in the number of orders


SELECT 
    EXTRACT(MONTH FROM transaction_date) AS MONTH,
    CAST(ROUND(COUNT(transaction_id)) AS INTEGER) AS total_orders,
    ROUND(
        (
            (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1)
	OVER (ORDER BY EXTRACT(MONTH FROM transaction_date)))::NUMERIC /
            LAG(COUNT(transaction_id), 1) OVER (ORDER BY EXTRACT(MONTH FROM transaction_date))
        ) * 100,
        2
    ) AS month_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    EXTRACT(MONTH FROM transaction_date) IN (2, 3)
GROUP BY 
    EXTRACT(MONTH FROM transaction_date)
ORDER BY 
    EXTRACT(MONTH FROM transaction_date);


--calculate the total quantity sold for every month


SELECT 
    SUM(transaction_qty) AS total_quantity,
    CASE EXTRACT(MONTH FROM transaction_date)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE 'Unknown'
    END AS month_name
FROM 
    coffee_shop_sales
WHERE 
    EXTRACT(YEAR FROM transaction_date) = 2023
GROUP BY 
    EXTRACT(MONTH FROM transaction_date)
ORDER BY 
    EXTRACT(MONTH FROM transaction_date);

--total quantity sold on month difference and month growth


SELECT 
    month_name,
    total_quantity,
    ROUND(
        (total_quantity - LAG(total_quantity, 1) OVER (ORDER BY month_num))::numeric 
        / NULLIF(LAG(total_quantity, 1) OVER (ORDER BY month_num), 0) * 100
    , 2) AS sales_diff
FROM (
    SELECT 
        EXTRACT(MONTH FROM transaction_date) AS month_num,
        CASE EXTRACT(MONTH FROM transaction_date)
            WHEN 1 THEN 'January'
            WHEN 2 THEN 'February'
            WHEN 3 THEN 'March'
            WHEN 4 THEN 'April'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'June'
            WHEN 7 THEN 'July'
            WHEN 8 THEN 'August'
            WHEN 9 THEN 'September'
            WHEN 10 THEN 'October'
            WHEN 11 THEN 'November'
            WHEN 12 THEN 'December'
            ELSE 'Unknown'
        END AS month_name,
        SUM(transaction_qty) AS total_quantity
    FROM
        coffee_shop_sales
    GROUP BY
        EXTRACT(MONTH FROM transaction_date)
) AS monthly_totals
ORDER BY
    month_num;

--calculate total sum, total quantity sold and total orders for particular date

select 
round(sum(unit_price * transaction_qty)) as total_sales,
sum (transaction_qty) as tota_qty_sold,
count ( transaction_id) as total_orders
from coffee_shop_sales
where transaction_date = '2023-05-18'

SELECT 
    CONCAT(
        ROUND(SUM(unit_price * transaction_qty) / 1000.0, 1),
        'k'
    ) AS total_sales_display,
    CONCAT(
        ROUND(SUM(transaction_qty) / 1000.0, 1),
        'k'
    ) AS total_qty_sold,
    CONCAT(
        ROUND(COUNT(transaction_id) / 1000.0, 1),
        'k'
    ) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18';



--find sales on weekend
SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM transaction_Date) IN (0, 6) THEN 'WEEKENDS'
        ELSE 'Weekdays'
    END AS day_sales,
    concat(round(SUM(transaction_qty * unit_price)/1000,1), 'k') AS total_sales
FROM 
    coffee_shop_sales
where extract(month from transaction_date) = 3
GROUP BY 
    CASE 
        WHEN EXTRACT(DOW FROM transaction_Date) IN (0, 6) THEN 'WEEKENDS'
        ELSE 'Weekdays'
    END;

--SALES VALUE BY STORE LOCATION

SELECT  store_location, concat(round(sum(unit_price*transaction_qty)/1000,2), 'K') as total_sales
from coffee_shop_sales
where extract(month from transaction_date)=5
group by store_location
order by sum(unit_price*transaction_qty) desc;

-- daily sales with average for specific month

select 

concat(round(avg(total_sales)/1000,1), 'k')
from
(
	select sum(unit_price*transaction_qty) as total_sales
	from coffee_shop_sales
	where extract(month from transaction_date)=2
	group by transaction_Date
	) as internal_query

--daily sale for particular month

SELECT 
    EXTRACT(DAY FROM transaction_Date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    EXTRACT(MONTH FROM transaction_date) = 5  -- Filter for May
GROUP BY 
    EXTRACT(DAY FROM transaction_Date)  -- Group by day of the month
ORDER BY 
    EXTRACT(DAY FROM transaction_Date);  -- Optional: Order by day of the month


--calculating total_sales and avg sales for everyday and finding avg line 
SELECT 
    day_of_month,
    CASE
        WHEN total_sales > avg_sales THEN 'above average'
        WHEN total_sales < avg_sales THEN 'below average'
        ELSE 'average'
    END AS sales_status,
	total_sales
FROM (
    SELECT 
        extract(day from transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        avg(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        extract(month from transaction_date) = 5
    GROUP BY 
        extract(day from transaction_date)
) AS sales_summary
ORDER BY 
    day_of_month;

--calculate sales by product category

select product_category,
sum(transaction_qty* unit_price) as total_Sales
from coffee_shop_sales
where extract(month from transaction_date)=5
group by product_Category
order by 2;

-- find top 10 product by sales

select product_type,
sum(transaction_qty* unit_price) as total_Sales
from coffee_shop_sales
where extract(month from transaction_date)=5 
group by product_type
order by 2 desc
limit 10;

-- find total sales, total quantity sold in particular time of the day in particular month

SELECT 
    SUM(transaction_qty * unit_price) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(*) 
FROM 
    coffee_shop_sales
WHERE 
    EXTRACT(MONTH FROM transaction_date) = 5 
    AND EXTRACT(DOW FROM transaction_date) = 1
    AND EXTRACT(HOUR FROM transaction_time) = 8

-- find total sales in the hour of the day in month

select extract(hour from transaction_time),
sum(unit_price*transaction_qty) as total_sales
from coffee_shop_sales
where extract(month from transaction_date)=5
group by extract(hour from transaction_time)
order by extract(hour from transaction_time)

--calculate total sale for per day of the month

select
case 
when extract(dow from transaction_date)=1 then 'Monday'
when extract(dow from transaction_date)=2 then 'Tuesday'
when extract(dow from transaction_date)=3 then 'Wednesday'
when extract(dow from transaction_date)=4 then 'Thursday'
when extract(dow from transaction_date)=5 then 'Friday'
when extract(dow from transaction_date)=6 then 'Saturday'
else 'sunday'
end as days_of_the_week,
round(sum(unit_price*transaction_qty)) as total_sales
from
coffee_shop_sales
where extract(month from transaction_date)=5
group by
case 
when extract(dow from transaction_date)=1 then 'Monday'
when extract(dow from transaction_date)=2 then 'Tuesday'
when extract(dow from transaction_date)=3 then 'Wednesday'
when extract(dow from transaction_date)=4 then 'Thursday'
when extract(dow from transaction_date)=5 then 'Friday'
when extract(dow from transaction_date)=6 then 'Saturday'
else 'sunday'
end;





