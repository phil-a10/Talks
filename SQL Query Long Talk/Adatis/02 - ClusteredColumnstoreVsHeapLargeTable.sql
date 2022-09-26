
USE StackOverflow2013;

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Comments_CCIX')
DROP TABLE dbo.Comments_CCIX;
GO

-- create a table to add a CCI to
CREATE TABLE dbo.Comments_CCIX
(
Id INT IDENTITY(1,1) NOT NULL,
CreationDate datetime NOT NULL,
PostId int NOT NULL,
Score int NOT NULL,
Text nvarchar(700) NOT NULL,
UserId INT NULL
);

INSERT dbo.Comments_CCIX (CreationDate, PostId, Score, Text, UserId)
SELECT CreationDate, PostId, Score, Text, UserId
FROM dbo.Comments;

-- Columnstore indexes introduced in SQL 2012
-- Became updateable in 2014
-- as the name suggests it utilises column-based storage to compress data
-- More on CCI here: https://www.nikoport.com/columnstore/
-- This is automatically done in Synapse dedicated SQL pools


-- table isn't huge pre-CCI - only about 8GB
EXEC sp_spaceused 'Comments_CCIX'

-- add the CCI (about 30s)
CREATE CLUSTERED COLUMNSTORE INDEX CCIX_Comments_CCIX_Id ON dbo.Comments_CCIX; --note that there are no columns listed this clustered index includes the whole table

-- CCI compresses the data:
EXEC sp_spaceused 'Comments_CCIX'

-- how much faster?

SET STATISTICS IO, TIME ON;

-- lets level the playing field
-- don't run these on production systems!
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	COUNT(*)
FROM dbo.Comments_Heap ch

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- a lot!

SELECT	COUNT(*)
FROM dbo.Comments_CCIX ch

-- how? check the query plan
-- in this case CCI also benefits from column elimination and aggregate pushdown

-- note that the CCI takes 30s to create so there's no benefit to creating it immediately before the query - as you 'only' save 12s
-- however this isn't always the case

-- note that its faster even if only one table in the query has a CCI:
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	UserId, 		
		COUNT(*)
FROM dbo.Comments_Heap ch
INNER JOIN dbo.Users u ON ch.UserId = u.Id -- not in a CCI
GROUP BY
		UserId;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	UserId, 		
		COUNT(*)
FROM dbo.Comments_CCIX ch
INNER JOIN dbo.Users u ON ch.UserId = u.Id
GROUP BY
		UserId;

-- note that CCI not always a magic bullet - but used sparingly can really improve performance