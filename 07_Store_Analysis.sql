USE grocery_delivery_db;

select * from customers;
select * from stores;
select * from products;
select * from orders;
select * from order_items;


-- 1.Which store has the highest number of orders?

select top 1
	s.store_name,count(o.order_id) as total_orders
	from stores s join orders o on s.store_id=o.store_id
	group by s.store_name order by total_orders desc;


-- 2.Which store generates the highest total revenue?

select top 1 
	s.store_name,sum(oi.quantity * oi.unit_price) as total_revenue
	from stores s join orders o on s.store_id=o.store_id
	join order_items oi on o.order_id=oi.order_id
	group by s.store_name order by total_revenue desc;

	
-- 3.Which store has the highest average order value?

select top 1
	s.store_name,avg(quantity * unit_price) as highest_avg_order_value
	from stores s join orders o on s.store_id=o.store_id
	join order_items oi on o.order_id=oi.order_id 
	group by s.store_name order by highest_avg_order_value desc ;

-- 4.Which store has the highest number of unique customers?

select top 1 
	s.store_name, count(distinct c.customer_id) as highest_unique_customers
	from stores s join orders o on s.store_id=o.store_id 
	join customers c on o.customer_id=c.customer_id 
	group by s.store_name order by highest_unique_customers desc;

-- 5.Which store has the highest average items per order?

select top 1
	s.store_name, avg(o.quantity) as highest_avg_items_per_order
	from stores s join orders oi on s.store_id=oi.store_id
	join order_items o on oi.order_id=o.order_id
	group by s.store_name 
	order by highest_avg_items_per_order desc;

-- 6.Which store has the highest cancellation rate?

select top 1
	s.store_name,
count(case 
		when o.order_status='cancelled' then 1 end) * 100/count(*) as cancellation_rate
from stores s join orders o on s.store_id=o.store_id
group by s.store_name
order by cancellation_rate desc;


-- 7.Which store has the highest revenue contribution percentage?

select top 1
	s.store_name,sum(oi.quantity * p.price) * 100/
	(select sum(oi1.quantity * p1.price)
	from order_items oi1 join products p1
	on oi1.product_id=p1.product_id) as revenue_contribution_percentage
from stores s join orders o on s.store_id=o.store_id
join order_items oi on o.order_id=oi.order_id
join products p on p.product_id=oi.product_id
group by s.store_name
order by revenue_contribution_percentage desc;


-- 8.Which stores perform above the average store revenue?

select s.store_name,sum(quantity * unit_price) as total_revenue
from stores s join orders o on s.store_id=o.store_id
join order_items oi on o.order_id=oi.order_id
group by s.store_name having sum(quantity * unit_price) >
(
select avg(total_revenue) 
from(
		select o1.store_id ,
		sum(quantity * unit_price) as total_revenue
		from orders o1 join order_items oi1 
		on o1.order_id=oi1.order_id
		group by o1.store_id
	) as avg_store_revenue
);


-- 9.Which store has the highest revenue per customer?

select top 1
	s.store_name,sum(quantity * unit_price) /count(distinct customer_id)
	as revenue_per_customer from stores s join orders o 
	on s.store_id=o.store_id join order_items oi 
	on o.order_id=oi.order_id
	group by s.store_name 
	order by revenue_per_customer desc;

-- 10.Which store has the highest month-over-month revenue growth?


WITH monthly_revenue AS
(
    SELECT
        s.store_name,
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM stores s
    JOIN orders o
        ON s.store_id = o.store_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        s.store_name,
        YEAR(o.order_date),
        MONTH(o.order_date)
),
previous_month AS
(
    SELECT
        store_name,
        order_year,
        order_month,
        revenue,
        LAG(revenue) OVER
        (
            PARTITION BY store_name
            ORDER BY order_year, order_month
        ) AS previous_revenue
    FROM monthly_revenue
)
SELECT TOP 1
    store_name,
    revenue,
    previous_revenue,
    ((revenue - previous_revenue) * 100.0 / previous_revenue)
        AS mom_growth_percentage
FROM previous_month
WHERE previous_revenue IS NOT NULL
ORDER BY mom_growth_percentage DESC;

