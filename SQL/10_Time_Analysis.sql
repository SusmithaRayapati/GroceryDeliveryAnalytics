USE grocery_delivery_db;

select * from customers;
select * from stores;
select * from products;
select * from orders;
select * from order_items;

-- 1.Classify deliveries as Fast, Normal, Slow using CASE.

SELECT 
    order_id,
    delivery_time_minutes,
    CASE
        WHEN delivery_time_minutes <= 20 THEN 'Fast'
        WHEN delivery_time_minutes BETWEEN 21 AND 40 THEN 'Normal'
        ELSE 'Slow'
    END AS delivery_category
FROM orders;

-- 2.Find the average delivery time across all orders.

select avg(delivery_time_minutes) as avg_delivery_time from orders;

-- 3.Find the minimum and maximum delivery time.

select min(delivery_time_minutes) as min_delivery_time,
max(delivery_time_minutes) as max_delivery_time
from orders;

-- 4.Find the average delivery time for each store.

select store_name,avg(o.delivery_time_minutes) as avg_delivery_time
from orders o join stores s on o.store_id=s.store_id
group by store_name ;

-- 5.Find stores where average delivery time > 30 minutes.

select store_name,avg(delivery_time_minutes) as avg_delivery_time
from orders o join stores s on o.store_id =s.store_id
group by store_name having avg(delivery_time_minutes)>30;

-- 6.Find orders where delivery time > 45 minutes.

select order_id,max(delivery_time_minutes) as delivery_time
from  orders group by order_id
having max(delivery_time_minutes)>45;

-- 7.Find the Top 5 stores with the fastest average delivery time.

select top 5 
    store_name,avg(delivery_time_minutes) as fastest_avg_delievry_time
    from orders o join stores s on o.store_id=s.store_id
    group by store_name order by fastest_avg_delievry_time desc;
    
-- 8.Count orders in each Fast / Normal / Slow category.

SELECT
    CASE
        WHEN delivery_time_minutes <= 20 THEN 'Fast'
        WHEN delivery_time_minutes BETWEEN 21 AND 40 THEN 'Normal'
        ELSE 'Slow'
    END AS delivery_category,
    COUNT(*) AS order_count
FROM orders
GROUP BY
    CASE
        WHEN delivery_time_minutes <= 20 THEN 'Fast'
        WHEN delivery_time_minutes BETWEEN 21 AND 40 THEN 'Normal'
        ELSE 'Slow'
    END;

-- 9.Find the store with the highest average delivery time.

select top 1
    store_name,avg(delivery_time_minutes) as highest_avg_delivery_time
    from orders o join stores s on o.store_id=s.store_id
    group by store_name order by highest_avg_delivery_time desc;

-- 10.Find orders whose delivery time is above the overall average.

select order_id,delivery_time_minutes from orders
where delivery_time_minutes>(
select avg(delivery_time_minutes) from orders );

