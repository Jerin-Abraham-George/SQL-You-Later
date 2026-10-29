/* Question 11:

a. How many employees exist in the Database?

b. How many of these employees are active employees?

c. How many Job Titles equal the 'SP' Person type?

d. How many of these employees are sales people? */

		-- a.

		SELECT
			COUNT(*) AS EmpCount,
			COUNT(DISTINCT BusinessEntityID) AS EmpCount2,
			COUNT(DISTINCT NationalIDNumber) AS EmpCount3
		FROM HumanResources.Employee

		-- b.

		SELECT
		CurrentFlag,
		COUNT(*) AS EmployeeCount
		FROM HumanResources.Employee
		GROUP BY CurrentFlag

		-- c.

		SELECT
			COUNT(DISTINCT JobTitle) AS EmployeeCount
		FROM HumanResources.Employee e
			INNER JOIN Person.Person p
			ON e.BusinessEntityID = p.BusinessEntityID
		WHERE p.PersonType = 'SP'
	
		-- d.

		SELECT
		JobTitle,
		COUNT(DISTINCT e.BusinessEntityID) AS SPCount
		FROM HumanResources.Employee e
		INNER JOIN Person.Person p
		ON e.BusinessEntityID = p.BusinessEntityID
		WHERE p.PersonType = 'SP'
		GROUP BY JobTitle

/* Question 12:
a. What is the name of the CEO? Concatenate first and last name.

b. When did this person start working for AdventureWorks

c. Who reports to the CEO? Includes their names and title */

		-- a.

		SELECT 
		e.JobTitle,
		CONCAT(p.FirstName, ' ', p.LastName) AS FullName
		FROM
		HumanResources.Employee e
		INNER JOIN Person.Person p
		ON e.BusinessEntityID = p.BusinessEntityID
		WHERE e.JobTitle = 'Chief Executive Officer'

		-- b. 

		SELECT
		e.JobTitle,
		e.HireDate,
		CONCAT(p.FirstName, ' ', p.LastName) AS FullName
		FROM
		HumanResources.Employee e
		INNER JOIN Person.Person p
		ON e.BusinessEntityID = p.BusinessEntityID
		WHERE e.JobTitle = 'Chief Executive Officer'

		-- c.

		SELECT
		CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
		e.JobTitle
		FROM
		HumanResources.Employee e
		INNER JOIN Person.Person p
		ON e.BusinessEntityID = p.BusinessEntityID
		WHERE e.OrganizationLevel = 1


/* Question 13:
a. What is the job title for John Evans

b. What department does John Evans work in? */

		-- a.

		SELECT
		e.JobTitle,
		CONCAT(p.FirstName, ' ', p.LastName) AS FullName
		FROM
		HumanResources.Employee e
		INNER JOIN Person.Person p
		ON e.BusinessEntityID = p.BusinessEntityID
		WHERE CONCAT(p.FirstName, ' ', p.LastName) = 'John Evans'

		-- b.

		SELECT
		e.JobTitle,
		CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
		dh.DepartmentID,
		d.Name AS Department
		FROM
		HumanResources.Employee e
		INNER JOIN Person.Person p
		ON e.BusinessEntityID = p.BusinessEntityID
		INNER JOIN HumanResources.EmployeeDepartmentHistory dh
		ON e.BusinessEntityID = dh.BusinessEntityID
		INNER JOIN HumanResources.Department d
		ON dh.DepartmentID = d.DepartmentID
		WHERE CONCAT(p.FirstName, ' ', p.LastName) = 'John Evans'


