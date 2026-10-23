/*
========================================================================
Create Database and Schemas
========================================================================

Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if it already exits.
  If the database exists, it is dropped and created. Additionally, the scripts sets up 3 schemas within the database: 'bronze', 'silver' and 'gold'.

WARNING:
  Running this script will drop the entire 'Datawarehouse' database if it exists.
  All data in the database will be permanenly deleted. Proceed with caution and ensure you have proper backups before running the scripts.
*/


USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER  DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
  
CREATE SCHEMA silver;
GO
  
CREATE SCHEMA gold;
GO
