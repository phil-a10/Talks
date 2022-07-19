USE AdventureWorks2019;

SELECT	[CountryRegionCode], [Name], [ModifiedDate]
FROM	Person.CountryRegion
WHERE	ModifiedDate > '20010101'

--dirty read ie uncommitted data but it doesn't get blocked by INSERT
SELECT	[CountryRegionCode], [Name], [ModifiedDate]
FROM	Person.CountryRegion (nolock) 
WHERE	ModifiedDate > '20010101'

--this dirty read finds the ZZ country code - but does it actually exist!
SELECT	[CountryRegionCode], [Name], [ModifiedDate]
FROM	Person.CountryRegion (nolock) 
WHERE	CountryRegionCode = 'ZZ'

--after the transaction fails/rolls back - there is no indication CountryRegionCode ever existed!
SELECT	[CountryRegionCode], [Name], [ModifiedDate]
FROM	Person.CountryRegion 
WHERE	CountryRegionCode = 'ZM'

