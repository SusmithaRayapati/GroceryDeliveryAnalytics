USE grocery_delivery_db;

select * from customers;
select * from stores;
select * from products;
select * from orders;
select * from order_items;


-- 1.Find the top 3 highest-value orders in each store using ROW_NUMBER().

with cte as(
	select s.store_name,o.order_id,
	sum(quantity * unit_price) as highest_order_value
	from orders o join order_items oi on o.order_id=oi.order_id
	join stores s on o.store_id=s.store_id 
	group by s.store_name,o.order_id
	),
	rank_ as(
		select store_name,order_id,highest_order_value,
		row_number() over(partition by store_name order by highest_order_value desc)
		as order_rank
		from cte
		)
select store_name,order_id, order_rank from rank_ where order_rank <=3;


-- 2.Rank stores based on their total sales, highest sales store should get rank 1.

with cte as(
	select store_name,sum(quantity * unit_price) as total_amount
	from stores s join orders o on s.store_id=o.store_id
	join order_items oi on oi.order_id=o.order_id
	group by store_name
	),
	rank_ as(
		select store_name,total_amount,rank() over(
		order by total_amount desc) as rank_value
		from cte
		)
	select store_name,total_amount, rank_value from rank_ where rank_value=1;


-- 3.Find the top 3 customers based on total order amount using DENSE_RANK().

with cte as(
	select customer_name,sum(quantity * unit_price) as total_amount
	from customers c join orders o on c.customer_id=o.customer_id
	join order_items oi on o.order_id=oi.order_id
	group by customer_name
	),
	den as (
		select customer_name,total_amount,
		DENSE_RANK() over(order by total_amount desc) as den_rank
		from cte)
	select customer_name,total_amount,den_rank from den 
	where den_rank <=3;


-- 4.Find each customers highest-value order using a window function.

with cte as(
	select c.customer_name,o.order_id,
	sum(quantity * unit_price) as total_amount
	from customers c join orders o on c.customer_id=o.customer_id
	join order_items oi on o.order_id=oi.order_id
	group by c.customer_name,o.order_id
	),
	win as(
		select customer_name,order_id,total_amount, dense_rank()
		over(partition by customer_name order by total_amount desc)
		as highest_rank_value from cte )
	select customer_name,order_id, total_amount,highest_rank_value
	from win where highest_rank_value=1;


-- 5.For each customer, show their current order amount and previous order amount.

with cte as(
	select c.customer_name,o.order_id,o.order_date,sum(quantity * unit_price) 
	as current_total_amount from customers c join orders o on 
	c.customer_id=o.customer_id join order_items oi on o.order_id=oi.order_id
	group by c.customer_name,o.order_id,o.order_date
	)
	select customer_name,order_id,order_date,current_total_amount,
	lag(current_total_amount) over(partition by customer_name order by order_date)
	as previous_order_amount from cte;


-- 6.For each customer, show their current order amount and next order amount.

with cte as(
	select c.customer_name,o.order_id,o.order_date,sum(quantity * unit_price) 
	as current_total_amount from customers c join orders o on 
	c.customer_id=o.customer_id join order_items oi on o.order_id=oi.order_id
	group by c.customer_name,o.order_id,o.order_date
	)
	select customer_name,order_id,order_date,current_total_amount,
	lead(current_total_amount) over(partition by customer_name order by order_date)
	as next_order_amount from cte;


--7.Calculate the running total of order amounts ordered by order_date.

with  cte as(
	select o.order_id, order_date,sum(quantity * unit_price) as total_amount
	from order_items oi join orders o on oi.order_id=o.order_id
	group by o.order_id,order_date
	)
	select order_id, order_date,sum(total_amount) over(order by order_date)
	as running_total_amount
	from cte;


-- 8.Using a CTE, find stores whose total sales are greater than the average store sales.

with cte as (
	select store_name,sum(quantity * unit_price) as total_amount
	from stores s join orders o on s.store_id=o.store_id
	join order_items oi on o.order_id=oi.order_id
	group by store_name
	)
	select store_name, total_amount from cte 
	where total_amount >( 
		select avg(total_amount) as avg_sales
		from cte
		);


-- 9.Find the highest-value order for each store using a subquery/window function.

with cte as(
		select store_name, sum(quantity * unit_price) as total_amount
		from stores s join orders o on s.store_id=o.store_id
		join  order_items oi on o.order_id=oi.order_id
		group by store_name
		),
rank_ as (		
	select store_name, total_amount,dense_rank() over(
	partition by store_name order by total_amount desc) 
	as highest_rank_order_value from cte
	)
	select store_name,total_amount,highest_rank_order_value from
	 rank_ where highest_rank_order_value=1;


-- 10.Find the top 3 stores based on total sales, and display:

with cte as(
	select store_name,sum(quantity * unit_price) as total_sales
	from stores s join orders o on s.store_id=o.store_id
	join order_items oi on o.order_id=oi.order_id
	group by store_name
	),
	rank_ as(
	select store_name, total_sales , DENSE_RANK() 
	over(order by total_sales desc) as highest_ranks
	from cte
	)
	select store_name, total_sales, highest_ranks from rank_
	where highest_ranks <=3;
