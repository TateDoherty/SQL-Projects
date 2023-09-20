--Intro: Hi, my name is Tate Doherty and this is a SQL Project using a data set from Kaggle about Bike Store data to learn trends and insights. 
--link: https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database?select=stores.csv
--This project was made using Microsoft SQL Server Management Studio

--1. Check that all 9 tables imported below have data that is available 

SELECT * FROM dbo.brands 
SELECT * FROM dbo.categories
SELECT * FROM dbo.customers
SELECT * FROM dbo.order_items
SELECT * FROM dbo.orders
SELECT * FROM dbo.products
SELECT * FROM dbo.staffs
SELECT * FROM dbo.stocks
SELECT * FROM dbo.stores

--2. Check for missing values in all 9 tables

SELECT COUNT(*) AS MissingValues FROM dbo.brands WHERE brand_id IS NULL OR brand_name IS NULL
SELECT COUNT(*) AS MissingValues FROM dbo.categories WHERE category_id IS NULL OR category_name IS NULL
SELECT COUNT(*) AS MissingValues FROM dbo.customers WHERE customer_id IS NULL OR first_name IS NULL OR last_name IS NULL 
SELECT COUNT(*) AS MissingValues FROM dbo.order_items WHERE order_id IS NULL OR item_id IS NULL OR product_id IS NULL
SELECT COUNT(*) AS MissingValues FROM dbo.products WHERE product_id IS NULL
SELECT COUNT(*) AS MissingValues FROM dbo.orders WHERE order_id IS NULL OR customer_id IS NULL OR store_id IS NULL OR staff_id IS NULL
SELECT COUNT(*) AS MissingValues FROM dbo.staffs WHERE staff_id IS NULL OR first_name IS NULL OR last_name IS NULL
SELECT COUNT(*) AS MissingValues FROM dbo.stocks WHERE store_id IS NULL OR product_id IS NULL
SELECT COUNT(*) AS MissingValues FROM dbo.stores WHERE store_id IS NULL OR store_name IS NULL

--3. Check to see the count of customers, orders, products, stores, and staff in the database

SELECT  COUNT(customer_id) AS CustomerCount FROM dbo.customers
SELECT  COUNT(order_id) AS OrderCount FROM dbo.orders
SELECT  COUNT(product_id) AS ProductCount FROM dbo.products
SELECT  COUNT(store_id) AS StoreCount FROM dbo.stores
SELECT  COUNT(staff_id) AS StaffCount FROM dbo.staffs

--4. Find the top 20 most sold items in the bike store database

SELECT COUNT(orditems.order_id) AS OrderCount, prod.product_name
FROM dbo.order_items orditems JOIN dbo.products prod ON orditems.product_id = prod.product_id
GROUP BY prod.product_name
ORDER BY OrderCount DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY

--5. Find the top 10 cities where customers purchase the most bikes
SELECT cust.city, COUNT(ord.order_id) AS OrdCount
FROM dbo.customers cust JOIN dbo.orders ord ON cust.customer_id = ord.customer_id 
GROUP BY cust.city
ORDER BY OrdCount DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY

--6. Find which stores sell the most items in the bike store database and include their state and city location

SELECT COUNT(ord.order_id) as OrdCount, store.store_name, store.state, store.city
FROM dbo.orders ord JOIN dbo.stores store ON ord.store_id = store.store_id
GROUP BY  store.store_name, store.state, store.city
ORDER BY OrdCount DESC

--7. Find out which staff members make the most amount of sales along with their phone number and store name

SELECT COUNT(ord.order_id) AS OrdCount, staff.first_name, staff.last_name, staff.phone, store.store_name
FROM dbo.orders AS ord JOIN dbo.staffs as staff ON ord.staff_id = staff.staff_id
JOIN dbo.stores store ON staff.store_id = store.store_id
GROUP BY staff.first_name, staff.last_name, store.store_name, staff.phone
ORDER BY OrdCount DESC



--8. List the average price of products from each category and round to the nearest cent 

SELECT ROUND(AVG(prod.list_price), 2) AS AvgListPrice, cat.category_name
FROM dbo.categories cat JOIN dbo.products prod ON cat.category_id = prod.product_id
GROUP BY cat.category_name
ORDER BY AvgListPrice DESC

--9. Make a temporary table and decrease the list price of road bikes by 10% and increase the list price of children bicycles by 10% and round to the nearest cent

DROP TABLE IF EXISTS #Temp_ListPrice_Table
CREATE TABLE #Temp_ListPrice_Table 
	(product_id int, product_name nvarchar(200), brand_id int, category_id int, list_price float, category_name nvarchar(200))
INSERT INTO #Temp_ListPrice_Table 
SELECT prod.product_id, prod.product_name, prod.brand_id, prod.category_id, prod.list_price, cat.category_name
FROM dbo.categories cat JOIN dbo.products prod ON cat.category_id = prod.product_id



ALTER TABLE #Temp_ListPrice_Table ADD AlteredListPrice AS 
(CASE WHEN category_name = 'Road Bikes' THEN list_price - (list_price*.10)
	  WHEN category_name = 'Children Bicycles' THEN list_price + list_price*.05
	  ELSE list_price 
	  END)

SELECT category_name, ROUND(list_price, 2) AS OriginalListPrice, ROUND(AlteredListPrice, 2) AS AlteredListPrice
FROM #Temp_ListPrice_Table

--10. There has been a flooding incident on 2016-01-06 and shipping will be delayed by 2 days in Yonkers, New York. 
--Please find the customer(s) email(s) and alter the shipping date by 2 days to compensate for the flood.

DROP TABLE IF EXISTS #Temp_ShippingDate_Table
CREATE TABLE #Temp_ShippingDate_Table (customer_id int, order_id int, email nvarchar(200) , city nvarchar(200), shipped_date nvarchar(200))

INSERT INTO #Temp_ShippingDate_Table
SELECT cust.customer_id, ord.order_id, cust.email, cust.city, ord.shipped_date
FROM dbo.customers cust JOIN dbo.orders ord ON cust.customer_id = ord.customer_id

ALTER TABLE #Temp_ShippingDate_Table ADD NewShippingDate AS
(CASE WHEN shipped_date = '2016-01-06' AND city = 'Yonkers' THEN '2016-01-08' ELSE shipped_date END)

SELECT email, city, shipped_date, NewShippingDate FROM #Temp_ShippingDate_Table WHERE city = 'Yonkers' AND shipped_date = '2016-01-06'


--Conclusion

--Insights and Trends Learned from the Bike Store Database:

-- Learned the count of customers, orders, products, stores, and staff to get a general view of the database (Step #3) 
-- Learned the top 20 most sold bikes so store owners should consider purchasing more of the bikes that are most sold in the stores (Step #4) 
-- Figured out the top 10 cities where customers purchase the most bikes so store managers can prioritize which cities the most bikes should go to (Step #5) 
-- Figured out which stores receive the most bike orders in case of a potential store closure in the future (Step #6) 
-- Figured out which staff members make the most amount of sales along with their phone number and store name if a store manager is issuing a raise/promotion (Step #7) 
-- Learned the average price of bikes by category so the store manager can price other bikes in the same category at that price (Step #8) 
-- Learned how to alter bike prices by category in the case the store manager wants to increase or decrease the price of bike categories (Step #9) 
-- Figured out how to alter the shipping date by city in the case of a flood if the store manager needs to adjust shipping dates due to natural disaters (Step #10) 
