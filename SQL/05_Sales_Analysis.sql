USE grocery_delivery_db;

select * from customers;
select * from stores;
select * from products;
select * from orders;
select * from order_items;

-- 1.What is the total sales revenue?

select sum(quantity * unit_price) as total_sales_revenue from order_items;

-- 2.What is the average sales value per order?

select avg(sales_value) as avg_sales_value
from (
select order_id,sum(quantity * unit_price) as sales_value from order_items
group by order_id
) as total_sales;

-- 3.What is the total quantity of products sold?

select sum(quantity) as total_quantity from order_items ;

-- 4.Which product generated the highest sales revenue?

select TOP 1 
	o.product_id,p.product_name ,sum(quantity * unit_price) as total_revenue 
	from order_items o join products p on o.product_id=p.product_id
	group by o.product_id,p.product_name
	order by total_revenue desc;

-- 5.Which product had the highest quantity sold?

select top 1 
	o.product_id,p.product_name, sum(quantity) as higest_quantity_sold
	from products p join order_items o on p.product_id=o.product_id 
	group by o.product_id,p.product_name 
	order by higest_quantity_sold desc;

-- 6.Which category generated the highest sales revenue?

select top 1 
	p.category, sum(quantity * unit_price) as highest_category_sales 
	from products p join order_items o on p.product_id=o.product_id 
	group by p.category 
	order by highest_category_sales desc;

-- 7.Which store generated the highest sales revenue?

select  top 1 
	s.store_name ,sum(quantity * unit_price) as highest_store_sales
	from stores s join orders o on s.store_id=o.store_id join order_items i
	on o.order_id=i.order_id group by s.store_name 
	order by highest_store_sales desc;

-- 8.Which city generated the highest sales revenue?

select top 1
	c.city, sum(quantity * unit_price) as highest_sales_city from customers c
	join orders i on c.customer_id=i.customer_id join order_items o 
	on i.order_id=o.order_id group by c.city order by highest_sales_city desc;

-- 9.Which month generated the highest sales revenue?

select top 1
	month(o.order_date) as month_,
	sum(quantity * unit_price) as highest_sales 
	from orders o join order_items i on
	o.order_id=i.order_id group by MONTH(o.order_date)
	order by highest_sales desc;


-- 10.Who are the top 5 customers by total sales?

select top 5
		c.customer_name,sum(quantity * unit_price) as total_sales
		from customers c join orders o on c.customer_id=o.customer_id
		join order_items i on o.order_id=i.order_id
		group by c.customer_name order by total_sales desc;

