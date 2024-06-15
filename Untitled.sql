-- 1. Get number of monthly active customers.

select date_format(rental_date, '%Y-%m') as month,
       count(distinct customer_id)
from sakila.rental
group by month 
order by month;



SELECT
    YEAR(rental_date) AS rental_year,
    MONTH(rental_date) AS rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM
    sakila.rental
GROUP BY
    rental_year, rental_month;
    
    
    
-- 2. Active users in the previous month.

with cte_rental as(
                select date_format (rental_date, '%m') as activity_month,
                       date_format (rental_date, '%Y') as  activity_year,
                       customer_id
				from sakila.rental),
	cte_active_users as(
                        select activity_month,activity_year, count(distinct customer_id) as active_users
                        from cte_rental
                        group by activity_month,activity_year)
                        
select activity_month, activity_year, active_users, lag(active_users) over(order by activity_month, activity_year) as last_month
from cte_active_users;


-- 3. Percentage change in the number of active customers.
			
    with cte_rental as(
                select date_format (rental_date, '%m') as activity_month,
                       date_format (rental_date, '%Y') as  activity_year,
                       customer_id
				from sakila.rental),
	cte_active_users as(
                        select activity_month,activity_year, count(distinct customer_id) as active_users
                        from cte_rental
                        group by activity_month,activity_year),
     cte_active_users_prev as(
                               select activity_month,activity_year, active_users,
                                lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
	                             from cte_active_users)

 
 select *,
        (Active_users - Last_month) as Difference,
	    concat(round((Active_users - Last_month)/last_month*10), '%') as Percent_Differene

from cte_active_users_prev;




-- 4. Retained customers every month.

with cte_rental as(
                select date_format (rental_date, '%m') as Activity_month,
                       date_format (rental_date, '%Y') as  Activity_year,
                       customer_id
				from sakila.rental),
 recurrent_rental as (
	select distinct 
		customer_id as Active_id, 
		Activity_year, 
		Activity_month
	from cte_rental
), recurrent_months as (
	select Active_id, Activity_year, Activity_month,
		lag(Activity_year) over (partition by Active_id order by Activity_year, Activity_month) Previous_year,
		lag(Activity_month) over (partition by Active_id order by Activity_year, Activity_month) Previous_month
	from recurrent_rental
), recurrent_months_diff as (
	select Active_id, Activity_year, Activity_month, Previous_year, Previous_month,
		   Activity_year-Previous_year as diff_years, Activity_month-Previous_month as diff_months
	from recurrent_months
	where Activity_month-Previous_month in (1, -11)
)
select Activity_year, Activity_month, count(distinct Active_id)
from recurrent_months_diff
group by Activity_year, Activity_month
;
        
                               
                               
                
                
                       





