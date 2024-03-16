#dropping database initially if exists
#drop database if exists salesdatawalmart; 

#creating database (for not getting error used if not exists)
create database if not exists salesdatawalmart; 

#selecting the database
use salesdatawalmart; 

#dropping the sales table if existed before
#drop table if exists sales; 

# creating sales table and making columns
create table if not exists sales (
invoice_id VARCHAR(30) not null primary key,
branch VARCHAR(5) not null,
city VARCHAR(30) not null,
customer_type VARCHAR(30) not null,
gender VARCHAR(30) not null,
product_line VARCHAR(100) not null,
unit_price DECIMAL(10, 2) not null,
quantity INT not null,
VAT FLOAT(6, 4) not null,
total DECIMAL(12, 4) not null,
date DATEtime not null,
time time not null,
payment_method VARCHAR(15) not null,
cogs DECIMAL(10, 2) not null,
gross_margin_percentage FLOAT(11, 9) not null,
gross_income DECIMAL(12, 6) not null,
rating FLOAT(3, 2) not null);


# import data from csv 
-- Now after the data imported now cleaning the data


#---------------------------------------------------------------------------
###----------------------------------EDA------------------------------------
#---------------------------------------------------------------------------


# Data Wrangling / Data Cleaning--------------------------------------------
-- we have inserted data to the table with not null command so there is no null data in the table

# Feature engineering-------------------------------------------------------
-- generating some new columns for better understand the data

#1.time_of_day
-- adding time of the day i.e. morning, afternoon,evening and night:
-- to see what logic we gonna use (main logical query)
select time, case
when time between '04:00:01' AND '12:00:00' Then 'Morning'
when time between '12:00:01' AND '17:00:00' Then 'Afternoon'
when time between '17:00:01' AND '21:00:00' Then 'Evening'
Else 'Night'
END as time_of_day
from sales; 
-- making column time_of_day in main data
alter table sales add column time_of_day varchar(10); 
-- updating the data into time_of_day column in main data, here 1st 'time' is time function and 2nd 'time' is column name
update sales set time_of_day = (
case
when time(time) between '04:00:01' AND '12:00:00' Then 'Morning'
when time(time) between '12:00:01' AND '17:00:00' Then 'Afternoon'
when time(time) between '17:00:01' AND '21:00:00' Then 'Evening'
Else 'Night'
END); 

#2.day_name
-- adding name of the day i.e. Monday to sunday:
-- to see what logic we gonna use (main logical query):
select date,dayname(date) as day_name
from sales; 
-- making column time_of_day in main data
alter table sales add column day_name varchar(10); 
-- updating the data into day_name column in main data
update sales set day_name = dayname(date); 

#2.month_name
-- adding name of the month i.e. january to december:
-- to see what logic we gonna use (main logical query):
select date,monthname(date) as month_name
from sales; 
-- making column time_of_day in main data
alter table sales add column month_name varchar(10); 
-- updating the data into day_name column in main data
update sales set month_name = monthname(date); 

-- -------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------
######---------------------------Business Questions-------------------------------------
-- -------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------
## Generic questions--------------------------------------------------------------------
-- -------------------------------------------------------------------------------------

#Q1) How many unique cities does the data have?
-- seeing the unique city names
select distinct city from sales;
-- seeing the number of unique cities
select count(distinct city) as total_unique_cities from sales;

#Q2) in which city is each branch?
-- seeing unique branch names per city
select distinct city, branch from sales;

-- cross checking 
select city, branch from sales where city = 'Yangon';
select city, branch from sales where city = 'Naypyitaw';
select city, branch from sales where city = 'Mandalay';
select city, branch from sales where branch = 'A';
select city, branch from sales where branch = 'B';
select city, branch from sales where branch = 'C';

-- -------------------------------------------------------------------------------------
## Product Questions--------------------------------------------------------------------
-- -------------------------------------------------------------------------------------

#Q1) How many unique products lines does the data have?
-- seeing unique product lines 
select distinct product_line from sales;
-- seeing total number of unique product lines
select count(distinct product_line) as total_product_lines from sales;

#Q2) what is the most common payment method?
-- seeing counts of payment methods
select payment_method,count(payment_method) as total from sales group by payment_method;
-- seeing most counts so using decending and making limit to 1 so we can see most number 
select payment_method,count(payment_method) as total from sales group by payment_method order by total desc limit 1;

#Q3) what is the most selling product line?
-- as we know from data details the column total is the total gross sales
-- seeing product line wise total sales
select product_line,sum(quantity) as total_quantity from sales group by product_line;
-- now seeing most selling line
select product_line,sum(quantity) as total_quantity from sales group by product_line order by total_quantity desc limit 1;

