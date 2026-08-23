USE grocery_delivery_db;

select * from customers;
select * from stores;
select * from products;
select * from orders;
select * from order_items;


-- 1.Find the total number of customers.

select count(1) as total_customers from customers;

-- 2.Find the total number of orders placed by each customer.

select c.customer_name,count(o.order_id) as total_orders
from customers c join orders o on c.customer_id=o.customer_id
group by c.customer_name;

-- 3.Find the total amount spent by each customer.

select c.customer_name, sum(quantity * unit_price) as total_amount
from customers c join orders o on c.customer_id=o.customer_id
join order_items oi on o.order_id=oi.order_id
group by c.customer_name;

-- 4.Find the average order value for each customer.

SELECT 
    c.customer_id,
    c.customer_name,
    AVG(order_total) AS avg_order_value
FROM customers c
JOIN (
    SELECT 
        o.order_id,
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) x
    ON c.customer_id = x.customer_id
GROUP BY c.customer_id, c.customer_name;


-- 5.Find the highest order value for each customer.

SELECT 
    c.customer_id,
    c.customer_name,
    MAX(order_total) AS highest_order_value
FROM customers c
JOIN (
    SELECT 
        o.order_id,
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) x
    ON c.customer_id = x.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 6.Find the latest order date for each customer.

select 
c.customer_name,max(o.order_date) as latest_order
from customers c join orders o on c.customer_id=o.customer_id
group by c.customer_name;

-- 7.Find customers who have placed more than 5 orders.

select c.customer_name, count(o.order_id) as orders_count
from customers c join orders o on c.customer_id=o.customer_id
join order_items oi on o.order_id=oi.order_id
group by c.customer_name having count(o.order_id)>5;

-- 8.Find customers whose total spending is greater than ?50,000.

select c.customer_name,sum(quantity * unit_price) as total_amount
from customers c join orders o on c.customer_id=o.customer_id
join order_items oi on o.order_id=oi.order_id
group by c.customer_name having sum(quantity * unit_price) > 50000;

-- 9.Find the top 5 customers based on total spending.

select top 5
c.customer_name,sum(quantity * unit_price) as total_amount
from customers c join orders o on c.customer_id=o.customer_id
join order_items oi on o.order_id=oi.order_id
group by c.customer_name order by total_amount desc;

-- 10.Rank customers based on their total spending.

with cte as(
select c.customer_name, sum(quantity *unit_price) as total_amount
from customers c join orders o on c.customer_id=o.customer_id
join order_items oi on o.order_id=oi.order_id
group by c.customer_name
)
select customer_name,total_amount,
rank() over(order by total_amount desc)
as Rank_total_amount from cte;
