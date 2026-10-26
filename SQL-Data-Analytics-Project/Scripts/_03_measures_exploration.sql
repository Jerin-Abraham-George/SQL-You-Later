/*
===========================================================================================
Measures Exploration (Key Metrics)
===========================================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===========================================================================================
*/

-- Find the Total Sales
SELECT
SUM(sales_amount) AS Total_Sales
FROM gold.fact_sales

-- Find how many items are sold
SELECT
SUM(quantity) AS Total_Quantity
FROM gold.fact_sales

-- Find the Average Selling Price
SELECT
AVG(price) AS Avg_Selling_Price
FROM gold.fact_sales

-- Find the Total Number of Orders
SELECT
COUNT(order_number) AS Total_Orders
FROM gold.fact_sales

SELECT
COUNT(DISTINCT order_number) AS Total_Orders
FROM gold.fact_sales

-- Find the Total Number of Products
SELECT
COUNT(product_name) AS Total_Products
FROM gold.dim_products


-- Find the Total Number of Customers
SELECT
COUNT(customer_key) AS Total_Customers
FROM gold.dim_customers


-- Find the Total Number of that has placed an order
SELECT
COUNT(DISTINCT customer_key) AS Total_Customers
FROM gold.fact_sales

-- Generate Report that shows all Key Metrics of the business
SELECT
'Total Sales' AS measure_name, 
SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
'Total Quantity',
SUM(quantity)
FROM gold.fact_sales

UNION ALL
SELECT
'Average Selling Price',
AVG(price)
FROM gold.fact_sales

UNION ALL

SELECT
'Total Orders',
COUNT(order_number) 
FROM gold.fact_sales

UNION ALL

SELECT
'Total Products', 
COUNT(product_name) 
FROM gold.dim_products

UNION ALL 

SELECT
'Total Customers', 
COUNT(customer_key) 
FROM gold.dim_customers
