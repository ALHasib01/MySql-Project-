
-- Provide the list of markets in which customer "Atliq Exclusive" 
-- operates its business in the APAC region.

use gdb023;
select * from gdb023.dim_customer;

select distinct market
from dim_customer
where customer = "Atliq Exclusive" and region = "APAC";

-- What is the percentage of unique product increase 
-- in 2021 vs. 2020? The final output contains these fields, 
-- unique_products_2020 
-- unique_products_2021 
-- percentage_chg

select * from fact_gross_price
limit 5;


with cte1 as (
select count(distinct product_code) as Unique_Products_2021
    from fact_gross_price
    where fiscal_year = "2021"),

cte2 as ( 
select count(distinct product_code) as Unique_Products_2020
    from fact_gross_price
    where fiscal_year = "2020"),

cte3 as (
 select * from cte1
 cross join cte2)
 
 select *, ((Unique_Products_2021 - Unique_Products_2020) / Unique_Products_2020) * 100 AS percentage_chg
           from cte3;
           
           
-- Provide a report with all the unique product counts 
-- for each segment and sort them in descending order of product counts. 
-- The final output contains 2 fields, segment product_count           
 
select * from dim_product
limit 5;
 
 Select segment, count(distinct product_code) as Product_Count 
 from dim_product
 group by segment
 order by Product_count DESC;
 
/**Follow-up: Which segment had the most increase in unique 
products in 2021 vs 2020? The final output contains these fields, 
segment 
product_count_2020 
product_count_2021 
difference
**/

with initial_data as (
    select a.segment, a.product_code, b.fiscal_year
    from dim_product as a 
    join fact_gross_price as b on a.product_code = b.product_code
),
Product_count_2021 as (
     select segment, count(product_code) as product_count_2021
     from initial_data
     where fiscal_year = 2021
     group by segment
),
Product_count_2020 as (
     select segment, count(product_code) as product_count_2020
     from initial_data
     where fiscal_year = 2020
     group by segment
),
final_data as (
     select a.segment, product_count_2021, product_count_2020
     from product_count_2021 as a
     join product_count_2020 as b on a.segment = b.segment
)
select *, (product_count_2021 - product_count_2020) as Diffrence
from final_data
order by diffrence desc;

/**Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields, 
product_code 
product 
manufacturing_cost
**/

with initial_data as (
      select a.Product_code, a.product, b.manufacturing_cost
      from dim_product as a
      join fact_manufacturing_cost as b on a.Product_code = b.Product_code
),
 max_manufac_cost as (
    select product_code, product, manufacturing_cost
    from initial_data
    order by manufacturing_cost desc
    limit 1
),
min_manufac_cost as (
    select product_code, product, manufacturing_cost
    from initial_data
    order by manufacturing_cost 
    limit 1
),
final_data as (
	 select * from max_manufac_cost
     union
     select * from min_manufac_cost)
     
     select * from final_data;
    
/**6. Generate a report which contains the top 5 customers who received 
an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. 
The final output contains these fields, 
customer_code 
customer 
average_discount_percentage
**/

with indian_customer as (
     select customer_code, customer 
     from dim_customer 
     where market = "india"
),
discount_2021 as (
     select customer_code, pre_invoice_discount_pct
     from fact_pre_invoice_deductions
     where fiscal_year = 2021
 ),
 cleaned as (
     select a.customer_code, a.customer, b.pre_invoice_discount_pct
     from indian_customer as a
     join discount_2021 as b on a.customer_code = b.customer_code
),
avg_discount_pct as (
     select customer_code, customer, avg(pre_invoice_discount_pct) as avg_discount_pct
     from cleaned
     group by customer_code, customer 
     order by avg_discount_pct desc
     limit 5
)
select * from avg_discount_pct;     
     
    select * from cleaned;    
    

































