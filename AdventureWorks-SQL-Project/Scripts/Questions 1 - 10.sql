/* Question 1: Write a SQL Statement that will give you a COUNT of each object type in the AdventureWorks database. 
ORDER BY COUNT DESCENDing. */

		SELECT 
			type,
			type_DESC,
			COUNT(type) AS object_COUNT
		FROM sys.objects
		GROUP BY type, type_DESC
		ORDER BY COUNT(type) DESC

/* Question 2:
a. Write a SQL Statement that will show a COUNT of schemas, tables, and columns (do not include views) in the 
AdventureWorks database.

b. Write a similar statement as part a but list each schema, table, and column (do not include views). 
This table can be used later in the course.*/

		-- a.

		SELECT 
			COUNT(DISTINCT s.name) AS schemaname,
			COUNT(DISTINCT t.name) AS tablename,
			COUNT(c.name) AS columnName
		FROM sys.tables t
		INNER JOIN sys.columns c
		ON c.object_id = t.object_id
		INNER JOIN  sys.schemas s
		ON s.schema_id = t.schema_id

		SELECT 
			COUNT(DISTINCT TABLE_SCHEMA) AS TableSchema,
			COUNT(DISTINCT TABLE_NAME) AS TableName
		FROM INFORMATION_SCHEMA.columns
		WHERE TABLE_NAME NOT IN 
		(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)


		-- b.

		SELECT 
			s.name AS schemaname,
			t.name AS tablename,
			c.name AS columnName
		FROM sys.tables t
		INNER JOIN sys.columns c
		ON c.object_id = t.object_id
		INNER JOIN  sys.schemas s
		ON s.schema_id = t.schema_id

		SELECT 
			TABLE_SCHEMA AS TableSchema,
			TABLE_NAME AS TableName
		FROM INFORMATION_SCHEMA.columns
		WHERE TABLE_NAME NOT IN 
		(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)


/* Question 3: We learned in question 1 that 89 check constraints exist in the AdventureWorks Database. 
In this question we are going to determine what the check constraints are doing while creating a new database and table.

a. Create a new database called "Edited_AdventureWorks" (we are creating another database so we don't 
overwrite or change the AdventureWorks database). THEN write a USE statement to connect to the new database.

b. Using the following tables - sys.check_constraints, sys.tables, and sys.columns to write a query that will 
give you TableName, ColumnName, CheckConstraintName, and CheckConstraintDefinition

c. Create a table named "tbl_CheckConstraint" in the "Edited_AdventureWorks" database with the following 
columns and data types:

	TableName varchar(100)
	ColumnName varchar(100)
	CheckConsraint varchar(250)
	Definition varchar(500)
	ConstraintLevel varchar(100)

d. Using the query in part b insert the data into "tbl_CheckConstraint"

e. Using a CASE statement write an update statement (update ConstraintLevel) that will specify whether the constraint 
is assigned to the column or the table.

f. Once you're done interpreting the results drop the tbl_CheckConstraint table */


		-- a.

		CREATE DATABASE Edited_AdventureWorks
		USE Edited_AdventureWorks

		SELECT * FROM AdventureWorks2019.sys.tables

		-- b.

		SELECT 
		t.name AS TableName,
		c.name AS ColumnName,
		cc.name AS CheckConstraintName,
		cc.definition AS CheckConstraintDefinition
		FROM 
		AdventureWorks2019.sys.check_constraints cc
		INNER JOIN AdventureWorks2019.sys.tables t
		ON t.object_id = cc.parent_object_id  
		LEFT JOIN AdventureWorks2019.sys.columns c
		ON c.column_id = cc.parent_column_id AND
		   c.object_id = cc.parent_object_id


		-- c.

		CREATE TABLE tbl_CheckConstraint
			(Tablename VARCHAR(100),
			ColumnName VARCHAR(100),
			CheckConstraint VARCHAR(250),
			[Definition] VARCHAR(500),
			ConstraintLevel VARCHAR(100)
			)

		SELECT * FROM tbl_CheckConstraint

		--d. 

		INSERT INTO tbl_CheckConstraint
			(Tablename,
			ColumnName,
			CheckConstraint,
			[Definition],
			ConstraintLevel
			)	
		SELECT
			t.name AS TableName,
			c.name AS ColumnName,
			cc.name AS CheckConstraintName,
			cc.definition AS CheckConstraintDefinition,
			NULL AS ConstraintLevel
			FROM 
			AdventureWorks2019.sys.check_constraints cc
			INNER JOIN AdventureWorks2019.sys.tables t
			ON t.object_id = cc.parent_object_id  
			LEFT JOIN AdventureWorks2019.sys.columns c
			ON c.column_id = cc.parent_column_id AND
			   c.object_id = cc.parent_object_id

		-- e.

		UPDATE tbl_CheckConstraint
		SET ConstraintLevel = CASE
								WHEN ColumnName IS NULL THEN 'TableLevel'
								ELSE 'ColumnLevel'
								END

		-- f. 

		DROP TABLE tbl_CheckConstraint 



