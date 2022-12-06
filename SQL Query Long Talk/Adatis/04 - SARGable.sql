USE AdventureWorks2019;

--set up
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Production_Product_Name')
DROP INDEX Production.Product.IX_Production_Product_Name
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'PK_Product_Name')
DROP INDEX [PK_Product_Name] ON [Production].[Product]
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Production_Product_NameLastLetter')
DROP INDEX IX_Production_Product_NameLastLetter ON [Production].[Product]
GO

IF EXISTS (SELECT 1 FROM sys.columns c
			INNER JOIN sys.objects o ON c.object_id = o.object_id
			WHERE c.Name = 'NameLastLetter'
			AND o.name = 'Product')
ALTER TABLE Production.Product DROP COLUMN NameLastLetter
GO
-- end set up

-- find all products that begin with 'S'
SELECT	ProductID, Name
FROM	Production.Product
WHERE	Name LIKE N'S%';

CREATE NONCLUSTERED INDEX IX_Production_Product_Name 
ON Production.Product(Name)

-- what happens when we run:
SELECT	ProductID, Name
FROM	Production.Product
WHERE	Name LIKE N'S%';
-- Index will be used - makes the query SARGable (Search ARGument able)



-- BUT even with an index - it depends on the predicate eg:
SELECT	ProductID, Name
FROM	Production.Product
WHERE	RIGHT(Name, 1) = N'W';

-- so try and find an alternative that is SARGable:
SELECT	ProductID, Name
FROM	Production.Product
WHERE	Name = N'Paint - Yellow';

-- or materialise the data eg for names ending with 'w'

ALTER TABLE Production.Product ADD NameLastLetter AS RIGHT(Name, 1);

SELECT	TOP 100 Name, NameLastLetter
FROM	Production.Product

CREATE INDEX IX_Production_Product_NameLastLetter ON Production.Product (NameLastLetter) INCLUDE (Name);

SELECT	Name
FROM	Production.Product
WHERE	NameLastLetter = N'W';


-- but what happens with the original query?
SELECT	Name
FROM	Production.Product
WHERE	RIGHT(Name, 1) = N'W';







-- still sargeable even with a function!