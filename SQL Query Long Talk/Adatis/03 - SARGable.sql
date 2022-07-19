USE AdventureWorks2019;

--set up
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Production_Product_Name')
DROP INDEX Production.Product.IX_Production_Product_Name
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'AK_Product_Name')
DROP INDEX [AK_Product_Name] ON [Production].[Product]
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Production_Product_NameLastLetter')
DROP INDEX IX_Production_Product_NameLastLetter ON [Production].[Product]
GO

IF EXISTS (	
			SELECT 1
			FROM sys.columns c
			INNER JOIN sys.objects o ON c.object_id = o.object_id
			WHERE	c.name = 'NameLastLetter'
			AND		o.name = 'Product'
			)
ALTER TABLE Production.Product DROP COLUMN NameLastLetter


SET STATISTICS TIME, IO ON;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- find all products that begin with 'S'
SELECT	ProductID, Name
FROM	Production.Product
WHERE	Name LIKE N'S%';

-- Index will be used - makes the query SARGable (Search ARGument able)

CREATE INDEX IX_Production_Product_Name ON Production.Product(Name)

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	ProductID, Name
FROM	Production.Product
WHERE	Name LIKE N'S%';

-- BUT even with an index - it depends on the predicate eg:
SELECT	ProductID, Name
FROM	Production.Product
WHERE	Name LIKE N'%W';

-- so try and find an alternative that is SARGable:
SELECT	ProductID, Name
FROM	Production.Product
WHERE	Name = N'Paint - Yellow';

-- or:
ALTER TABLE Production.Product ADD NameLastLetter AS RIGHT(Name, 1);
CREATE INDEX IX_Production_Product_NameLastLetter ON Production.Product (NameLastLetter) INCLUDE (Name);

SELECT	Name
FROM	Production.Product
WHERE	NameLastLetter = N'W';