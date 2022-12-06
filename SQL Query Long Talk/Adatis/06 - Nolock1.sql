USE AdventureWorks2019;

--what does nolock actually do?

-- demo:
-- we're using explicit transactions here to slow everything down - but its the same principal when considering any SQL
-- remember: all SQL is transactional


-- what happens when we try to read a table that has an INSERT/UPDATE lock on it?
BEGIN TRAN;

INSERT [Person].[CountryRegion] ([CountryRegionCode], [Name], [ModifiedDate])
VALUES ('ZZ', 'Dummy Region', GETDATE());

COMMIT TRAN;
--ROLLBACK TRAN

DELETE [Person].[CountryRegion] 
WHERE CountryRegionCode = 'ZZ';

BEGIN TRAN;

INSERT [Person].[CountryRegion] ([CountryRegionCode], [Name], [ModifiedDate])
VALUES ('ZZ', 'Dummy Region', GETDATE());

COMMIT TRAN;

DELETE [Person].[CountryRegion] 
WHERE CountryRegionCode = 'ZZ';

BEGIN TRAN;

UPDATE [Person].[CountryRegion]
SET	CountryRegionCode = 'ZZ'
WHERE CountryRegionCode = 'ZM';

ROLLBACK TRAN

--reset:

UPDATE [Person].[CountryRegion]
SET	CountryRegionCode = 'ZM'
WHERE CountryRegionCode = 'ZZ';