Create database Datacleaning

use Datacleaning

--cleaning shipments table
select * from shipments;

--findimg null values

select * from shipments
where delivery_date is null;
--994 null delivery date

select * from shipments
where delivery_date is null
and delivery_status = 'delivered';
--329 null 

select * from shipments
where shipping_cost is null;
--1274 nulls

--fixing null values

--fixing null delivery date
delete from shipments
where delivery_status = 'delivered'
and delivery_date is null;
-- 329 rows affected

--fixing null shipping cost
select 
AVG(shipping_cost) as avgshippingcost,
MIN(shipping_cost) as minshippingcost,
MAX(shipping_cost) as maxshippingcost
from shipments
--avgshippingcost is 4503
--minshippingcost is 4000
--maxshippingcost is 5000

--replacing null shipping cost with average shipping cost
update shipments
set shipping_cost = 4503
where shipping_cost is null
--1175 rows affected

--
select * from shipments

-- fixing negative weight 

select * from shipments
where weight like '-%'
-- 929 negatives

update shipments
set weight = REPLACE(weight, '-', ' ')
where weight like '-%'

update shipments
set weight= trim(weight)

--standardizing weight 
alter table shipments
add weight_kg decimal(10,2)

select * from shipments

update shipments
set weight_kg =
case 
	when LOWER(weight) like '%g'
		and LOWER(weight) not like '%kg'
	then CAST(replace(lower(weight), 'g', ' ')
as decimal(10,2))/1000

	when LOWER(weight) like '%kg'
	then cast(replace(lower(trim(weight)), 'kg', ' ')
as decimal(10,1))
end;

--drop the old weight column
begin transaction
alter table shipments
drop column weight
commit

select * from shipments

--check for duplicates

select shipment_id,
COUNT(*) as countofships
from shipments
group by shipment_id
having COUNT(*) > 1
-- no duplicates
