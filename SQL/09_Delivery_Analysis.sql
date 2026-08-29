USE grocery_delivery_db;

select * from customers;
select * from stores;
select * from products;
select * from orders;
select * from order_items;

-- 1.Find the average delivery time across all orders.

select avg(delivery_time_minutes) as avg_delivery_time from orders;

-- 2.Find the average delivery time for each store.

select s.store_name,avg(o.delivery_time_minutes) as avg_delivery_time
from stores s join orders o on s.store_id=o.store_id
group by s.store_name;

-- 3.Find the maximum delivery time for each store.

select s.store_name,max(o.delivery_time_minutes) as avg_delivery_time
from stores s join orders o on s.store_id=o.store_id
group by s.store_name;

-- 4.Find the minimum delivery time for each store.

select s.store_name,min(o.delivery_time_minutes) as avg_delivery_time
from stores s join orders o on s.store_id=o.store_id
group by s.store_name;

-- 5.Find stores where the average delivery time is greater than 30 minutes.

select s.store_name,avg(o.delivery_time_minutes) as avg_delivery_time
from stores s join orders o on s.store_id=o.store_id
group by s.store_name having avg(o.delivery_time_minutes) > 30;


-- 6.Find orders where delivery time is greater than 45 minutes.

select order_id,max(delivery_time_minutes) as delivery_time from orders 
group by order_id having max(delivery_time_minutes)>45;

-- 7.Find the top 5 stores with the fastest average delivery time.

select top 5 
	store_name,avg(delivery_time_minutes)  as avg_delivery_time
	from stores s join orders o on s.store_id=o.store_id
	group by store_name order by avg_delivery_time desc ;

-- 8.Find the top 5 stores with the slowest average delivery time.

select top 5 
	store_name,avg(delivery_time_minutes)  as avg_delivery_time
	from stores s join orders o on s.store_id=o.store_id
	group by store_name order by avg_delivery_time ;


-- 9.Classify deliveries as:

	-- Fast ? ? 20 minutes
	-- Normal ? 21–40 minutes
	-- Slow ? > 40 minutes

	SELECT 
    order_id,
    delivery_time_minutes,
    CASE
        WHEN delivery_time_minutes <= 20 THEN 'Fast'
        WHEN delivery_time_minutes BETWEEN 21 AND 40 THEN 'Normal'
        ELSE 'Slow'
    END AS delivery_category
FROM orders;


-- 10.Rank stores based on their average delivery time.

with cte as(
select store_name,avg(delivery_time_minutes) as avg_delivery_time
from stores s join orders o on s.store_id=o.store_id
group by store_name
)
select store_name,avg_delivery_time, rank()
over(order by avg_delivery_time desc) as rank_avg_delivery_time
from cte;