/* Question 4: We learned in Question 1 that there are 71 tables in the AdventureWorks Database. 
We can also see these tables in  our entity relationship diagram (ERD). These tables are connected via primary keys and 
foreign keys.  

For example, in the Sales.SalesOrderHeader table there  is a foreign key on the CurrencyRateID. 

This Foreign key is connected to the primary key in the Sales.CurrencyRate  table. 

Therefore, WHEN we connect these two tables together we will use the CurrencyRateID FROM both tables. 

The name of this Foreign Key in the AdventureWorks database is  "FK_SalesOrderHeader_CurrencyRate_CurrencyRateID". 
We also  know which Schema, Table, and Column join to the referenced Schema, referenced Table, and referenced column.  

ForeignKeyName: FK_SalesOrderHeader_CurrencyRate_CurrencyRateID

SchemaName: Sales

TableName: SalesOrderHeader

ColumnName: CurrencyRateID

ReferencedSchema: Sales

ReferencedTable: CurrencyRate

ReferencedColumn: CurrencyRateID */

		
		SELECT
		O.name AS FK_Name,
		S1.name AS SchemaName,
		T1.name AS TableName,
		C1.name AS ColumnName,
		S2.name AS ReferencedSchemaName,
		T2.name AS ReferencedTableName,
		C2.name AS ReferencedColumnName		
		FROM sys.foreign_key_columns FKC
		INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id
		INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id
		INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id
		INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
				AND C1.object_id = T1.object_id
		INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
				AND C2.object_id = T2.object_id
		INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id
		INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id


/* Question 5:
a. In this question we are going to put the script written in question 4 into a table. 
To keep the AdventureWorks database clean create a new database called "Edited_AdventureWorks" (if you haven't already)

b. Using a SELECT Into put the script in question 4 into a table named "Table_Relationships" be sure to put this 
table in the Edited_AdventureWorks database. Here is the script FROM question 4:

SELECT 
    O.name as FK_Name
    ,S1.name as SchemaName
    ,T1.name as TableName
    ,C1.name as ColumnName
    ,S2.name as ReferencedSchemaName
    ,T2.name as ReferencedTableName
    ,C2.name as ReferencedColumnName
FROM sys.foreign_key_columns FKC
    INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id
    INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id
    INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id
    INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
		             AND C1.object_id = T1.object_id
    INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
			     AND C2.object_id = T2.object_id
    INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id
    INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id

c. Find the Table in Object Explorer

d. In Question 1 we learned that the AdventureWorks database has 90 foreign key constraints; however, Table_Relationships has 91 rows/relationships. Find the foreign key that has been used twice. What does this mean?

e. How many Distinct Foreign Keys include BusinessEntityID as a column or referenced column? */


		-- a.
		
		CREATE DATABASE Edited_AdventureWorks 
		

		-- b. 

		SELECT 
			O.name AS FK_Name,
			S1.name AS SchemaName,
			T1.name AS TableName,
			C1.name AS ColumnName,
			S2.name AS ReferencedSchemaName,
			T2.name AS ReferencedTableName,
			C2.name AS ReferencedColumnName
		INTO Edited_AdventureWorks.dbo.Table_Relationships
		FROM sys.foreign_key_columns FKC
			INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id
			INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id
			INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id
			INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
					AND C1.object_id = T1.object_id
			INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
					AND C2.object_id = T2.object_id
			INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id
			INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id


		-- d.
			
		SELECT 
			FK_NAME,
			COUNT(*) AS CNT
		FROM Edited_AdventureWorks.dbo.Table_Relationships
		GROUP BY FK_NAME
		ORDER BY 2 DESC


		-- e.
		SELECT 
			COUNT(Distinct FK_Name)
		FROM Edited_AdventureWorks.dbo.Table_Relationships
		WHERE ColumnName = 'BusinessEntityID' or 
		ReferencedColumnName = 'BusinessEntityID'
 
		SELECT 
		*
		FROM Edited_AdventureWorks.dbo.Table_Relationships
		WHERE ColumnName = 'BusinessEntityID' or 
		ReferencedColumnName = 'BusinessEntityID'


