# 🏗️ SQL Data Warehouse Project

An end-to-end SQL Data Warehouse project demonstrating data ingestion, data cleansing, transformation, and analytical modeling using the **Bronze, Silver, and Gold Medallion Architecture**.

---

# 📌 Table of Contents

- #-project-overview
- #-project-objectives
- #️-data-architecture
- #️-technology-stack
- #-data-sources
- #-medallion-architecture
  - #-bronze-layer--raw-data-ingestion
  - #-silver-layer--data-cleansing-and-transformation
  - #-gold-layer--analytics-and-business-modeling
- #-etl-workflow
- #-project-structure
- #-getting-started
- #-example-analytical-queries
- #-data-quality-and-validation
- #-key-concepts-demonstrated

---

# 📖 Project Overview

The objective of this project is to build a structured data warehouse that transforms raw source data into reliable, consistent, and analytics-ready datasets.

The solution follows a layered data architecture where each layer serves a distinct purpose:

1. **Bronze Layer – Ingestion**  
   Stores raw data directly from source systems.

2. **Silver Layer – Transformation**  
   Cleans, standardizes, validates, and integrates data.

3. **Gold Layer – Analytics**  
   Organizes processed data into business-oriented models for reporting and analysis.

This architecture separates raw ingestion from transformation and analytical modeling, making the pipeline easier to maintain, troubleshoot, and extend.

---

# 🎯 Project Objectives

- Design a Data Warehouse using Medallion Architecture.
- Ingest data from source files into SQL Server.
- Develop SQL scripts for database creation and data loading.
- Apply data cleansing and standardization techniques.
- Handle missing values and inconsistent formats.
- Integrate related entities across source systems.
- Build business-oriented analytical models.
- Prepare data for reporting, dashboards, and business intelligence.
- Demonstrate practical SQL and Data Engineering skills.

---

# 🏛️ Data Architecture

The project follows a layered data processing architecture:

```text
              SOURCE DATA
                   |
           +-------+-------+
           |               |
        Source 1       Source 2
           |               |
           +-------+-------+
                   |
                   v
           +---------------+
           | BRONZE LAYER  |
           | Raw Ingestion |
           +---------------+
                   |
                   v
           +---------------+
           | SILVER LAYER  |
           | Clean &       |
           | Standardize   |
           +---------------+
                   |
                   v
           +---------------+
           |  GOLD LAYER   |
           | Business-Ready|
           | Data Models   |
           +---------------+
                   |
                   v
           +---------------+
           | ANALYTICS &   |
           | REPORTING     |
           +---------------+
```

## Why Medallion Architecture?

| Layer | Primary Purpose | Expected Outcome |
|---------|----------------|------------------|
| Bronze | Ingest source data | Raw, traceable data |
| Silver | Clean and transform data | Consistent, validated data |
| Gold | Model data for business use | Analytics-ready datasets |

Each layer builds on the previous one, ensuring a clear separation of responsibilities within the pipeline.

---

# 🛠️ Technology Stack

| Technology | Purpose |
|------------|---------|
| SQL | Data transformation and analytical querying |
| Microsoft SQL Server | Data Warehouse platform |
| T-SQL | Database development and automation |
| SSMS | SQL development and administration |
| CSV Files | Source data ingestion |
| Git & GitHub | Version control and documentation |

---

# 📂 Data Sources

The warehouse integrates data from multiple business systems for analysis.

| Source System | Typical Data Domain | Analytical Purpose |
|--------------|-------------------|-------------------|
| CRM | Customer Information | Customer profiling |
| CRM | Product Information | Product performance |
| CRM | Sales Transactions | Revenue analysis |
| ERP | Customer Attributes | Customer enrichment |
| ERP | Geographic Data | Regional analysis |
| ERP | Product Categories | Product classification |

> ⚠️ Update this section to reflect the exact datasets and entities used in your implementation.

---

# 🥉🥈🥇 Medallion Architecture

---

## 🥉 Bronze Layer – Raw Data Ingestion

The Bronze Layer serves as the entry point of the warehouse.

### Responsibilities

- Create raw staging tables.
- Load source data without modification.
- Preserve original source values.
- Maintain source-specific tables.
- Enable traceability and reprocessing.

### Processing Flow

```text
Source Files
     |
     v
Raw Table Definitions
     |
     v
Data Ingestion
     |
     v
Bronze Tables
```

The Bronze layer provides a reliable foundation for troubleshooting and auditability.

---

## 🥈 Silver Layer – Data Cleansing and Transformation

The Silver Layer transforms raw data into reliable and standardized datasets.

### Responsibilities

- Standardize text values and formats.
- Convert data types.
- Handle null or invalid values.
- Remove duplicates.
- Validate business rules.
- Integrate related datasets.
- Prepare data for analytics.

### Processing Flow

