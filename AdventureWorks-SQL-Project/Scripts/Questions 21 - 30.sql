/* Question 21:
AdventureWorks works with customers, employees and business partners all over the globe. 
The accounting department needs to be sure they are up-to-date on Country and State tax rates.

a. Pull a list of every country and state in the database.

b. Includes tax rates.

c. There are 181 rows when looking at countries and states, but once you add tax rates the number of rows increases to 184. Why is this?

d. Which location has the highest tax rate? */


		-- a.

		SELECT 
			c.Name AS Country,
			s.Name AS State
		FROM person.CountryRegion c
		INNER JOIN Person.StateProvince s
		ON c.CountryRegionCode = s.CountryRegionCode

		-- b.
		
		SELECT 
			c.Name AS Country,
			s.Name AS State,
			t.TaxRate AS TaxRate
		FROM person.CountryRegion c
		INNER JOIN Person.StateProvince s
		ON c.CountryRegionCode = s.CountryRegionCode
		LEFT JOIN Sales.SalesTaxRate t
		ON s.StateProvinceID = t.StateProvinceID

		-- c.
		
		SELECT * FROM Sales.SalesTaxRate
		WHERE StateProvinceID IN 
				(SELECT 
					s.StateProvinceID
				FROM person.CountryRegion c
					INNER JOIN Person.StateProvince s
					ON c.CountryRegionCode = s.CountryRegionCode
					LEFT JOIN Sales.SalesTaxRate t
					ON s.StateProvinceID = t.StateProvinceID
				GROUP BY s.StateProvinceID
				HAVING COUNT(*) > 1) 

		-- d.

		SELECT 
			TOP 1
			c.Name AS Country,
			s.Name AS State,
			t.TaxRate AS TaxRate
		FROM person.CountryRegion c
		INNER JOIN Person.StateProvince s
		ON c.CountryRegionCode = s.CountryRegionCode
		LEFT JOIN Sales.SalesTaxRate t
		ON s.StateProvinceID = t.StateProvinceID
		ORDER BY t.TaxRate DESC


/* Question 22:
The Marketing Department has never ran ads in the United Kingdom and would like you pull a list of every individual 
customer (PersonType = IN) by country.

a. How many individual (retail) customers exist in the person table?

b. Show this breakdown by country. */


		-- a.

		SELECT 
			COUNT(DISTINCT BusinessEntityID) AS Count
		FROM Person.Person
		WHERE PersonType = 'IN'

		-- b.

		SELECT 
			c.Name,
			FORMAT(COUNT(DISTINCT p.BusinessEntityID), 'N0') AS Count
		FROM Person.Person p
			INNER JOIN Person.BusinessEntityAddress bea
			ON p.BusinessEntityID = bea.BusinessEntityID
			INNER JOIN Person.Address a
			ON bea.AddressID = a.AddressID
			INNER JOIN person.StateProvince sp
			ON a.StateProvinceID = sp.StateProvinceID
			INNER JOIN Person.CountryRegion c
			ON sp.CountryRegionCode = c.CountryRegionCode
		WHERE PersonType = 'IN'
		GROUP BY c.Name
		ORDER BY 2 DESC


/* QUestion 23:
What percent of total customers reside in each country. For Example,  if there are 1000 total customers 
and 200 live in the United States then 20% of the customers live in the United States. */


		-- Declaring variable
		DECLARE @TotalRetailCustomers FLOAT;
	
		-- Calculate total customers
		SELECT
		@TotalRetailCustomers = COUNT(BusinessEntityID) FROM person.Person WHERE PersonType = 'IN'

		SELECT 
			c.Name,
			FORMAT(CAST(COUNT(DISTINCT p.BusinessEntityID) AS FLOAT) / @TotalRetailCustomers, 'P') AS PercentOfTotal
		FROM Person.Person p
			INNER JOIN Person.BusinessEntityAddress bea
			ON p.BusinessEntityID = bea.BusinessEntityID
			INNER JOIN Person.Address a
			ON bea.AddressID = a.AddressID
			INNER JOIN person.StateProvince sp
			ON a.StateProvinceID = sp.StateProvinceID
			INNER JOIN Person.CountryRegion c
			ON sp.CountryRegionCode = c.CountryRegionCode
		WHERE PersonType = 'IN'
		GROUP BY c.Name
		ORDER BY 1 DESC