/* Question 6:
In Question 1 we learned that the AdventureWorks Database has 152 Default Constraints. 
What tables and columns are these constraints on? And what are the default values? */


		SELECT 
			s.name AS SchemaName,
			t.name AS TableName,
			c.name AS ColumnName,
			dc.name AS DefaultConstraint,
			dc.definition AS DefaultDefinition
		FROM sys.default_constraints dc
		INNER JOIN sys.tables t ON t.object_id = dc.parent_object_id
		INNER JOIN sys.schemas s ON s.schema_id = dc.schema_id
		INNER JOIN sys.columns c ON c.column_id = dc.parent_column_id
		and c.object_id = dc.parent_object_id


/* Question 7
a. Write a script that you can use to find every column in the database that includes "rate" in the column name.

b. Write a script that you can use to find every table in the database that includes "History" in the table name. */


		-- a.

		SELECT 
			t.name AS TableName,
			c.name AS ColumnName
		FROM sys.tables t
		INNER JOIN sys.columns c on t.object_id = c.object_id
		WHERE c.name like '%rate%'

		-- b.
		SELECT 
			t.name AS TableName,
			c.name as ColumnName
		FROM sys.tables t
		INNER JOIN sys.columns c on t.object_id = c.object_id
		WHERE t.name like '%History%'


/* Question 8
In Question 2 we were introduced to the information_schema schema, specifically the information_schema.columns table.

a. Use this table to get a COUNT of each data type in the AdventureWorks Database (include the view tables). 
Which data type is used the most?

b. Using a CASE statement create a data type grouping that summarizes each data type as one of the following Groups:

Character

Numeric

Date

NULL

Use the following columns to create these groups:

Character_Maximum_Length

Numeric_Precision

DateTime_Precision

For example, WHEN the Character_Maximum_Length IS NOT NULL THEN the data type group is "Character." If a row is    
NULL in all three columns THEN put it in the "NULL" group.

THEN give a COUNT of data types in each grouping. The final output will only have two columns - "DataTypeGroup" and 
"DataTypeCNT." Lastly, ORDER BY COUNT DESC. */


		-- a.

		SELECT 
			Data_Type,
			COUNT(*) as DataTypeCNT
		FROM Information_Schema.Columns
		GROUP BY Data_Type
		ORDER BY 2 DESC


		-- b.

		SELECT 
			CASE 
				WHEN Character_Maximum_Length IS NOT NULL THEN 'Character'
				WHEN Numeric_Precision IS NOT NULL THEN 'Numeric'
				WHEN Datetime_Precision IS NOT NULL THEN 'Date'
		ELSE NULL
		END AS 'DataTypeGroup',
		COUNT(*) as CNT
		FROM Information_Schema.Columns
		GROUP BY 
			CASE 
				WHEN Character_Maximum_Length IS NOT NULL THEN 'Character'
			WHEN Numeric_Precision IS NOT NULL THEN 'Numeric'
			WHEN Datetime_Precision IS NOT NULL THEN 'Date'
			ELSE NULL
		 END
		ORDER BY COUNT(*) DESC


		-- c.

		SELECT * FROM Information_Schema.Columns
		WHERE Character_Maximum_Length IS NULL
		AND Numeric_Precision IS NULL
		AND Datetime_Precision IS NULL


/* Question 9:
Question 9
We know FROM Question 1 and using the information_schema.view table that there are 20 views in the AdventureWorks database. 
Each one of these views are created FROM one or more table(s) in the database. 
For Example, "vStateProvinceCOUNTryRegion" is a view that was created FROM multiple columns in the StateProvince and 
COUNTryRegion tables.

Write a script that will show you each view name and the number of tables used to create the view. */


		SELECT View_name, 
		COUNT(Distinct Table_Name) AS TableCNT		
		FROM Information_Schema.View_Column_Usage
		GROUP BY View_name


/* Question 10:
One of the most convenient things about the AdventureWorks database is the column "value" (definitions) found in table 
below.

SELECT * FROM sys.extENDed_properties

a. Write a script that will give you the TableName, ColumnName and each value (definition) WHERE class = 1

b. What is the find the value (definition) for every Column in the Person table */


		-- a.

		SELECT
			t.name AS TableName,
			c.name AS ColumnName,
			ep.value AS 'Definition'
		FROM sys.extENDed_properties ep
		INNER JOIN sys.tables t ON t.object_id = ep.major_id
		INNER JOIN sys.columns c ON c.object_id = ep.major_id
		AND c.column_id = ep.minor_id
		WHERE class = 1

		-- b.

		SELECT 
			t.name AS TableName,
			c.name AS ColumnName,
			ep.value AS 'Definition'
		FROM sys.extENDed_properties ep
		INNER JOIN sys.tables t ON t.object_id = ep.major_id
		INNER JOIN sys.columns c ON c.object_id = ep.major_id
		AND c.column_id = ep.minor_id
		WHERE class = 1
		AND t.name = 'Person'
