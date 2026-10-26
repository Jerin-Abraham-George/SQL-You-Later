# 📊 SQL Data Analytics Project

## Overview

This project demonstrates a complete SQL-based data analytics workflow designed to transform raw transactional data into meaningful business insights.

Using a dimensional data warehouse structure consisting of fact and dimension tables, the project explores customer behavior, product performance, sales trends, revenue contributions, customer segmentation, and business KPIs through advanced SQL analysis.

The project follows a real-world analytics approach, progressing from data exploration and metric generation to customer reporting, product reporting, and performance evaluation.

---

## Objectives

- Explore and understand business datasets through SQL.
- Analyze customer, product, and sales performance.
- Generate key business metrics and KPIs.
- Identify revenue-driving products and customers.
- Track trends and performance over time.
- Build reusable analytical reports using SQL Views.
- Apply advanced SQL functions for business intelligence and decision-making.

---

## Dataset Structure

The project uses a dimensional data model consisting of:

### Fact Table

| Table | Description |
|---------|------------|
| `gold.fact_sales` | Contains transactional sales data including orders, quantities, revenue, and dates |

### Dimension Tables

| Table | Description |
|---------|------------|
| `gold.dim_customers` | Customer information including demographics and location |
| `gold.dim_products` | Product information including categories and costs |

---

## Key Features

### 🔍 Dimensions Exploration
Analyzed dimension tables to understand:

- Customer geographic distribution
- Product categories
- Product subcategories
- Product catalog structure

### 📅 Date Range Exploration
Determined:

- First and last order dates
- Available historical data range
- Customer age distribution
- Youngest and oldest customers

### 📏 Measures Exploration
Generated core business KPIs:

- Total Sales
- Total Quantity Sold
- Average Selling Price
- Total Orders
- Total Products
- Total Customers
- Active Purchasing Customers

### 📊 Magnitude Analysis
Measured business performance across:

- Countries
- Product Categories
- Customer Segments
- Revenue Distribution
- Product Distribution

### 🏆 Ranking Analysis
Identified:

- Top Performing Products
- Lowest Performing Products
- Highest Revenue Customers
- Best Selling Subcategories
- Lowest Performing Subcategories

### 📈 Change Over Time Analysis
Analyzed business growth trends:

- Monthly Sales Trends
- Customer Trends
- Quantity Trends
- Time-Series Performance Analysis

### 🔄 Cumulative Analysis
Calculated:

- Running Sales Totals
- Yearly Sales Growth
- Moving Averages
- Long-Term Performance Trends

### ⚡ Performance Analysis
Compared performance using:

- Year-over-Year Analysis
- Product Sales Benchmarking
- Previous Year Comparisons
- Average Performance Evaluation

### 🧩 Part-to-Whole Analysis
Measured category contribution to overall business performance by:

- Revenue Share Analysis
- Percentage Contribution Analysis
- Category Impact Assessment

### 🎯 Customer & Product Segmentation
Created business segments for:

#### Customer Segmentation

- VIP Customers
- Regular Customers
- New Customers

#### Product Segmentation

- High Performers
- Mid-Range Products
- Low Performers

### 📑 Analytical Reporting
Built reusable analytical views:

- Customer Intelligence Report
- Product Intelligence Report

---

## SQL Concepts Demonstrated

### Query Fundamentals

- SELECT
- WHERE
- ORDER BY
- GROUP BY
- HAVING
- DISTINCT

### Aggregate Functions

- COUNT()
- SUM()
- AVG()
- MIN()
- MAX()

### Date Functions

- YEAR()
- MONTH()
- DATEDIFF()
- DATETRUNC()
- FORMAT()

### Conditional Logic

- CASE Statements

### Joins

- LEFT JOIN

### Common Table Expressions (CTEs)

- WITH Clause
- Multi-step Analytical Queries

### Window Functions

- RANK()
- DENSE_RANK()
- LAG()
- SUM() OVER()
- AVG() OVER()

### View Creation

- CREATE VIEW

---

## Analytical Workflow

```text
Data Exploration
        │
        ▼
Business Metrics
        │
        ▼
Magnitude Analysis
        │
        ▼
Ranking Analysis
        │
        ▼
Trend Analysis
        │
        ▼
Performance Evaluation
        │
        ▼
Segmentation Analysis
        │
        ▼
Customer Reporting
        │
        ▼
Product Reporting
```

---

## Customer Report

A reusable SQL view was developed to consolidate customer-level intelligence.

### Metrics Generated

- Customer Name
- Age
- Age Group
- Customer Segment
- Total Orders
- Total Sales
- Total Quantity Purchased
- Total Products Purchased
- Customer Lifespan
- Recency
- Average Order Value
- Average Monthly Spend

### Customer Segments

| Segment | Criteria |
|----------|----------|
| VIP | Lifespan ≥ 12 Months and Spending > €5,000 |
| Regular | Lifespan ≥ 12 Months and Spending ≤ €5,000 |
| New | Lifespan < 12 Months |

---

## Product Report

A reusable SQL view was created to evaluate product performance.

### Metrics Generated

- Product Name
- Category
- Subcategory
- Total Orders
- Total Sales
- Total Quantity Sold
- Total Customers
- Product Lifespan
- Recency
- Average Selling Price
- Average Order Revenue
- Average Monthly Revenue

### Product Segments

| Segment | Criteria |
|----------|----------|
| High Performer | Revenue > 50,000 |
| Mid-Range | Revenue between 10,000 and 50,000 |
| Low Performer | Revenue < 10,000 |

---

## Business Questions Answered

### Customers

- Which countries generate the most customers?
- Who are the highest revenue customers?
- How can customers be segmented based on spending behavior?
- What is the customer lifecycle and recency?

### Products

- Which products generate the highest revenue?
- Which products underperform?
- Which categories contribute most to sales?
- What are the most profitable product segments?

### Sales

- How has sales performance evolved over time?
- What are the monthly sales trends?
- How does current performance compare to previous years?
- What percentage of revenue comes from each category?

---

## Skills Demonstrated

- Data Exploration
- Data Aggregation
- Business Intelligence
- KPI Development
- Customer Analytics
- Product Analytics
- Revenue Analysis
- Segmentation Analysis
- Time-Series Analysis
- Dimensional Modeling
- SQL Reporting
- Advanced Window Functions
- Analytical SQL Development

---

## Result

This project demonstrates how SQL can be used as a complete analytics solution for transforming raw transactional data into actionable business intelligence.

By combining exploratory analysis, KPI reporting, segmentation, trend analysis, ranking techniques, and reusable reporting views, the project delivers a structured framework for understanding customer behavior, product performance, and overall business growth through data-driven decision-making.

---

## Tools & Technologies

- SQL Server
- T-SQL
- Data Warehouse Model
- Fact & Dimension Tables
- Common Table Expressions (CTEs)
- Window Functions
- SQL Views
- Business Intelligence Analytics

---

👑 "Every customer is special. Some are just special enough to be labeled VIP by a CASE statement."