/* Question 24:
In this question use SalesOrderID '69411' to determine answer.

a. In the SalesOrderHeader what is the difference between "SubTotal" and "TotalDue"?

b. Which one of these matches the "LineTotal" in the SalesOrderDetail?

c. How is TotalDue calculated in SalesOrderHeader?

d. How is LineTotal calculated in SalesOrderDetail? */


		-- a. 

		SELECT 
			FORMAT(SUM(SubTotal), 'C0') AS SubTotal,
			FORMAT(SUM(TotalDue), 'C0') AS TotalDue,
			FORMAT(SUM(TotalDue) - SUM(SubTotal), 'C0') AS Variance
		FROM Sales.SalesOrderHeader
		WHERE SalesOrderID = 69411

		-- b.

		SELECT 
			FORMAT(SUM(LineTotal), 'C0') AS LineTotal
		FROM Sales.SalesOrderDetail
		WHERE SalesOrderID = 69411	
		-- LineTotal = SubTotal = $3,793

		-- c.

		SELECT
			FORMAT(SUM(TotalDue), 'C0') AS TotalDue,
			FORMAT(SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight), 'C0') AS TotalDueCheck
		FROM Sales.SalesOrderHeader
		WHERE SalesOrderID = 69411

		-- d.

		SELECT
			FORMAT(SUM(LineTotal), 'C0') AS LineTotal,
			FORMAT(SUM((UnitPrice * (1- UnitPriceDiscount) *OrderQty)), 'C0') AS LineTotalCheck
		FROM Sales.SalesOrderDetail
		WHERE SalesOrderID = 69411


/* Question 25:
In general Gross Revenue is calculated by taking the Amount of Sales/Revenue without removing the expenses to sell 
that item. Which also means that in general Net Revenue is the Amount of Sales/Revenue after the expenses have been 
subtracted.

Which product has the best margins? (Highest Net Revenue) */


		SELECT 
		Name,
			FORMAT(ListPrice, 'C0') AS ListPrice, 
			FORMAT(StandardCost,'C0') AS StandardCost,
			FORMAT((ListPrice - StandardCost),'C0') AS Margin
		FROM Production.Product
		ORDER BY (ListPrice - StandardCost) DESC


/* Question 26:
As we learned in Question 25, the "Mountain-100 Silver" and the "Mountain-100 Black" bicycles have the 
highest margins... meaning the ListPrice to StandardCost ratio is higher than any other product.

a. Within the Production.Product table find a identifier that groups the 8 "Mountain-100" bicycles (4 Silver and 4 Black).

b. How many special offers have been applied to these 8 bicycles? When did the special offer start? When did the    
special offer end? What was the special offer?

c. Based on the most recent special offer start date is the product actually discontinued? Or Is the product still sold?

d. When was the last date the product was sold to an actual customer? */


		-- a.
		SELECT 
		*
		FROM Production.Product p
		WHERE p.name LIKE 'Mountain-100%'

		SELECT 
		*
		FROM Production.Product p
		WHERE ProductModelID = 19

		-- b.

		SELECT
			so.StartDate,
			so.EndDate,
			so.Type,
			so.Category,
			so.Description,
			so.DiscountPct,
			COUNT(DISTINCT p.Name) AS Count
		FROM Production.Product p
		LEFT JOIN Sales.SpecialOfferProduct sop
		ON p.ProductID = sop.ProductID
		LEFT JOIN Sales.SpecialOffer so
		ON sop.SpecialOfferID = so.SpecialOfferID
		WHERE p.ProductModelID = 19
		GROUP BY
			so.StartDate,
			so.EndDate,
			so.Type,
			so.Category,
			so.Description,
			so.DiscountPct
		
		-- c.

		SELECT
			SellStartDate,
			SellEndDate,
			DiscontinuedDate
		FROM Production.Product
		WHERE ProductModelID = 19

		-- d.

		SELECT 
			MIN(OrderDate) AS FirstDate,
			MAX(OrderDate) AS MostRecentDate
		FROM 
		Sales.SalesOrderHeader soh
		INNER JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		INNER JOIN Production.Product p
		ON sod.ProductID = p.ProductID
		WHERE ProductModelID = 19