#Q4) what is the total revenue by month?
-- total revenue month wise
select month_name as month, sum(total) as total_revenue from sales group by month;
-- seeing from max revenue to minimum
select month_name as month, sum(total) as total_revenue from sales group by month order by total_revenue desc;

#Q5) what month had the largest COGS?
-- Identifies the month with the largest Cost of Goods Sold and limit used to see only 1 output
select month_name as month, sum(cogs) as cogs from sales group by month order by cogs desc limit 1;

#Q6) what product line had the largest revenue?
-- 
select product_line, sum(total) as revenue from sales group by product_line order by revenue desc limit 1;

#Q7) what is the city with largest revenue?
select city, sum(total) as revenue from sales group by city order by revenue desc limit 1;

#Q8) what product line has the largest VAT?
-- this would give us total tax 
select product_line, sum(VAT) as VAT from sales group by product_line order by VAT desc limit 1;
-- but we need largest VAT means we need average
select product_line, avg(VAT) as avg_VAT from sales group by product_line order by avg_VAT desc limit 1;

#Q9) Fetch each product line and add a column to those product line showing 'Good','Bad'.good if its greater than average sales 
-- seeing average quantity
select avg(quantity) from sales;
-- here we need to use subquery because if we use aggrigated function it should be in group by ranges but here we cant use groupby so subquery needed
select product_line, (case when quantity > (select avg(quantity) from sales) then 'Good' else 'Bad' end) as Col from sales;

#Q10) Which branch sold more products than average product sold?
-- to see avg quantity
select avg(quantity) as avg_sold from sales;
-- using having clause
select branch, sum(quantity) as total_quantity from sales group by branch having sum(quantity) > (select avg(quantity) from sales);

#Q11) What is the most common product line by gender?
-- here we can use anything is count line count(product_line), count(*) etc its gonna give same result
select gender,product_line, count(gender) as Num_sales from sales group by product_line,gender order by Num_sales desc;

#Q12) What is the average rating of each product line?
select product_line, avg(rating) as avg_rating from sales group by product_line;

-- -------------------------------------------------------------------------------------
# Sales Questions-----------------------------------------------------------------------
-- -------------------------------------------------------------------------------------

#Q1) Number of sales made in each time of the day per weekday
-- gives daywise and time of the day wise total sales
SELECT day_name, time_of_day, COUNT(*) AS total_sales FROM sales GROUP BY day_name,time_of_day ORDER BY day_name, time_of_day;

#Q2) Which of the customer brings the most revenue?
select customer_type, sum(total) as total_revenue from sales group by customer_type order by total_revenue desc limit 1;

#Q3) Which city has the largest tax percent/VAT (Value added tax)?
-- we want city which has largest tax percent or VAT  we can simply use average
select city, avg(VAT) as avg_VAT from sales group by city order by avg_VAT desc;

#Q4) Which customer type pays the most VAT
-- average VAT paid by each customer type and selecting the one with the highest average VAT 
select customer_type, avg(VAT) as total_avg_tax from sales group by customer_type order by total_avg_tax desc limit 1;


-- -------------------------------------------------------------------------------------
# customer Questions--------------------------------------------------------------------
-- -------------------------------------------------------------------------------------

#Q1) How many unique customer type does the data have?
select distinct customer_type from sales;

#Q2) How many unique payment methods does the data have?
select distinct payment_method from sales;

#Q3) what is the most common customer type?
select customer_type, count(customer_type) as total_cust from sales group by customer_type order by total_cust desc limit 1;

#Q4) which customer type buys the most?
select customer_type,count(*) as count from sales group by customer_type;

#Q5) what is the gender of most of the customers?
select gender, count(*) as count from sales group by gender order by count desc limit 1;

#Q6) what is the gender distribution per branch?
select gender, branch, count(*) as count from sales group by branch, gender order by branch;

#Q7) which time of the day do customers give most ratings?
-- here not asked the highest ratings here asked most ratings means we need to count
select time_of_day, count(rating) as no_of_ratings from sales group by time_of_day order by no_of_ratings desc;

#Q8) Which time of the day do customers give most ratings per branch?
select branch,time_of_day, count(rating) as no_of_ratings from sales group by time_of_day,branch order by no_of_ratings desc;

#Q9) Which day fo the week has the best avg ratings?
select day_name, avg(rating) as avg_rating from sales group by day_name order by avg_rating desc limit 1;

#Q10) Which day of the week has the best average ratings per branch?
select branch, day_name,avg(rating) as avg_rating from sales group by branch,day_name order by avg_rating desc;

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------

