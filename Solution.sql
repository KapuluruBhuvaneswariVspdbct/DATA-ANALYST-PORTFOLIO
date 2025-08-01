use amazon_db;
select * from amazon_sales;

/*
 Problem 1: Top Performing Categories
 Which product categories generate the most sales and revenue?
 Purpose: Identify the most profitable product lines and where to invest more.
*/
SELECT category, SUM(`Total Sales`) AS total_sales
FROM amazon_sales
GROUP BY category
ORDER BY total_sales DESC
limit 3;





/*
 Problem 2: Regional Sales Performance
 Which customer locations (cities) bring the highest and lowest revenue?
 Purpose: Find potential markets for expansion or strategic focus.
*/
SELECT (`Customer Location`) , sum(`Total Sales`) as t from amazon_sales
group by (`Customer Location`)
order by t desc;


/*
Problem 4: Bestselling Products
 What are the most popular and highest-selling products?
 Purpose: Support stock planning and identify candidates for promotions
*/
SELECT (`Product`) , sum(`Total Sales`) as t from amazon_sales
group by (`Product`)
order by t desc;


/*
 Problem 5: Payment Method Analysis
 What payment methods are most used, and how do they relate to order status?
 Purpose: Understand customer preferences and risk factors
*/
select (`Payment Method`),Count(`Payment Method`) as c
from amazon_sales
group by (`Payment Method`)
order by c desc;


/*
 Problem 6: Order Status Breakdown
 How many orders are completed, pending, or cancelled? What revenue is lost due to cancellations?
 Purpose: Improve fulfillment and reduce losses
*/

select status , count(`status`) as c
from amazon_sales
group by status
order by c desc ;


/*
 Problem 7: Top Customers
 Who are the top customers in terms of purchase volume and spending?
 Purpose: Build customer loyalty and personalized marketing strategies.
*/

SELECT `Customer Name`, SUM(`Total Sales`) AS total_sales
FROM amazon_sales
GROUP BY `Customer Name`
ORDER BY total_sales DESC;