/* Question 27:
Question 27
We learned in Question 26 that the 8 bicycles that fall under the 19 ProductModelID don't have a discontinued  date. 
However, this model hasn't been ordered since  May 29, 2012. The most recent purchase (any item) was June 30, 2014. 
Which means this product either has been discounted and there isn't a discontinued date. Or the product is still being 
sold, but hasn't been purchased in 2 years. Which is it? */


		SELECT
			p.Name,
			SUM(i.quantity) AS Inventory
		FROM Production.Product p
		INNER JOIN Production.ProductInventory i
		ON p.ProductID = i.ProductID
		WHERE ProductModelID = 19
		GROUP BY p.Name


/* Question 28
a. Using Sales.SalesReason pull a distinct list of every sales reason.

b. Add a count of SalesOrderID's to the sales reason.

c. Which Sales Reason is most common? */


		-- a.

		SELECT DISTINCT(ReasonType) 
		FROM Sales.SalesReason

		-- b.

		SELECT 
			sr.Name,
			FORMAT(COUNT(SalesOrderID), 'N0') AS Count
			FROM Sales.SalesReason sr
		INNER JOIN Sales.SalesOrderHeaderSalesReason hsr
		ON sr.SalesReasonID = hsr.SalesReasonID
		GROUP BY sr.Name

		-- c.

		SELECT TOP 1
			sr.Name,
			FORMAT(COUNT(SalesOrderID), 'N0') AS Count
		FROM Sales.SalesReason sr
		INNER JOIN Sales.SalesOrderHeaderSalesReason hsr
		ON sr.SalesReasonID = hsr.SalesReasonID
		GROUP BY sr.Name
		ORDER BY COUNT(SalesOrderID) DESC


/* Question 29:
Based on the results in question 28, there are 27,647 rows in the SalesOrderHeaderSalesReason table. 
Which means these 27,647 are assigned to a SalesReason. However, there are 31,465 unique SalesOrderIDs in the 
SalesOrderHeader table. This is due to the fact that a SalesOrder can have zero, one, or multiple sales reasons listed. 
For Example, SalesOrderID 44044 has "Manufacturer" and "Quality" listed as reasons why the customer purchased. 
The most reasons listed for a single SalesOrderID is 3.

Using a CTE (Common Table Expression) find the number of SalesOrderIDs that have zero, one, two, and 
three sales reasons. */


		WITH CTE_Sales AS (
				SELECT 
					soh.SalesOrderID,
					COUNT(hsr.SalesOrderID) AS CNT
				FROM Sales.SalesOrderHeader soh
				LEFT JOIN Sales.SalesOrderHeaderSalesReason hsr
				ON soh.SalesOrderID = hsr.SalesOrderID
				LEFT JOIN Sales.SalesReason sr
				ON sr.SalesReasonID = hsr.SalesReasonID
				GROUP BY soh.SalesOrderID
			)

		SELECT 
		CNT,
		COUNT(CNT) AS CountOfSalesOrderIDs
		FROM CTE_Sales
		GROUP BY CNT
		ORDER BY 2 DESC


/* Question 30:
Assume the sales team wants to reach out to folks who left a review (ProductReview). 
Is it possible to find the customers that left a review in the Person table? */


		SELECT * FROM Production.ProductReview

		SELECT 
			pr.*
			,p.Name
		FROM Production.ProductReview pr
		INNER JOIN Production.Product p ON p.ProductID = pr.ProductID

		SELECT * FROM Person.EmailAddress
		WHERE EmailAddress IN (
								SELECT 
								EmailAddress
								FROM Production.ProductReview pr
							  )

		SELECT * 
		FROM Sales.SalesOrderHeader soh
		INNER JOIN Person.Person p ON p.BusinessEntityID = soh.CustomerID
		INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
		INNER JOIN Production.Product pr ON pr.ProductID = sod.ProductID
		WHERE FirstName LIKE '%John%' AND LastName LIKE '%Smith%'

		SELECT * 
		FROM HumanResources.Employee
		INNER JOIN Person.Person ON Person.BusinessEntityID = Employee.BusinessEntityID
		WHERE FirstName LIKE '%Laura%' AND LastName LIKE '%Norman%'



-- Query for checking table details:


	
		SELECT 
		t.name AS TableName,
		c.name AS ColumnName,
		ep.value AS Definitions
		FROM sys.extended_properties ep
		INNER JOIN sys.tables t
		ON t.object_id = ep.major_id
		INNER JOIN sys.columns c
		ON c.object_id = ep.major_id AND c.column_id = ep.minor_id
		WHERE class = 1 AND t.name IN ('Product')
