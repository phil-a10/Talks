USE AdventureWorks2019;

-- Requirement: All employees, rates, joined before 1/1/2010

-- Following naive join returns duplicates:
DBCC FREEPROCCACHE; 
DBCC DROPCLEANBUFFERS; 


SELECT	eph.BusinessEntityID,
		p.FirstName,
		p.LastName,
		eph.RateChangeDate,
		eph.Rate
FROM	[HumanResources].[EmployeeDepartmentHistory] edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID
INNER	JOIN Person.Person p ON edh.BusinessEntityID = p.BusinessEntityID
WHERE	edh.[StartDate] < '20100101'
ORDER BY eph.BusinessEntityID

DBCC FREEPROCCACHE; 
DBCC DROPCLEANBUFFERS; 

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
ORDER BY eph.BusinessEntityID

-- note the memory grant

-- this also removes duplicates - because we've understand how the data works - at a lower cost:

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

SELECT	eph.BusinessEntityID,
		p.FirstName,
		p.LastName,
		eph.RateChangeDate,
		eph.Rate
FROM	(
		SELECT	BusinessEntityID, MIN(StartDate) MinStartDate
		FROM	[HumanResources].[EmployeeDepartmentHistory]
		GROUP BY
				BusinessEntityID
		)edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID 
INNER JOIN Person.Person p ON edh.BusinessEntityID = p.BusinessEntityID
WHERE	edh.[MinStartDate] < '20100101'
ORDER BY eph.BusinessEntityID

SET STATISTICS IO ON

-- BUT! Distinct not always 'bad'

-- Requirement: find employees who started in the last 15 years

SELECT e.[NationalIDNumber]
      ,e.[LoginID]
      ,e.[JobTitle]
      ,e.[BirthDate]
  FROM [HumanResources].[Employee] e
  INNER JOIN [HumanResources].[EmployeeDepartmentHistory] edh ON e.BusinessEntityID = edh.BusinessEntityID
  WHERE StartDate > DATEADD(YEAR, -15, GETDATE() )
  

-- DISTINCT will remove the duplicates - but what is 'missing' from the Query Plan? And why?

SELECT	DISTINCT	e.[NationalIDNumber]
					,e.[LoginID]
					,e.[JobTitle]
					,e.[BirthDate]
FROM [HumanResources].[Employee] e
INNER JOIN [HumanResources].[EmployeeDepartmentHistory] edh ON e.BusinessEntityID = edh.BusinessEntityID
WHERE StartDate > DATEADD(YEAR, -15, GETDATE() )
 