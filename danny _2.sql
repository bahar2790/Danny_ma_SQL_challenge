--Öncelikle daha doğru analizler yapabilmek için verideki boş değerleri null değerlere çeviriyoruz
select * from customer_orders
update customer_orders
set exclusions = case WHEN exclusions = 'null' or exclusions = '' then NULL
		ELSE exclusions end
update customer_orders
set extras = case WHEN extras = 'null' or extras = '' then NULL
		else extras END
		
select * from runner_orders
update runner_orders
set pickup_time = case when
	pickup_time = 'null' then NULL else pickup_time End,
 distance = case when
	distance = 'null' then NULL
	when distance like '%km' then trim(distance, 'km')
	else distance END,
 duration = case when
	duration = 'null' then NULL
	when duration like '%minutes' then trim(duration,'minutes')
	when duration like '%mins' then trim(duration,'mins')
	when duration like '%minute' then trim(duration,'minute')
	else duration end,
 cancellation = case when
	cancellation = 'null' or cancellation = '' then NUll
	else cancellation END;
  
  
  --A PİZZA METRİCS

--How many pizzas were ordered?
select count(order_id) from customer_orders;

--How many unique customer orders were made?
select count(distinct customer_id) as unique_customer_orders from customer_orders;

--How many successful orders were delivered by each runner?
select count(order_id),runner_id from runner_orders
where cancellation is null 
group by 2
order by 2
--How many of each type of pizza was delivered?

select count(co.pizza_id)as pizza_count,
co.pizza_id
from runner_orders as ro
join customer_orders as co on ro.order_id=co.order_id
join pizza_names as pn on co.pizza_id=pn.pizza_id
where cancellation is NULL
group by 2
order by 2




--How many Vegetarian and Meatlovers were ordered by each customer?

select count(pizza_name), pizza_name,customer_id
from pizza_names as pn
join customer_orders as co on pn.pizza_id = co.pizza_id
group by 2,3
order by 2;

--What was the maximum number of pizzas delivered in a single order?
select  count (pizza_id),co.order_id
from customer_orders as co
join runner_orders as ro on co.order_id = ro.order_id
where cancellation is null
group by 2
order by 2 desc;

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    co.customer_id,
    SUM(CASE WHEN co.exclusions IS NOT NULL AND ro.cancellation IS NULL THEN 1 ELSE 0 END) AS change_pizza_count,
    SUM(CASE WHEN co.exclusions IS NULL AND ro.cancellation IS NULL THEN 1 ELSE 0 END) AS no_change_pizza_count
FROM 
    customer_orders AS co
JOIN 
    runner_orders AS ro ON co.order_id = ro.order_id
GROUP BY 
    co.customer_id;


--How many pizzas were delivered that had both exclusions and extras?
select count(extras) as count_extras,
      count(exclusions) as count_exclusions
	  from customer_orders as co
	   join runner_orders as ro on co.order_id = ro.order_id
	   where cancellation is not null;
	   
	  
--What was the total volume of pizzas ordered for each hour of the day?

select to_char(order_time, 'HH24'),
		count(order_id)
from customer_orders co
group by 1
order by 1
--What was the volume of orders for each day of the week?
select count(order_id) as order_count,
to_char(order_time, 'DD') as day
from customer_orders
group by 2
order by 2



                   --B. Runner and Customer Experience



--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT to_char(registration_date, 'w') AS week_start, COUNT(*) AS runners_count,
registration_date
FROM runners
GROUP BY to_char(registration_date, 'w'),3
ORDER BY week_start;

--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT avg(pickup_time-order_time) as avg_time, runner_id
FROM runner_orders as ro
join customer_orders as co on co.order_id=ro.order_id
where pickup_time is not null
group by 2
order by 2

--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT 
    COUNT(co.pizza_id) AS pizza_count,
    co.customer_id,
    AVG(ro.pickup_time - co.order_time) AS avg_time,
    ro.runner_id
FROM 
    runner_orders AS ro
JOIN 
    customer_orders AS co ON co.order_id = ro.order_id
WHERE 
    ro.pickup_time IS NOT NULL
GROUP BY 
    co.customer_id, ro.runner_id
ORDER BY 
    co.customer_id;

--4.What was the average distance travelled for each customer?

select round(avg(distance) )as avg_distance,
customer_id
from runner_orders as ro
join customer_orders co on co.order_id = ro.order_id
group by 2;


--5.What was the difference between the longest and shortest delivery times for all orders?
select max(duration)- min (duration) as difference_delivery_time from runner_orders;


--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id,order_id,ROUND(AVG(distance/duration)::numeric,2) as avg_speed
from runner_orders
group by 1,2
order by 1;



