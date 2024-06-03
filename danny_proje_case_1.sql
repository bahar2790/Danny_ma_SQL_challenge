
-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as total_amount
from dannys_diner.sales as s
join dannys_diner.menu as m on s.product_id = m.product_id
group by customer_id 
order by 2 desc;



-- 2. How many days has each customer visited the restaurant?
select customer_id, count( distinct order_date) as total_visit
from dannys_diner.sales
group by 1;

-- 3. What was the first item from the menu purchased by each customer?

select s.customer_id, min (s.order_date) as customer_first_date,
m.product_name as customer_first_food
from dannys_diner.sales as s
join dannys_diner.menu as m on s.product_id =m.product_id 
group by 1,3
order by 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name ,count(*) as purchase_count
from dannys_diner.menu as m
join dannys_diner.sales as s on m.product_id = s.product_id
group by product_name
having count(*) = (select max(purchase_count) from(select count(*) as purchase_count from dannys_diner.sales group by product_id)as count)
order by purchase_count;

-- 5. Which item was the most popular for each customer?  
WITH ranked_sales AS (
    SELECT 
        customer_id,
        product_name,
        COUNT(product_name) AS order_count,
        RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS rn
    FROM dannys_diner.sales AS s
    JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
    GROUP BY customer_id, product_name
)
SELECT 
    customer_id,
    order_count,
    product_name
FROM ranked_sales
WHERE rn = 1
ORDER BY customer_id;

-- 6. Which item was purchased first by the customer after they became a member?
select s.customer_id,min(s.order_date)product_name
from dannys_diner.sales as s
join dannys_diner.menu as m on s.product_id = m.product_id
join dannys_diner.members as me on s.customer_id = me.customer_id

where order_date >= join_date
group by 1;

-- 7. Which item was purchased just before the customer became a member?
with siralama as(select 
s.customer_id,
product_name,
order_date,
rank() over(partition by s.customer_id order by order_date desc) as row_number
from dannys_diner.sales as s
join dannys_diner.menu on menu.product_id=s.product_id
join dannys_diner.members as m on m.customer_id=s.customer_id
where order_date < join_date)
select
customer_id,
product_name,
order_date
from siralama where row_number =1

-- 8. What is the total items and amount spent for each member before they became a member?

select customer_id , sum (price),count(s.product_id)
from dannys_diner.sales as s
join dannys_diner.menu as m on s.product_id = m.product_id
group by 1
order by 1;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?with toplam as(select customer_id,
select price,
product_name,
case 
when product_name= 'sushi' then price*20
else price*10 end as puan
from dannys_diner.sales as s
join dannys_diner.menu as m on s.product_id=m.product_id
order by 1


 


-- 10. 

SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN order_date <= join_date + INTERVAL '1 week' THEN price * 20  -- İlk hafta 2x puan
            ELSE price * 10  -- Normal puanlar
        END
    ) AS total_points
FROM dannys_diner.sales as s
join dannys_diner.members as me on s.customer_id=me.customer_id
join dannys_diner.menu as m on s.product_id = m.product_id
    
WHERE
    EXTRACT(MONTH FROM order_date) = 1  -- Ocak ayında yapılan alımlar
GROUP BY
    s.customer_id;






