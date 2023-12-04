CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT
);
 
 -- -------------------------------------------------------------------
 -- ---------------------- Feature engineering ------------------------
 
 -- Create a new column time_of_day.
 
 SELECT 
	time,
    CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END AS time_of_day
 FROM sales;
 
 ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
 
 UPDATE sales
 SET time_of_day = 
CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
END;

-- Create a new column day_name.

SELECT
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- Create a new column month_name.

SELECT 
	date,
    MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);  

-- --------------------------------------------------------------------
-- ---------------------------- Generic -------------------------------
 
-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- --------------------------------------------------------------------
-- ----------------------------- Product ------------------------------

-- How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT product_line) AS unique_product_lines
FROM sales;

-- What is the most common payment method?
SELECT 
	payment_method,
	COUNT(payment_method) AS total_count
FROM sales
GROUP BY payment_method
ORDER BY total_count DESC;

-- What is the most selling product line?
SELECT 
	product_line,
    COUNT(product_line) AS count_of_sales
FROM sales
GROUP BY product_line
ORDER BY count_of_sales DESC;

-- What is the total revenue by month?
SELECT 
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had a largest COGS?
SELECT 
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT
	product_line,
    SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT
	branch,
	city,
    SUM(total) as total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT
	product_line,
    AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product line showing 
-- 'Good', 'Bad'. Good if it´s greater than average sales.

-- first way (by using a view)
CREATE VIEW AvgQuantityView AS
SELECT
    AVG(quantity) AS avg_qnty
FROM sales;

SELECT
    product_line,
    CASE
        WHEN quantity > (SELECT avg_qnty FROM AvgQuantityView) THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM sales
GROUP BY product_line;

-- second way...
SELECT
    product_line,
    CASE
        WHEN quantity > (SELECT AVG(quantity) FROM sales) THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) AS average_sold
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT 
	product_line,
    gender,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
    ROUND(AVG(rating), 2) AS average_rating
FROM sales
GROUP BY product_line
ORDER BY average_rating DESC;

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------

-- Number of sales made in each time of the day per weekday.
SELECT 
    time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Saturday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax/VAT percent?
SELECT 
	city,
    MAX(VAT) AS vat_pct
FROM sales
GROUP BY city
ORDER BY vat_pct DESC;

-- Which customer type pays the most in VAT?
SELECT 
	customer_type,
    AVG(VAT) AS total_max
FROM sales
GROUP BY  customer_type
ORDER BY total_max DESC;

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------

-- How many unique customer types does the data have?
SELECT 	
	Count(DISTINCT(customer_type)) AS unique_types
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
	COUNT(DISTINCT(payment_method)) AS cnt_payment_method
FROM sales;

-- What is the most common customer type?
SELECT 
	customer_type,
    COUNT(customer_type) AS count_of_custm_type
FROM sales
GROUP BY customer_type
ORDER BY count_of_custm_type DESC;

-- Which customer type buys the most?
SELECT 
	customer_type,
    COUNT(*) AS total_sales
FROM sales
GROUP BY customer_type
ORDER BY total_sales DESC;

-- What is the gender of most of the customers?
SELECT
	gender,
    COUNT(*) AS cnt_of_gender
FROM sales
GROUP BY gender
ORDER BY cnt_of_gender DESC;

-- What is the gender distribution per branch?
SELECT
    branch,
    gender,
    COUNT(*) AS cnt_of_gender
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- Which time of the day do customers give most ratings?
SELECT
    time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT 
	branch,
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY branch
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings?
SELECT 
	day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT 
	branch,
	day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY branch
ORDER BY branch;