/* Question 14:
a. Which Purchasing vendors have the highest credit rating?

b. Using a case statement replace the 1 and 0 in Vendor.PreferredVendorStatus to "Preferred" vs "Not Preferred."   
How many vendors are considered Preferred?

c. For Active Vendors only, do Preferred vendors have a High or lower average credit rating?

d. How many vendors are active and Not Preferred? */


		-- a.

		SELECT *
		FROM
		(
			SELECT 
			Name,
			RANK() OVER(ORDER BY CreditRating ASC) AS HighestRank
			FROM Purchasing.Vendor
		) t
		WHERE HighestRank = 1

		-- b.

		SELECT 
		CASE
			WHEN PreferredVendorStatus = 1 THEN 'Preferred'
			WHEN PreferredVendorStatus = 0 THEN 'Not Preferred'
		END AS PreferredVendorStatus,
		COUNT(DISTINCT BusinessEntityID) AS TotalVendors
		FROM Purchasing.Vendor
		GROUP BY 
				CASE
				WHEN PreferredVendorStatus = 1 THEN 'Preferred'
				WHEN PreferredVendorStatus = 0 THEN 'Not Preferred'
				END

		-- c. 

		SELECT 
		CASE
			WHEN PreferredVendorStatus = 1 THEN 'Preferred'
			WHEN PreferredVendorStatus = 0 THEN 'Not Preferred'
		END AS PreferredVendorStatus,
		AVG(CAST(CreditRating AS DECIMAL)) AS AvgRating
		FROM Purchasing.Vendor
		WHERE ActiveFlag = 1
		GROUP BY 
				CASE
				WHEN PreferredVendorStatus = 1 THEN 'Preferred'
				WHEN PreferredVendorStatus = 0 THEN 'Not Preferred'
				END

		-- d.

		SELECT COUNT(DISTINCT BusinessEntityID) AS Count
		FROM Purchasing.Vendor
		WHERE ActiveFlag = 1 AND PreferredVendorStatus = 0


/* Question 15:
Assume today is August 15, 2014.

a. Calculate the age for every current employee. What is the age of the oldest employee?

b. What is the average age by Organization level? Show answer with a single decimal

c. Use the ceiling function to round up

d. Use the floor function to round down */


		-- a.

		SELECT
		CONCAT(p.FirstName, ' ' , p.MiddleName, ' ' , p.LastName) AS FullName,
		DATEDIFF(YEAR, e.BirthDate, '2014-08-15') AS Age
		FROM
		HumanResources.Employee e
		INNER JOIN Person.Person p
		ON e.BusinessEntityID = p.BusinessEntityID
		ORDER BY 2 DESC
		
		-- b.

		SELECT
		OrganizationLevel,
		FORMAT(AVG(CAST(DATEDIFF(YEAR, BirthDate, '2024-08-15') AS DECIMAL)), 'N1') AS Age
		FROM HumanResources.Employee
		GROUP BY OrganizationLevel
		ORDER BY 2 DESC

		-- c.

		SELECT
		OrganizationLevel,
		CEILING(AVG(CAST(DATEDIFF(YEAR, BirthDate, '2024-08-15') AS DECIMAL))) AS Age
		FROM HumanResources.Employee
		GROUP BY OrganizationLevel
		ORDER BY 2 DESC

		-- d.

		SELECT
		OrganizationLevel,
		FLOOR(AVG(CAST(DATEDIFF(YEAR, BirthDate, '2024-08-15') AS DECIMAL))) AS Age
		FROM HumanResources.Employee
		GROUP BY OrganizationLevel
		ORDER BY 2 DESC


/* Question 16:
a. How many products are sold by AdventureWorks?

b. How many of these products are actively being sold by AdventureWorks?

c. How many of these active products are made in house vs. purchased? */


		-- a.

		SELECT 
		COUNT(*) AS ProductsCount
		FROM Production.Product
		WHERE FinishedGoodsFlag = 1

		-- b.

		SELECT 
		COUNT(*) AS ProductsCount
		FROM Production.Product
		WHERE FinishedGoodsFlag = 1 AND SellEndDate IS NULL

		-- c.
		
		SELECT 
		CASE 
			WHEN MakeFlag = 1 THEN 'In-house'
			ELSE 'Purchased'
		END AS [In-house/Purchased],
		COUNT(*) AS ProductsCount
		FROM Production.Product
		WHERE FinishedGoodsFlag = 1 AND SellEndDate IS NULL
		GROUP BY CASE 
				 WHEN MakeFlag = 1 THEN 'In-house'
				 ELSE 'Purchased'
				 END


