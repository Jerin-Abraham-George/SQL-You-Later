/*
==================================================================================================
Ranking Analysis
==================================================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
==================================================================================================
*/

-- Which 5 Products generated the Highest Revenue?
    -- Simple Ranking
SELECT
TOP (5)
p.product_name,
SUM(f.sales_amount) AS Revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY Revenue DESC;

    -- Ranking using WINDOW Function
SELECT *
FROM
(
    SELECT
    p.product_name,
    SUM(f.sales_amount)                                 AS Revenue,
    RANK() OVER(ORDER BY SUM(f.sales_amount) DESC)      AS SalesRank 
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    GROUP BY p.product_name
)t
WHERE SalesRank <= 5

-- What are the 5 worst-performing products in terms of Sales?
SELECT
TOP (5)
p.product_name,
SUM(f.sales_amount)                                     AS Revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY Revenue ASC;

    -- Ranking using WINDOW Function
SELECT *
FROM
(
    SELECT
    p.product_name,
    SUM(f.sales_amount) AS Revenue,
    RANK() OVER(ORDER BY SUM(f.sales_amount) ASC)       AS SalesRank 
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    GROUP BY p.product_name
)t
WHERE SalesRank <= 5


-- Which 5 Sub Category generated the Highest Revenue?
    -- Simple Ranking
SELECT
TOP (5)
p.subcategory,
SUM(f.sales_amount) AS Revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY Revenue DESC;

    -- Ranking using WINDOW Function
SELECT *
FROM
(
    SELECT
    p.subcategory,
    SUM(f.sales_amount) AS Revenue,
    RANK() OVER(ORDER BY SUM(f.sales_amount) DESC)      AS SalesRank 
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    GROUP BY p.subcategory
)t
WHERE SalesRank <= 5


-- What are the 5 worst-performing Sub Categories in terms of Sales?
    -- Simple Ranking
SELECT
TOP (5)
p.subcategory,
SUM(f.sales_amount)                                     AS Revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY Revenue ASC;

    -- Ranking using WINDOW Function
SELECT *
FROM
(
    SELECT
    p.subcategory,
    SUM(f.sales_amount) AS Revenue,
    RANK() OVER(ORDER BY SUM(f.sales_amount) ASC)       AS SalesRank 
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    GROUP BY p.subcategory
)t
WHERE SalesRank <= 5

-- Find the Top 10 Customers who have generated the Highest Revenue
SELECT *
FROM 
    (SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount)                                     AS total_revenue,
    RANK() OVER (ORDER BY SUM(f.sales_amount) DESC)         AS RevenueRank
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
    ) t
WHERE RevenueRank <= 10




-- The 3 customers with the fewest orders placed
SELECT *
FROM 
    (SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number)                                           AS total_order,
    DENSE_RANK() OVER (ORDER BY SUM(f.sales_amount) ASC)                     AS OrderRank
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
    ) t
WHERE OrderRank <= 3
