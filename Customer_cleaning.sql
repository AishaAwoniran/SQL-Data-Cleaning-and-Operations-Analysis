use Datacleaning

select * 
from customers

--checking for nulls 

select * from customers
where first_name is null
--324 rows

select * from customers
where last_name is null
--356 rows

select * 
from customers
where phone is null
--192 rows

--fixing nulls

--fixing null first and last name
alter table customers
add full_name varchar(100);

update customers
set full_name = CONCAT(first_name, ' ', last_name);

alter table customers
drop column first_name

alter table customers
drop column last_name;


update customers
set full_name = trim(full_name);

--standardizing texts

select * from customers

select country,
COUNT(*) countofcountry
from customers
group by country

update customers
set country = 'Nigeria'
where country = 'NG'


--fixing phone number

begin transaction
update customers
set phone = CONCAT('0', phone)
where phone not like '0%'
and phone is not null
commit

select * from customers

-- fixing email
alter table customers
add email_status varchar(20)

update customers
set email_status = 
case 
	when email like '%@%.com' then 'Valid'
	else 'Invalid'
end;


--reordering table


select
	customer_id,
	full_name,
	email,
	email_status,
	phone, 
	join_date, 
	country
into customers_clean
from customers

--checking for duplicates
select customer_id,
COUNT(*) as countofcustomer
from customers
group by customer_id
having COUNT(*) > 1