/* Question 17:
We learned in Question 16 that the product table includes a few different type of products - i.e., manufactured vs. 
purchased.

a. Sum the LineTotal in SalesOrderDetail. Format as currency

b. Sum the LineTotal in SalesOrderDetail by the MakeFlag in the product table. Use a case statement to specify 
manufactured vs. purchased. Format as currency.

c. Add a count of distinct SalesOrderIDs

d. What is the average LineTotal per SalesOrderID? */


		-- a.

		SELECT
		FORMAT(SUM(LineTotal), 'C', 'en-US') AS LineTotal
		FROM Sales.SalesOrderDetail

		-- b.

		SELECT
		CASE
			WHEN MakeFlag = 1 THEN 'Manufactured'
			WHEN MakeFlag = 0 THEN 'Purchased'
		END AS MakeFlag,
		FORMAT(SUM(LineTotal), 'C', 'en-US') AS LineTotal
		FROM Sales.SalesOrderDetail s
		INNER JOIN Production.Product p
		ON s.ProductID = P.ProductID
		GROUP BY MakeFlag

		-- c.

		SELECT
		CASE
			WHEN MakeFlag = 1 THEN 'Manufactured'
			WHEN MakeFlag = 0 THEN 'Purchased'
		END AS MakeFlag,
		FORMAT(SUM(LineTotal), 'C', 'en-US') AS LineTotal,
		COUNT(DISTINCT SalesOrderID) AS SalesOrderIDCount
		FROM Sales.SalesOrderDetail s
		INNER JOIN Production.Product p
		ON s.ProductID = P.ProductID
		GROUP BY MakeFlag

		-- d.


		SELECT
		CASE
			WHEN MakeFlag = 1 THEN 'Manufactured'
			WHEN MakeFlag = 0 THEN 'Purchased'
		END AS MakeFlag,
		FORMAT(SUM(LineTotal), 'C0', 'en-US') AS LineTotal,
		FORMAT(COUNT(DISTINCT SalesOrderID), 'N0') AS SalesOrderIDCount,
		FORMAT(SUM(LineTotal) / COUNT(DISTINCT SalesOrderID), 'C0', 'en-US') AvgLineTotal
		FROM Sales.SalesOrderDetail s
		INNER JOIN Production.Product p
		ON s.ProductID = P.ProductID
		GROUP BY MakeFlag


/*Question 18:
The AdventureWorks Cyclery database includes historical and present transactions.

a. In the TransactionHistory and TransactionHistoryArchive tables a "W","S", and "P" are used as Transaction types.    
What do these abbreviations mean?

b. Union TransactionHistory and TransactionHistoryArchive

c. Find the First and Last TransactionDate in the TransactionHistory and TransactionHistoryArchive tables. 
Use the union written in part b. The current data type for TransactionDate is datetime. 
Convert or Cast the data type to date.

d. Find the First and Last Date for each transaction type. Use a case statement to specify the transaction types.*/


		-- a.

		SELECT DISTINCT TransactionType,
		CASE 
			WHEN TransactionType = 'W' THEN 'Work Order'
			WHEN TransactionType = 'S' THEN 'Sales Order'
			WHEN TransactionType = 'P' THEN 'Purchase Order'
		END TransactionTypeDesc
		FROM Production.TransactionHistory

		-- b.

		SELECT 
		'TransactionHistory' AS TableName,
		* FROM Production.TransactionHistory
		UNION 
		SELECT
		'TransactionHistoryArchive' AS TableName,
		* FROM Production.TransactionHistoryArchive

		-- c.

		SELECT 
		CAST(MIN(t.TransactionDate) AS DATE) FirstTransactionDate,
		CAST(MAX(t.TransactionDate) AS DATE) LastTransactionDate
		FROM 
			(SELECT 
			'TransactionHistory' AS TableName,
			* FROM Production.TransactionHistory
			UNION 
			SELECT
			'TransactionHistoryArchive' AS TableName,
			* FROM Production.TransactionHistoryArchive) t

		-- d.

		SELECT
		CASE 
			WHEN TransactionType = 'W' THEN 'Work Order'
			WHEN TransactionType = 'S' THEN 'Sales Order'
			WHEN TransactionType = 'P' THEN 'Purchase Order'
			ELSE NULL
		END AS TransactionType,
		CAST(MIN(t.TransactionDate) AS DATE) FirstTransactionDate,
		CAST(MAX(t.TransactionDate) AS DATE) LastTransactionDate
		FROM 
			(SELECT 
			'TransactionHistory' AS TableName,
			* FROM Production.TransactionHistory
			UNION 
			SELECT
			'TransactionHistoryArchive' AS TableName,
			* FROM Production.TransactionHistoryArchive) t
		GROUP BY TransactionType



