-- Customer and Product Analysis SQL Project

-- Introduction:
-- As part of this project we will be analysing the scale model car datbase using SQL to answer following questions:

-- Question 1: Which products should we order more of or less of?
-- Question 2: How should we tailor marketing and communication strategies to customer behaviors?
-- Question 3: How much can we spend on acquiring new customers?

-- Datbase Summary:
-- Customers: customer data                             (PK: customerNumber, FK: salesRepEmployeeNumber (employees)) 
-- Employees: all employee information                  (PK: employeeNumber (recursive relationship with reportsTo), FK: officeCode (offices))
-- Offices: sales office information                    (PK: officeCode)
-- Orders: customers' sales orders                      (PK: orderNumber, FK: customerNumber (customers))
-- OrderDetails: sales order line for each sales order  (PK: orderNumber (orders), productCode(products))
-- Payments: customers' payment records                 (PK: customerNumber (customers), checkNumber)
-- Products: a list of scale model cars                 (PK: productCode, FK: productLine (productlines))
-- ProductLines: a list of product line categories      (PK: productLine)

-- Query 1

SELECT 'customers' AS table_name, 13 AS num_attributes, COUNT(*) AS num_rows
  FROM customers
	
UNION ALL 

SELECT 'products' AS table_name,  9 AS num_attributes, COUNT(*) AS num_rows
  FROM products

UNION ALL 

SELECT 'productlines' AS table_name,  4 AS num_attributes, COUNT(*) AS num_rows
  FROM productlines

UNION ALL 

SELECT 'orders' AS table_name,  7 AS num_attributes, COUNT(*) AS num_rows 
  FROM orders
	
UNION ALL 

SELECT 'orderdetails' AS table_name,  5 AS num_attributes, COUNT(*) AS num_rows
  FROM orderdetails
	
UNION ALL 

SELECT 'payments' AS table_name,  4 AS num_attributes, COUNT(*) AS num_rows
  FROM payments
	
UNION ALL 

SELECT 'employees' AS table_name,  8 AS num_attributes, COUNT(*) AS num_rows
  FROM employees
	
UNION ALL 

SELECT 'offices' AS table_name,  9 AS num_attributes, COUNT(*) AS num_rows
  FROM offices;

----------------------------------------------------------------------------------------------------------------------------------------------
-- Question 1: Which Products Should We Order More of or Less of?
----------------------------------------------------------------------------------------------------------------------------------------------
-- a. Write a query to compute the low stock for each product

SELECT products.productCode, SUM(orderdetails.quantityOrdered)/products.quantityInStock AS low_stock
  FROM products
  JOIN orderdetails
    ON products.productCode = orderdetails.productCode
 GROUP BY products.productCode
 ORDER BY low_stock ASC
 LIMIT 10;

-- b. Write a query to compute the product performance for each product

SELECT orderdetails.productCode, SUM(orderdetails.quantityOrdered*orderdetails.priceEach) AS product_performance
  FROM orderdetails
 GROUP BY productCode
 ORDER BY product_performance DESC;
 LIMIT 10;

-- c. Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using the IN operator

WITH
low_stock AS (
SELECT products.productCode, SUM(orderdetails.quantityOrdered)/products.quantityInStock AS low_stock
  FROM products
  JOIN orderdetails
    ON products.productCode = orderdetails.productCode
 GROUP BY products.productCode
 ORDER BY low_stock ASC
 LIMIT 10
),
product_performance AS (
SELECT productCode, SUM(quantityOrdered*priceEach) AS product_performance
  FROM orderdetails
 GROUP BY productCode
 ORDER BY product_performance DESC
 LIMIT 10
)
SELECT low_stock.productCode
  FROM low_stock
 WHERE low_stock.productCode IN (SELECT product_performance.productCode
								   FROM product_performance);

----------------------------------------------------------------------------------------------------------------------------------------------
-- Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
----------------------------------------------------------------------------------------------------------------------------------------------
-- a. Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place.
SELECT o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
  JOIN products AS p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
 ORDER BY profit DESC;

 -- b. Write a query to find the top five VIP customers
WITH
profit_per_customer AS (
SELECT o.customerNumber AS customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
  JOIN products AS p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
 ORDER BY profit DESC
)
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, profit_per_customer.profit
  FROM customers AS c
  JOIN profit_per_customer
    ON c.customerNumber = profit_per_customer.customerNumber
 ORDER BY profit_per_customer.profit DESC
 LIMIT 5;

 -- c. Write a query to find the bottom five customers
 WITH
profit_per_customer AS (
SELECT o.customerNumber AS customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
  JOIN products AS p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
 ORDER BY profit DESC
)
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, profit_per_customer.profit
  FROM customers AS c
  JOIN profit_per_customer
    ON c.customerNumber = profit_per_customer.customerNumber
 ORDER BY profit_per_customer.profit ASC
 LIMIT 5;

----------------------------------------------------------------------------------------------------------------------------------------------
-- Question 3: How Much Can We Spend on Acquiring New Customers?
----------------------------------------------------------------------------------------------------------------------------------------------
-- a. Write a query to compute the average of customer profits using the CTE on the previous screen
WITH
profit_gen_table AS (
SELECT os.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS prof_gen  
  FROM products pr
  JOIN orderdetails od
    ON pr.productCode = od.productCode
  JOIN orders os
    ON od.orderNumber = os.orderNumber
 GROUP BY os.customerNumber
)
SELECT AVG(pg.prof_gen) AS lyf_tym_val
  FROM profit_gen_table pg;


/* 
----------------------------------------------------------------------------------------------------------------------------------------------
CONCLUSION
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
-- Question 1: Which Products Should We Order More of or Less of?
----------------------------------------------------------------------------------------------------------------------------------------------

After analyzing the query results that compared low stock with product performance, it was observed that 60% of the low-stock products belonged 
to the 'Classic Cars' product line. These products have a high frequency of sale and perform well in terms of product performance. Therefore, it 
is recommended to frequently replenish the stock of these products to ensure their availability for customers.
 
----------------------------------------------------------------------------------------------------------------------------------------------
-- Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
----------------------------------------------------------------------------------------------------------------------------------------------
  
Upon analyzing the query results that compared the top and bottom customers in terms of profit generation, it was observed that our top customers 
have generated a significant portion of our profits. To retain these valuable customers, it is recommended that we offer loyalty rewards and priority 
services to make them feel appreciated and valued.

On the other hand, the bottom customers have contributed relatively less to our profits. Therefore, it is important to understand their preferences 
and solicit feedback to identify areas where we can improve our products and services to better meet their needs. Additionally, we may consider offering 
them special pricing, discounts, and offers to incentivize them to increase their spending and potentially become more profitable customers in the future.
 
----------------------------------------------------------------------------------------------------------------------------------------------
-- Question 3: How Much Can We Spend on Acquiring New Customers?
----------------------------------------------------------------------------------------------------------------------------------------------
  
The statement regarding the average customer lifetime value of our store is significant, as it indicates the amount of revenue we can expect 
to generate from each customer over the course of their relationship with our store. With an average customer lifetime value of $39,040, we 
can use this information to make informed decisions about how much we should spend on customer acquisition.

By comparing the cost of acquiring new customers with the expected revenue generated from each new customer, we can determine the maximum 
amount we can spend on customer acquisition while still maintaining or increasing our profit levels. This analysis can help us make informed 
decisions about our marketing and advertising budgets, ensuring that we are allocating resources in a way that maximizes our return on investment.
	          
*/
