-- Set the Search path

set search_path to Projects;

-- Create the Sales data table

create table sales_data (
	sales_id SERIAL primary key,
	sale_date DATE,
	city VARCHAR(100),
	customer_gender VARCHAR(20) check (customer_gender in ('Male','Female')),
	product_category VARCHAR(100),
	quantity INT check (quantity > 0),
	unit_price numeric(10,2),
	total_price numeric(10,2),
	payment_method VARCHAR(30)
	);

-- Query the created table
select * from sales_data;

-- Insert the sample data
INSERT INTO sales_data (sale_date, city, customer_gender, product_category, quantity, unit_price, total_price, payment_method)
VALUES
('2025-01-12', 'Nairobi', 'Female', 'Food and Beverages', 4, 3.50, 14.00, 'Cash'),
('2025-01-13', 'Nairobi', 'Male', 'Electronics', 1, 120.00, 120.00, 'Credit Card'),
('2025-01-14', 'Nairobi', 'Female', 'Sports and Travel', 2, 45.00, 90.00, 'E-Wallet'),
('2025-02-03', 'Nairobi', 'Male', 'Food and Beverages', 5, 2.00, 10.00, 'Credit Card'),
('2025-02-10', 'Nairobi', 'Female', 'Clothing and Accessories', 3, 20.00, 60.00, 'Cash'),

('2025-01-16', 'Mombasa', 'Male', 'Food and Beverages', 6, 1.50, 9.00, 'E-Wallet'),
('2025-01-18', 'Mombasa', 'Female', 'Electronics', 1, 150.00, 150.00, 'Credit Card'),
('2025-02-20', 'Mombasa', 'Male', 'Clothing and Accessories', 2, 25.00, 50.00, 'Cash'),
('2025-03-05', 'Mombasa', 'Female', 'Sports and Travel', 1, 60.00, 60.00, 'E-Wallet'),
('2025-03-08', 'Mombasa', 'Male', 'Food and Beverages', 7, 2.50, 17.50, 'Cash'),

('2025-02-01', 'Kisumu', 'Female', 'Food and Beverages', 3, 3.00, 9.00, 'Cash'),
('2025-02-14', 'Kisumu', 'Male', 'Electronics', 2, 130.00, 260.00, 'Credit Card'),
('2025-02-17', 'Kisumu', 'Female', 'Clothing and Accessories', 4, 15.00, 60.00, 'E-Wallet'),
('2025-03-03', 'Kisumu', 'Male', 'Sports and Travel', 2, 50.00, 100.00, 'Cash'),
('2025-03-06', 'Kisumu', 'Female', 'Food and Beverages', 6, 2.20, 13.20, 'Credit Card'),

('2025-03-10', 'Nairobi', 'Female', 'Electronics', 1, 200.00, 200.00, 'E-Wallet'),
('2025-03-11', 'Mombasa', 'Male', 'Sports and Travel', 3, 40.00, 120.00, 'Credit Card'),
('2025-03-12', 'Kisumu', 'Female', 'Clothing and Accessories', 2, 30.00, 60.00, 'Cash'),
('2025-03-13', 'Nairobi', 'Male', 'Food and Beverages', 5, 3.10, 15.50, 'Credit Card'),
('2025-03-14', 'Mombasa', 'Female', 'Food and Beverages', 4, 3.00, 12.00, 'E-Wallet');

-- Query the table
select * from sales_data;

-- QUESTION 1: How do the sales of the different product categories compare?

-- Compare the total sales value for each product category 
-- to understand which categories perform best or worst in terms of revenue.

select product_category, sum(total_price) as total_sales
from sales_data
group by product_category 
order by total_sales desc; -- from the results, Electronics products performs best in terms of total sales compared to other products, 
-- Food and Beverages products are the worst performing.

select product_category, sum(total_price) as total_sales,
	ROUND(SUM(total_price) * 100 / SUM(SUM(total_price)) OVER()) as percent_of_total_sales
	from sales_data
	group by product_category
	order by total_sales desc;

--select distinct product_category, total_price
--from sales_data;

-- QUESTION 2: How does gender affect the sales of the different product categories?

-- Understand how much each gender contributes to the total sales of each product category.

select product_category, customer_gender, SUM(total_price) as total_sales,
	ROUND(SUM(total_price) * 100 / SUM(SUM(total_price)) over (partition by product_category),2) as percent_of_category
	from sales_data
	group by product_category, customer_gender
	order by total_sales asc, percent_of_category asc;

-- QUESTION 3: Is there a monthly trend between these product categories?

-- Understand how each product category performs over time (monthly).
-- This helps detect seasonality, growth patterns, or monthly peaks in sales.

select to_char(sale_date, 'YYYY-MM') as sale_month, product_category, SUM(total_price) as total_sales
from sales_data
group by sale_month, product_category 
order by sale_month asc, total_sales desc;

-- QUESTION 4: When consumers purchase product category X, which product category Y are they most likely to buy?

-- Identify product category pairs that are frequently bought together in the same transaction (same customer, same day, same city). 
-- This helps uncover cross-selling opportunities.

SELECT 
    a.product_category AS category_x,
    b.product_category AS category_y,
    COUNT(*) AS times_bought_together
FROM 
    sales_data a
JOIN 
    sales_data b
    ON a.sale_date = b.sale_date
    AND a.city = b.city
    AND a.customer_gender = b.customer_gender
    AND a.product_category < b.product_category  -- avoid duplicates and self-pairing
GROUP BY 
    category_x, category_y
ORDER BY 
    times_bought_together DESC;

-- QUESTION 5: What product category earns the most?

-- Identify the top-earning product category by total sales value (total_price).

select product_category, SUM(total_price) as total_sales
from sales_data
group by product_category 
order by total_sales desc
limit 1;

-- QUESTION 6: What product category earns the least

select product_category, SUM(total_price) as total_sales
from sales_data
group by product_category 
order by total_sales asc
limit 1;

-- QUESTION 7: Explore how the sales of different product categories compare on a per-city basis.

-- Help the business understand which cities perform better or worse per product category. This insight can inform:

--- Inventory allocation

--- Regional marketing

--- Store space decisions

select product_category, city, SUM(total_price) as total_sales
from sales_data
group by product_category, city 
order by total_sales desc;

-- QUESTION 8: Explore how each product category’s sales relate to the payment method used.

-- Identify which payment methods are most used for each product category.
-- This can help:

--- Improve payment channel support

--- Design targeted promotions (e.g., cashback on e-wallets for electronics)

select product_category, payment_method, SUM(total_price) as total_sales,
ROUND(SUM(total_price) * 100 / SUM(SUM(total_price)) over (partition by product_category),2) as percent_category
from sales_data
group by product_category, payment_method 
order by product_category, total_sales desc;