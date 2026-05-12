--use datacleaning

--Data Analysis

--1. Total Revenue
select 
	SUM(total_amount) as 'Total Revenue'
from orders

--2. Total Orders
select 
	count(order_id) 'Total Orders'
from orders

--3. Total Customers
select
	COUNT(distinct customer_id) as 'Total Customer'
from customers_clean

--4. Monthly sales trend
select
	MONTH(order_date) months,
	SUM(total_amount) Revenue
from orders
group by MONTH(order_date)
order by months

--5. Top Selling Products
select 
	product,
	SUM(quantity) 'Total Quantity Sold',
	SUM(total_amount) 'Revenue'
from orders
group by product
order by Revenue desc

--6. Top Customers by Revenue
select top 10 
	customers_clean.customer_id,
	customers_clean.full_name,
	SUM(orders.total_amount) as Revenue
from orders 
right join customers_clean
	on orders.customer_id = customers_clean.customer_id
	group by customers_clean.customer_id,
	customers_clean.full_name
order by Revenue desc

--7 delivery status breakdown
select delivery_status,
COUNT(*) 'Shipment Count'
from shipments
group by delivery_status

--8 Average delivery time
select delivery_status,
AVG (datediff(day, ship_date, delivery_date) * 1.0) as 'Average delivery days'
from shipments
group by delivery_status
having delivery_status = 'delivered'

--9 Return rate
select 
	ROUND(
		count(
			case when delivery_status = 'returned'
			then 1 
			end) *100.0
			/ count (*),
			2
			) as 'return rate percentage'
from shipments
