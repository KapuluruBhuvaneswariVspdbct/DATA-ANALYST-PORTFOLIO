/*
 Provide the list of markets in which customer  "Atliq  Exclusive"  operates its 
business in the  APAC  region.
*/
USE gbd023;
SELECT * FROM dim_customer;
SELECT * FROM dim_product;
SELECT * FROM fact_gross_price;
SELECT * FROM fact_pre_invoice_deductions;
SELECT * FROM fact_sales_monthly;
select * from  fact_manufacturing_cost;
SELECT market FROM dim_customer
WHERE region = 'APAC' and customer='Atliq Exclusive';

/*
.  What is the percentage of unique product increase in 2021 vs. 2020? The 
final output contains these fields, 
unique_products_2020 
unique_products_2021 
percentage_chg 
*/
select unique_products_2020 ,unique_products_2021,((unique_products_2021-unique_products_2020)*100)/(unique_products_2020) from
(select count(case when fiscal_year=2020 then fiscal_year end) as unique_products_2020 ,count(case when fiscal_year=2021 then fiscal_year end) as unique_products_2021 from fact_gross_price)as a;

/*
  Provide a report with all the unique product counts for each  segment  and 
sort them in descending order of product counts. The final output contains 
2 fields, 
segment 
product_count
*/
SELECT SEGMENT, COUNT(*) AS PRODUCT_COUNT FROM DIM_PRODUCT
GROUP BY SEGMENT
ORDER BY PRODUCT_COUNT DESC;

/*
  Follow-up: Which segment had the most increase in unique products in 
2021 vs 2020? The final output contains these fields, 
segment 
product_count_2020 
product_count_2021 
difference
*/
select segment , count(case when fiscal_year=2020 then fiscal_year end),count(case when fiscal_year=2021 then fiscal_year end)
from dim_product d
join (select product_code,fiscal_year from  fact_gross_price) as f
on d.product_code=f.product_code
group by segment;

/*
SELECT f.segment,first as product_count_2020  , second as product_count_2021 ,second-first as difference FROM 
	(SELECT segment,count(*) as first from (
				SELECT * FROM DIM_PRODUCT
				LEFT JOIN fact_gross_price
				USING (PRODUCT_CODE) 
		)AS FIRST 
		WHERE FIRST.FISCAL_YEAR=2020
		GROUP BY SEGMENT) as f

join
	(SELECT segment ,count(*)as second FROM (
			SELECT * FROM DIM_PRODUCT
			LEFT JOIN fact_gross_price
			USING (PRODUCT_CODE) 
	)AS FIRST 
	WHERE FIRST.FISCAL_YEAR=2021
	GROUP BY SEGMENT) as j
on f.segment=j.segment; 
                         */               
                                        
/*
 Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields, 
product_code 
product 
manufacturing_cost
*/


select D.PRODUCT_CODE,PRODUCT ,MANUFACTURING_COST  FROM (
SELECT * FROM fact_manufacturing_cost
WHERE MANUFACTURING_COST =(SELECT MIN(manufacturing_cost)FROM fact_manufacturing_cost) OR  MANUFACTURING_COST = (SELECT MAX(manufacturing_cost)FROM fact_manufacturing_cost )) AS F
JOIN dim_product AS D 
ON D.PRODUCT_CODE = F.PRODUCT_CODE;

select product_code,product,manufacturing_cost from ( select * from fact_manufacturing_cost as f
join dim_product 
using(product_code))as a
where manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost) or  manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost) ;


/*  Generate a report which contains the top 5 customers who received an 
average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
Indian  market. The final output contains these fields, 
customer_code 
customer 
average_discount_percentage */
select f.customer_code , customer , f.average_discount_percentage from 
(select customer_code , avg(case when fiscal_year=2021 then pre_invoice_discount_pct  end) as average_discount_percentage from fact_pre_invoice_deductions group by customer_code) as f
join dim_customer as d
using(customer_code)
where market="india"
order by f.average_discount_percentage limit 5;

/*
 Get the complete report of the Gross sales amount for the customer  “Atliq 
Exclusive”  for each month  .  This analysis helps to  get an idea of low and 
high-performing months and take strategic decisions. 
The final report contains these columns: 
Month 
Year 
Gross sales Amount
*/


select month(date) ,fiscal_year, sum(sold_quantity*gross_price) as gross_sales from (select product_code,fiscal_year,gross_price,date,customer_code,sold_quantity from fact_sales_monthly join fact_gross_price using(fiscal_year,product_code)) as m 
where customer_code in (select customer_code from dim_customer where customer='atliq exclusive') group by fiscal_year,month(date) order by fiscal_year , gross_sales desc
;

/*
8.  In which quarter of 2020, got the maximum total_sold_quantity? The final 
output contains these fields sorted by the total_sold_quantity, 
Quarter 
total_sold_quantity
*/
select 'q1' as quarter ,sum(sold_quantity) as total_sold_quantity from fact_sales_monthly where month(date) in (1,2,3)
union all
select 'q2' ,sum(sold_quantity) from fact_sales_monthly where month(date) in (5,4,6)
union all
select 'q3'  ,sum(sold_quantity)  from fact_sales_monthly where month(date) in (7,8,9)
union all
select 'q4 ',sum(sold_quantity) from fact_sales_monthly where month(date) in (10,11,12)
;

/*
 Which channel helped to bring more gross sales in the fiscal year 2021 
and the percentage of contribution?  The final output  contains these fields, 
channel 
gross_sales_mln 
percentage
*/
select channel , gross_sales_mln , round(gross_sales_mln*100/sum(gross_sales_mln) over(),2) as percentage from(
select channel , sum(gross_sales ) as gross_sales_mln from 
(select customer_code , sum(sold_quantity *gross_price) as  gross_sales from fact_sales_monthly join fact_gross_price  using(product_code) where  fact_gross_price .fiscal_year=2021 group by customer_code) as m
join dim_customer using(customer_code) group by channel) as a;


/*
10.  Get the Top 3 products in each division that have a high 
total_sold_quantity in the fiscal_year 2021? The final output contains these 
fields, 
division 
product_code 
product 
total_sold_quantity 
rank_order 
*/select * from (
select division ,product_code,product,sum(sold_quantity) ,rank() over(partition by division order by sum(sold_quantity) desc) as ranke from dim_product join fact_sales_monthly using(product_code)  group by product,product_code,division  )as a where ranke<=3 ;
