USE grocery_delivery_db;

-- 1.What is the total number of orders?

select count(*) as total_counts from orders;

-- 2.What is the total number of delivered orders?

select count(*) as orders_delivered
from orders where order_status='Delivered';

-- 3.What is the total number of cancelled orders?

select count(*) as orders_cancelled
from orders where order_status='cancelled';

-- 4.What is the order cancellation rate?

select count(*) as total_orders,
sum(case when order_status='cancelled' then 1 else 0 end) as cancelled_orders,
round( sum(case when order_status='cancelled' then 1 else 0 end) * 100/count(*),2)
as cancelled_rate from orders;

-- 5.What is the average order value?

select avg(order_value) as avg_order_value 
from (
	select order_id ,sum(quantity * unit_price) as order_value from order_items
	group by order_id
	) as total_orders;


-- 6.What is the total revenue generated?

select sum(quantity * unit_price) as total_revenue from order_items;

-- 7.What is the average number of items per order?

select avg(total_orders) as avg_orders_per_order 
from(
	select order_id, sum(quantity) as total_orders from order_items
	group by order_id
	) as toral_orders_per_order;

-- 8.What is the maximum order value?

select max(order_value) as max_order_value 
from (
	select order_id,sum(quantity * unit_price) as order_value from order_items
	group by order_id
	) as total_order_value;

-- 9.What is the minimum order value?

select min(order_value) as min_order_value 
from (
	select order_id,sum(quantity * unit_price) as order_value from order_items
	group by order_id
	) as total_order_value;


-- 10.What percentage of orders were successfully delivered?

select count(*) as total_orders,
sum(case when order_status='delivered' then 1 else 0 end) as orders_deliverd,
round( sum(case when order_status='delivered' then 1 else 0 end) * 100/count(*),2)
as deliverd_rate from orders;
