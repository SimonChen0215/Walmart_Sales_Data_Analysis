-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
)

-- -----------------------------------------------------------------
-- ------------------------Feature Engineering----------------------

-- time_of_day
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20)
UPDATE sales
SET time_of_day = (
	CASE 
			WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
			WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
			ELSE 'Evening'
	END
	);

-- day_name
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10)
UPDATE sales
SET day_name = SUBSTR(DAYNAME(date),1,3)

-- month_name
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10)
UPDATE sales
SET month_name = SUBSTR(MONTHNAME(date),1,3)


-- -----------------------------------------------------------------------------
-- ------------------------Exploratory Data Analysis (EDA)----------------------

-- -------------------Generic Questions--------------
-- How many unique cities does the data have?
SELECT DISTINCT city 
FROM sales;
-- In which city is each branch?
SELECT DISTINCT branch
FROM sales;

SELECT DISTINCT city, branch
FROM sales

-- -------------------Product-----------------
-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
FROM sales

-- What is the most common payment method?
SELECT payment,COUNT(*) AS Count
FROM sales
GROUP BY payment
ORDER BY Count DESC

-- What is the most selling product line?
SELECT product_line,COUNT(product_line) AS Count
FROM sales
GROUP BY product_line
ORDER BY Count DESC

-- What is the total revenue by month?
SELECT 
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month
ORDER BY total_revenue

-- What month had the largest COGS? (January)
SELECT 
	month_name AS month,
    SUM(cogs) AS COGS
FROM sales
GROUP BY month
ORDER BY COGS DESC

-- What product line had the largest revenue?
SELECT
	product_line,
    SUM(total) AS Revenue
FROM sales
GROUP BY product_line
ORDER BY Revenue DESC

-- What is the city with the largest revenue?
SELECT
	city,
    SUM(total) AS Revenue
FROM sales
GROUP BY city
ORDER BY Revenue DESC

-- What product line had the largest VAT?
SELECT
	product_line,
    AVG(tax_pct) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	invoice_id, 
    product_line,
    (CASE
		WHEN total > (SELECT AVG(total) FROM sales) THEN 'Good'
        ELSE 'Bad'
	END) AS good_bad
FROM sales
        
-- Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT SUM(quantity)/3 FROM sales)

-- What is the most common product line by gender?
SELECT 
	gender,
    product_line, 
    COUNT(*) AS count
FROM sales
GROUP BY 
	gender, 
    product_line
ORDER BY gender,count DESC

-- What is the average rating of each product line?
SELECT 
	product_line, AVG(rating) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC

-- ---------------------------------------------------------------------------
-- --------------------------------- Sales -----------------------------------

-- Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
	COUNT(*) AS count
FROM sales
WHERE day_name = 'Mon'
GROUP BY time_of_day

-- Which of the customer types brings the most revenue?
SELECT 
	customer_type,
	SUM(total) AS Revenue
FROM sales
GROUP BY customer_type
ORDER BY Revenue DESC

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
	city,
    AVG(tax_pct) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC

-- Which customer type pays the most in VAT?
SELECT 
	customer_type type,
    AVG(tax_pct) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC

-- ---------------------- Customers ----------------------
-- How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type)
FROM sales

-- How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment)
FROM sales

-- What is the most common customer type?
SELECT customer_type, COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC

-- Which customer type buys the most?
SELECT customer_type, SUM(total) AS sum
FROM sales
GROUP BY customer_type
ORDER BY sum DESC

-- What is the gender of most of the customers?
SELECT gender, COUNT(gender) AS number
FROM sales
GROUP BY gender
ORDER BY number DESC

-- What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS number
FROM sales
GROUP BY branch,gender
ORDER BY branch

-- Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS rating
FROM sales
GROUP BY time_of_day
ORDER BY rating DESC

-- Which time of the day do customers give most ratings per branch?
SELECT branch,time_of_day, AVG(rating) AS rating
FROM sales
GROUP BY branch,time_of_day
ORDER BY branch, rating DESC

-- Which day fo the week has the best avg ratings?
SELECT day_name, AVG(rating) AS rating
FROM sales
GROUP BY day_name
ORDER BY rating DESC

-- Which day of the week has the best average ratings per branch?
SELECT branch,day_name, AVG(rating) AS rating
FROM sales
GROUP BY branch,day_name
ORDER BY branch, rating DESC