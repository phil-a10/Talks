USE AdventureWorks2019;

SET STATISTICS IO, TIME ON;

-- Requirement: All employees, rates, joined before 1/1/2010

-- Following naive join returns duplicates:
DBCC FREEPROCCACHE; 
DBCC DROPCLEANBUFFERS; 


SELECT	eph.BusinessEntityID,
		p.NameStyle,
		p.Title,
		p.FirstName,
		p.MiddleName,
		p.LastName,
		eph.RateChangeDate,
		eph.Rate
FROM	[HumanResources].[EmployeeDepartmentHistory] edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID
INNER JOIN Person.Person p ON edh.BusinessEntityID = p.BusinessEntityID
WHERE	edh.[StartDate] < '20100101'
ORDER BY eph.BusinessEntityID;

-- distinct will remove duplicates - but at a cost - note how the query is evaluated
SELECT	DISTINCT
		eph.BusinessEntityID,
		p.NameStyle,
		p.Title,
		p.FirstName,
		p.MiddleName,
		p.LastName,
		eph.RateChangeDate,
		eph.Rate
FROM	[HumanResources].[EmployeeDepartmentHistory] edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID
INNER	JOIN Person.Person p ON edh.BusinessEntityID = p.BusinessEntityID
WHERE	edh.[StartDate] < '20100101'
ORDER BY eph.BusinessEntityID;

-- note the memory grant

-- this also removes duplicates - because we've understand how the data works - at a lower cost:

SELECT	eph.BusinessEntityID,
		p.NameStyle,
		p.Title,
		p.FirstName,
		p.MiddleName,
		p.LastName,
		eph.RateChangeDate,
		eph.Rate
FROM	(
		-- in this case we're only interested in when people started therefore:
		SELECT	BusinessEntityID, MIN(StartDate) MinStartDate
		FROM	[HumanResources].[EmployeeDepartmentHistory]
		GROUP BY
				BusinessEntityID
		)edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID 
INNER JOIN Person.Person p ON edh.BusinessEntityID = p.BusinessEntityID
WHERE	edh.[MinStartDate] < '20100101'
ORDER BY eph.BusinessEntityID



-- BUT! Distinct not always 'bad'

-- Requirement: find employees who started in the last 15 years

-- DISTINCT will remove the duplicates - but what is 'missing' from the Query Plan? And why?

SELECT	DISTINCT	e.[NationalIDNumber]
					,e.[LoginID]
					,e.[JobTitle]
					,e.[BirthDate]
FROM [HumanResources].[Employee] e
INNER JOIN [HumanResources].[EmployeeDepartmentHistory] edh ON e.BusinessEntityID = edh.BusinessEntityID
WHERE StartDate > DATEADD(YEAR, -15, GETDATE() )







-- HumanResources.Employee has a clustered index - so doesn't need a Distinct Sort operator
-- Also we are de-duping only columns from one table