/* Question 19:
We learned in Question 18 that the most recent SalesOrder transaction occurred on 2014-06-30 and the First Sales Order 
transaction occurred on 2011-05-31. Does the SalesOrderHeader table show a similar Order date for the first 
and Last Sale? Format as Date */


		SELECT 
			CAST(MIN(OrderDate) AS DATE) AS FirstDate,
			CAST(MAX(OrderDate) AS DATE) AS LastDate
		FROM Sales.SalesOrderHeader;

		SELECT
		CASE 
			WHEN TransactionType = 'W' THEN 'Work Order'
			WHEN TransactionType = 'S' THEN 'Sales Order'
			WHEN TransactionType = 'P' THEN 'Purchase Order'
			ELSE NULL
		END AS TransactionType,
		CAST(MIN(t.TransactionDate) AS DATE) FirstTransactionDate,
		CAST(MAX(t.TransactionDate) AS DATE) LastTransactionDate
		FROM 
			(SELECT 
			'TransactionHistory' AS TableName,
			* FROM Production.TransactionHistory
			UNION 
			SELECT
			'TransactionHistoryArchive' AS TableName,
			* FROM Production.TransactionHistoryArchive) t
		GROUP BY TransactionType


/* Question 20:
We learned in Question 19 that the first and most recent OrderDate in the SalesOrderHeader table matches the 
Sales Order Dates in the transactionHistory table (Question 18).

a. Find the other tables and dates that should match the WorkOrder and PurchaseOrder Dates. 
Format these dates as a date in the YYYY-MM-DD format.

b. Do the dates match? Why/Why not? */


		SELECT 
		status,
		CAST(MIN(OrderDate) AS DATE) AS FirstOrderDate,
		CAST(MAX(OrderDate) AS DATE) AS LastOrderDate
		FROM Purchasing.PurchaseOrderHeader
		GROUP BY status
		ORDER BY status ASC

		SELECT 
		CAST(MIN(DueDate) AS DATE) AS FirstOrderDate,
		CAST(MAX(DueDate) AS DATE) AS LastOrderDate,
		CAST(MIN(StartDate) AS DATE) AS FirstOrderDate,
		CAST(MAX(StartDate) AS DATE) AS LastOrderDate,
		CAST(MIN(EndDate) AS DATE) AS FirstOrderDate,
		CAST(MAX(EndDate) AS DATE) AS LastOrderDate
		FROM Production.WorkOrder


-- Query for checking table details:

/* 
	
	SELECT 
	t.name AS TableName,
	c.name AS ColumnName,
	ep.value AS Definitions
FROM sys.extended_properties ep
INNER JOIN sys.tables t
ON t.object_id = ep.major_id
INNER JOIN sys.columns c
ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
WHERE class = 1 AND t.name IN ('TransactionHistory')

*/
