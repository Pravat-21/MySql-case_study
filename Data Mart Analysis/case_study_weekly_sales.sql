use case1;
show tables;
select * from weekly_sales limit 10;
## DATA CLEANSING OPARATION :
create table  clean_weekly_sales as 
select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calendar_year,
region,platform,
case
	when segment=null then 'unknown'
    else segment
    end as segment,
case
	when right(segment,1)='1' then 'Young Adults'
    when right(segment,1)='2' then 'Middle Aged'
    when right(segment,1) in ('3','4') then 'Retirees'
    else 'unknown'
    end as age_band,
case
	when left(segment,1)='C' then 'Couples'
    when left(segment,1)='F' then 'Families'
    else 'unkown'
    end as demographic,
customer_type,transactions,sales,
round(sales/transactions,2) as  avg_transaction
from weekly_sales;

select * from clean_weekly_sales limit 10;
#_____________________________________________________________________________

# DATA EXPLORATION
# 1. Which week numbers are missing from the dataset?

create table seq100 
(
	x int auto_increment,
    constraint pk primary key(x)
);
insert into seq100 values
(),(),(),(),(),(),(),(),(),(),(),(),(),
(),(),(),(),(),(),(),(),(),(),(),(),(),
(),(),(),(),(),(),(),(),(),(),(),(),(),
(),(),(),(),(),(),(),(),(),(),(),(),();
select * from seq100;
insert into seq100 select x+50 from seq100;
delete from seq100 where x>50;
select * from seq100;

create table seq52 as (select x from seq100 limit 52);
select * from seq52;

select x as missing_week_no from seq52 where x not in (select week_number from clean_weekly_sales);

select distinct week_number from clean_weekly_sales;

#______________________________________________________________________________________

# 2. How many total transactions were there for each year in the dataset?
select * from clean_weekly_sales limit 5;
select calendar_year,sum(transactions) as total_trans_per_year from clean_weekly_sales group by calendar_year;
#________________________________________________________________________________________

# 3. What are the total sales for each region for each month?
select region,month_number,sum(sales) as total_sales from clean_weekly_sales group by region,month_number;
#_________________________________________________________________________________________

# 4. What is the total count of transactions for each platform?
select platform,sum(transactions) as total_count_trans from clean_weekly_sales group by platform;
#__________________________________________________________________________________________

#5. What is the percentage of sales for Retail vs Shopify for each month?
WITH cte_monthly_platform_sales AS (
  SELECT
    month_number,calendar_year,
    platform,
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY month_number,calendar_year, platform
)
select month_number,calendar_year,
round((max(case when platform='Retail' then monthly_sales
	else null end)/sum(monthly_sales)*100),2) as retail_percentage,
round((max(case when platform='Shopify' then monthly_sales
	else null end)/sum(monthly_sales)*100),2) as shopify_percentage
from cte_monthly_platform_sales group by month_number,calendar_year;
#______________________________________________________________________
#6. What is the percentage of sales by demographic for each year in the dataset?
select * from clean_weekly_sales limit 5;
select calendar_year,demographic,
       sum(sales) as yearly_sum,
       round(100*sum(sales)/sum(sum(sales)) over (partition by demographic),2) as percentage_value 
from clean_weekly_sales
group by calendar_year,demographic;
#_________________________________________________________________________
# 7. Which age_band and demographic values contribute the most to Retail sales?
select age_band,demographic,
	   sum(sales) as total_sales
from clean_weekly_sales where platform='Retail'
group by age_band , demographic
order by sum(sales) desc;

#________________________________The end_____________________________________

       




    




    
    
