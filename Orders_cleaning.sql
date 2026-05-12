use Datacleaning

select * from orders

--checking for nulls

select * from orders
where price is null
--950 nulls

select * from orders
where total_amount is null
--468 nulls

--fixing nulls

--checking for negative quantity

select * from orders
where quantity <0
--1311 rows

--fixing negative quantity
update orders
set quantity = 1
where quantity = -1

--fixing nulls

delete from orders
where price is null
and total_amount is null
--468 rows affected

select * from orders
where price is null

update orders
set price = total_amount/quantity
where price is null

update orders 
set total_amount = price * quantity

--checking for duplicates

select order_id,
COUNT(*) as occurences
from orders
group by order_id
having COUNT(*) > 1;
--No duplicates

select status, 
count(*) as countofstatus
from orders
group by status

--standardizing text

update orders
set status = 'Completed'
where status = 'complete'

select * from orders

select MIN(price) minphoneprice,
MAX(price) maxphoneprice
from orders
where product = 'phone'

select product,
MIN(price) minphoneprice,
MAX(price) maxphoneprice
from orders
group by product

