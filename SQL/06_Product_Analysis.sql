USE grocery_delivery_db;

select * from customers;
select * from stores;
select * from products;
select * from orders;
select * from order_items;

-- 1.Which products have the highest number of orders?

select top 1
	p.product_name,count(order_id) as highest_order from products p
	join order_items o on p.product_id = o.product_id 
	group by p.product_name order by highest_order desc;

-- 2.Which products have the highest number of unique customers?

select top 1
	p.product_name ,count(distinct(c.customer_id)) as highest_unique_customers
	from products p join order_items o on p.product_id=o.product_id 
	join orders i on o.order_id=i.order_id
	join customers c on c.customer_id=i.customer_id
	group by p.product_name order by highest_unique_customers desc;

-- 3.What is the average quantity sold per order for each product?

select p.product_name,avg(o.quantity) as avg_quantity_sold 
from products p join order_items o on p.product_id=o.product_id
group by p.product_name;

-- 4.Which products have the highest average selling price?

select top 1 
	p.product_name,avg(p.price) as highest_avg_price
	from products p group by p.product_name 
	order by highest_avg_price desc;

-- 5.Which products have never been ordered?

select p.product_name from products p left join order_items o
on p.product_id=o.product_id where o.product_id is null;


-- 6.Which category has the highest number of different products sold?

select top 1
	p.category,count(distinct o.product_id) as highest_product_sold
	from products p join order_items o on p.product_id=o.product_id 
	group by p.category order by highest_product_sold desc;

-- 7.Which product has the highest sales growth between two months?

with cte as(
	select o.product_id, year(order_date) as sales_year,
	month(order_date) as sales_month,
	sum(quantity * unit_price) as total_sales
	from order_items o join orders oi on o.order_id=oi.order_id
	group by o.product_id,year(oi.order_date),month(oi.order_date)
	)
	select top 1
		p.product_name,m1.total_sales as prev_month_sales,
		m2.total_sales as current_month_sales, 
		(m2.total_sales - m1.total_sales) as sales_growth 
		from cte m1 join cte m2 on m1.product_id=m2.product_id
		and ( m1.sales_year=m2.sales_year
		and m1.sales_month=m2.sales_month+1)
		join products p on p.product_id=m1.product_id
		 order by sales_growth desc;

-- 8.Which products are frequently purchased together?

select p1.product_name as product_1,
	   p2.product_name as product_2,
	   count(*) as frequently_purchased
	   from order_items oi1 join order_items oi2
	   on oi1.order_id=oi2.order_id
	   and oi1.product_id<oi2.product_id
	   join products p1 on p1.product_id=oi1.product_id
	   join products p2 on p2.product_id=oi2.product_id
	group by p1.product_name,p2.product_name
	order by frequently_purchased desc;

-- 9.Which products have high quantity sold but low revenue?

select p.product_name,
	sum(quantity) as total_quantity,
	sum(quantity * unit_price) as total_revenue
	from order_items oi join products p on oi.product_id=p.product_id
	group by p.product_name order by total_quantity desc, total_revenue asc;

-- 10.Which products contribute the highest percentage of total sales?

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS product_sales,
    SUM(oi.quantity * oi.unit_price) * 100.0 /
    (SELECT SUM(quantity * unit_price)
     FROM order_items) AS sales_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY sales_percentage DESC;