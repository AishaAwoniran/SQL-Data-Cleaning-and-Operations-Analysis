# Retail Operations Data Cleaning & Analysis Using SQL

## Project Overview

This project focused on cleaning, transforming, and analyzing a retail and operations dataset containing over 5,000 records across three major tables:

* Customers
* Orders
* Shipments

The project was completed entirely using SQL and simulated a real-world business environment where operational data contains inconsistencies, missing values, formatting problems, and invalid records that must be resolved before meaningful analysis can be performed.

The objective was not only to clean the data, but also to generate business insights from the cleaned dataset using SQL queries.
---

# Tools Used

* SQL

---

# Skills Demonstrated

## SQL Skills

* Data Cleaning
* Data Transformation
* Data Validation
* Data Standardization
* String Functions
* Aggregate Functions
* CASE Statements
* Joins
* CTEs
* Subqueries
* NULL Handling
* Business Analysis
---

# Data Cleaning Process

## Orders Table Cleaning

The Orders table contained missing values, inconsistent text formatting, invalid quantities, and duplicate records.

### Cleaning Steps Performed

* Identified and handled NULL values in:
  * Price
  * Total Amount
* Calculated missing Price values using:
* Calculated missing Total Amount values
* Removed rows where both Price and Total Amount were NULL
* Corrected negative quantity values
* Standardized inconsistent order status values:
  * Complete
  * completed
    
→ Converted into a single consistent format.
* Checked for duplicate order records

---

### SQL Queries
```SQL
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
```

## Shipment Table Cleaning

The Shipment table contained inconsistent weight formats, spacing issues, and mixed measurement units.

### Cleaning Steps Performed

* Removed negative signs from weight values

* Standardized spacing and formatting using string functions

* Converted all shipment weights into kilograms for consistency

* Created a new analytical column:

* Standardized mixed units:

  * g
  * kg
  * KG

→ Converted all into kg.

* Preserved NULL delivery dates for shipments marked:

  * In Transit
  * Returned

---

### SQL Queries
```SQL
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
```
---

## Customer Table Cleaning

The Customer table contained inconsistent contact information and incomplete customer records.

### Cleaning Steps Performed

* Created a Full_Name column using concatenation:
  
* Standardized phone numbers

* Standardized country values

* Validated email addresses using SQL logic

* Cleaned and trimmed text fields using string functions

---

### SQL Queries Used
```SQL
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
```
---

# Data Analysis Process

After cleaning the dataset, SQL was used to generate operational and business insights.

## 🔍 Business Questions Answered

### 1. Total Revenue Analysis

* Calculated overall revenue generated
```SQL
select 
	SUM(total_amount) as 'Total Revenue'
from orders
```
<img width="147" height="63" alt="Total Revenue" src="https://github.com/user-attachments/assets/db4e2295-2aee-47da-89c0-dd98f944e55b" />

### 2. Total Orders

* Determined total number of customer orders
```SQL
select 
	count(order_id) 'Total Orders'
from orders
```
<img width="190" height="64" alt="Total Orders" src="https://github.com/user-attachments/assets/14287b40-649f-464e-bb73-1660210fb52f" />

### 3. Total Customers

* Counted unique customers
```SQL
select
	COUNT(distinct customer_id) as 'Total Customer'
from customers_clean
```
<img width="139" height="60" alt="Total Customer" src="https://github.com/user-attachments/assets/993fb5c1-877a-4077-857e-389f0da2de38" />

### 4. Monthly Revenue Trend

* Analyzed revenue growth over time
```SQL
select
	MONTH(order_date) months,
	SUM(total_amount) Revenue
from orders
group by MONTH(order_date)
order by months
```
<img width="184" height="249" alt="Monthly sales trend" src="https://github.com/user-attachments/assets/8ea3942f-37a0-4754-bb59-ca4d581b4d84" />

### 5. Top Selling Products

* Identified highest-performing products
```SQL
select 
	product,
	SUM(quantity) 'Total Quantity Sold',
	SUM(total_amount) 'Revenue'
from orders
group by product
order by Revenue desc
```
<img width="345" height="131" alt="Top Selling Products" src="https://github.com/user-attachments/assets/8238a668-611c-40d7-8651-14c2eb207c8e" />

### 6. Top Customers by Revenue

* Identified customers contributing the most revenue
```SQL
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
```
<img width="260" height="254" alt="Top Customers by revenue" src="https://github.com/user-attachments/assets/669aba71-4baa-4a3d-9f2e-7ee3f8976799" />

### 7. Delivery Status Breakdown

* Analyzed shipment statuses:
  * Delivered
  * In Transit
  * Returned

```SQL
select delivery_status,
COUNT(*) 'Shipment Count'
from shipments
group by delivery_status
```
<img width="241" height="96" alt="Delivery Status Breakdown" src="https://github.com/user-attachments/assets/a5c8d811-3fb6-4b62-b5c7-184a7d30c0b7" />

### 8. Average Delivery Time

* Calculated average shipment delivery duration
```SQL
select delivery_status,
AVG (datediff(day, ship_date, delivery_date) * 1.0) as 'Average delivery days'
from shipments
group by delivery_status
having delivery_status = 'delivered'
```
<img width="333" height="70" alt="Avg delivery days" src="https://github.com/user-attachments/assets/6c852528-19bf-453b-845b-ca4b03ab3567" />

### 9. Return Rate Analysis

* Measured percentage of returned shipments
```SQL
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
```
<img width="209" height="128" alt="Return rate percentage" src="https://github.com/user-attachments/assets/eeb87714-7083-4f32-b715-5ed55a43ef31" />

---
# Project Outcome

The dataset was successfully transformed from raw operational data into a structured and analysis-ready database.

The project demonstrates how SQL can be used not only for querying data, but also for:

* Cleaning messy datasets
* Standardizing operational records
* Handling real-world inconsistencies
* Performing business analysis
* Generating actionable insights
inconsistencies, invalid entries, and duplicate records.
