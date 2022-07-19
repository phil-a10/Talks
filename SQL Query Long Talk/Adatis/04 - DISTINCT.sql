USE AdventureWorks2019;

-- Requirement: All employees, departments and rates

-- Following naive join returns duplicates:

SELECT	edh.BusinessEntityID,
		eph.RateChangeDate,
		eph.Rate
FROM	[HumanResources].[EmployeeDepartmentHistory] edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID;

DBCC FREEPROCCACHE; 
DBCC DROPCLEANBUFFERS; 

-- distinct will remove duplicates - but at a cost:
-- as an aside - note how the query is evaluated

SELECT	DISTINCT edh.BusinessEntityID,
		eph.RateChangeDate,
		eph.Rate
FROM	[HumanResources].[EmployeeDepartmentHistory] edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID;

-- this also removes duplicates - because we've understand how the data works - at a much lower cost:

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

SELECT	edh.BusinessEntityID,
		eph.RateChangeDate,
		eph.Rate
FROM	[HumanResources].[EmployeeDepartmentHistory] edh
INNER JOIN [HumanResources].[EmployeePayHistory] eph ON edh.BusinessEntityID = eph.BusinessEntityID 
														AND edh.StartDate <= eph.RateChangeDate 
														AND ISNULL(edh.EndDate, '29990101') > eph.RateChangeDate;

-- BUT! Distinct not always bad

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
 