```text
Bronze Tables
     |
     v
Data Profiling
     |
     v
Cleansing & Standardization
     |
     v
Validation & Integration
     |
     v
Silver Tables
```

Transformation logic should be documented to keep processing transparent and reproducible.

---

## 🥇 Gold Layer – Analytics and Business Modeling

The Gold Layer exposes business-ready analytical datasets.

### Responsibilities

- Build dimensional models.
- Create fact and dimension tables.
- Simplify reporting.
- Support BI and Dashboarding.
- Provide reusable analytical datasets.

### Example Star Schema

```text
              +------------------+
              | Customer         |
              | Dimension        |
              +------------------+
                       |
                       |
+------------------+   |   +------------------+
| Product          |---+---| Sales Fact       |
| Dimension        |       | Transactions     |
+------------------+       +------------------+
                                    |
                                    |
                           +------------------+
                           | Date Dimension   |
                           +------------------+
```

> Replace this diagram with your actual Gold-layer schema if it differs.

---

# 🔄 ETL Workflow

| Stage | Activity | Result |
|---------|---------|---------|
| 1. Initialize | Create database and schemas | Warehouse environment |
| 2. Define Bronze | Create raw staging tables | Source-compatible structures |
| 3. Load Bronze | Ingest source data | Raw datasets |
| 4. Define Silver | Create transformed tables | Process-ready structures |
| 5. Load Silver | Apply cleansing rules | Clean datasets |
| 6. Build Gold | Create analytical models | Business-ready data |
| 7. Validate | Run quality checks | Verified outputs |
| 8. Analyze | Query Gold layer | Business insights |

---

# 📁 Project Structure

```text
SQL-Data-Warehouse-Project/
│
├── datasets/
│
├── scripts/
│   ├── init_database.sql
│   │
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── proc_load_bronze.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   └── proc_load_silver.sql
│   │
│   └── gold/
│       └── ddl_gold.sql
│
├── tests/
│
└── README.md
```

---

# 🚀 Getting Started

## Prerequisites

Before running the project, ensure you have:

- Microsoft SQL Server installed.
- SQL Server Management Studio (SSMS).
- Required source datasets.
- Database creation permissions.
- Access to source file locations.

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/Jerin-Abraham-George/SQL-You-Later.git
```

```bash
cd SQL-You-Later/SQL-Data-Warehouse-Project
```

---

## Step 2: Initialize the Database

Execute:

```sql
init_database.sql
```

Verify that:

- Database exists.
- Schemas are created.
- Required permissions are configured.

---

## Step 3: Create Bronze Layer

Execute:

```sql
ddl_bronze.sql
```

Create Bronze procedures:

```sql
proc_load_bronze.sql
```

---

## Step 4: Load Bronze Data

```sql
EXEC bronze.load_bronze;
```

---

## Step 5: Create & Load Silver Layer

Create Silver objects:

```sql
ddl_silver.sql
```

Execute transformation process:

```sql
EXEC silver.load_silver;
```

---

## Step 6: Build Gold Layer

Execute:

```sql
ddl_gold.sql
```

Verify:

- Fact tables
- Dimension tables
- Views
- Relationships

---

## Step 7: Perform Data Validation

Validate:

- Row counts
- Duplicate records
- Null values
- Referential integrity
- Business rules

---

## Step 8: Explore Analytical Data

Run analytical queries against Gold Layer datasets.

---

# 📊 Example Analytical Queries

## 1. Sales Summary

```sql
SELECT
    COUNT(*) AS transaction_count
FROM gold.fact_sales;
```

---

## 2. Sales by Product

```sql
SELECT
    p.product_name,
    SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY
    p.product_name
ORDER BY
    total_sales DESC;
```

---

## 3. Customer-Level Sales

```sql
SELECT
    c.customer_key,
    COUNT(*) AS sales_record_count,
    SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY
    c.customer_key
ORDER BY
    total_sales DESC;
```

---

# ✅ Data Quality and Validation

High-quality data is essential for trustworthy analytics.

| Validation Area | Purpose |
|---------------|---------|
| Completeness | Required fields populated |
| Uniqueness | No duplicate keys |
| Validity | Correct formats and data types |
| Consistency | Consistent representations across systems |
| Referential Integrity | Facts link to valid dimensions |
| Reconciliation | Data consistency across layers |
| Aggregation Accuracy | Measures calculated correctly |

---

# 💡 Key Concepts Demonstrated

- **Data Warehousing**
- **ETL Development**
- **Medallion Architecture**
- **SQL Development**
- **Data Cleansing**
- **Data Integration**
- **Dimensional Modeling**
- **Data Validation**
- **Database Design**

---

🏗️🥉🥈🥇 "Bronze, Silver, Gold — finally, a pipeline where getting promoted doesn't require office politics."

