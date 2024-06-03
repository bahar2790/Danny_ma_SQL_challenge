# Danny's Diner SQL Analysis

Welcome to the SQL analysis project for Danny's Diner! This repository contains a series of SQL queries designed to extract meaningful insights from the restaurant's sales, menu, and membership data. Each query addresses a specific business question to help understand customer behavior, sales trends, and product popularity.

## SQL Queries

### 1. Total Amount Spent by Each Customer
This query calculates the total amount each customer has spent at the restaurant.

SELECT customer_id, SUM(price) AS total_amount
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY customer_id 
ORDER BY 2 DESC;
2. Number of Visits by Each Customer
This query counts the number of days each customer visited the restaurant.


SELECT customer_id, COUNT(DISTINCT order_date) AS total_visit
FROM dannys_diner.sales
GROUP BY 1;
3. First Item Purchased by Each Customer
This query identifies the first item each customer purchased from the menu.


SELECT s.customer_id, MIN(s.order_date) AS customer_first_date,
m.product_name AS customer_first_food
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id 
GROUP BY 1, 3
ORDER BY 1;
4. Most Purchased Item on the Menu
This query finds the most purchased item on the menu and the number of times it was purchased.


SELECT m.product_name, COUNT(*) AS purchase_count
FROM dannys_diner.menu AS m
JOIN dannys_diner.sales AS s ON m.product_id = s.product_id
GROUP BY product_name
HAVING COUNT(*) = (
    SELECT MAX(purchase_count) 
    FROM (
        SELECT COUNT(*) AS purchase_count 
        FROM dannys_diner.sales 
        GROUP BY product_id
    ) AS count
)
ORDER BY purchase_count;
5. Most Popular Item for Each Customer
This query determines the most popular item for each customer.


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
6. First Item Purchased After Becoming a Member
This query identifies the first item purchased by the customer after they became a member.


SELECT s.customer_id, MIN(s.order_date) AS product_name
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
JOIN dannys_diner.members AS me ON s.customer_id = me.customer_id
WHERE order_date >= join_date
GROUP BY 1;
7. Item Purchased Just Before Becoming a Member
This query finds the item purchased just before the customer became a member.


WITH siralama AS (
    SELECT 
        s.customer_id,
        product_name,
        order_date,
        RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS row_number
    FROM dannys_diner.sales AS s
    JOIN dannys_diner.menu ON menu.product_id = s.product_id
    JOIN dannys_diner.members AS m ON m.customer_id = s.customer_id
    WHERE order_date < join_date
)
SELECT
    customer_id,
    product_name,
    order_date
FROM siralama 
WHERE row_number = 1;
8. Total Items and Amount Spent Before Membership
This query calculates the total items and amount spent for each member before they became a member.


SELECT customer_id, SUM(price), COUNT(s.product_id)
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 1;
9. Points Calculation Based on Spending
This query calculates the total points each customer would have, considering that each $1 spent equates to 10 points, and sushi has a 2x points multiplier.


WITH toplam AS (
    SELECT 
        customer_id,
        price,
        product_name,
        CASE 
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10 
        END AS puan
    FROM dannys_diner.sales AS s
    JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
)
SELECT 
    customer_id, 
    SUM(puan) AS total_points
FROM toplam
GROUP BY customer_id
ORDER BY customer_id;
10. Points Calculation for January
This query calculates the points earned by each customer in January, with a 2x points multiplier for purchases made in the first week of their membership.


SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN order_date <= join_date + INTERVAL '1 week' THEN price * 20
            ELSE price * 10
        END
    ) AS total_points
FROM dannys_diner.sales AS s
JOIN dannys_diner.members AS me ON s.customer_id = me.customer_id
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
WHERE EXTRACT(MONTH FROM order_date) = 1
GROUP BY s.customer_id;
How to Use

Clone this repository to your local machine.

git clone https://github.com/bahar2790/danny_ma_SQL_challange.git
Open your SQL client and connect to your database.
Load the provided SQL scripts into your database environment.
Execute the queries to gain insights from Danny's Diner data.
Contributing

Feel free to fork this repository and submit pull requests for any improvements or additional analyses. Your contributions are welcome!

