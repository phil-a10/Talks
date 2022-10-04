-- Heaps/Indexing

-- set-up:
USE AdventureWorks2019;

IF EXISTS (SELECT 1 FROM sys.indexes i 
			INNER JOIN sys.objects o ON i.object_id = o.object_id 
			WHERE o.name = 'IX_TransactionHistoryHeap_TransactionDate'
			)
	DROP INDEX [Production].[TransactionHistoryHeap].IX_TransactionHistoryHeap_TransactionDate

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'TransactionHistoryHeap')
DROP TABLE [Production].[TransactionHistoryHeap] 
-- end set-up

SELECT * 
INTO [Production].[TransactionHistoryHeap] 
FROM [Production].[TransactionHistory]


-- A table with no clustered index is known as a heap
-- often this is 'bad' ie inefficient:

SELECT	TransactionID, ProductID, Quantity, ActualCost
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionID = 186237;

SELECT	TransactionID, ProductID, Quantity, ActualCost
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionDate > '20131231';



-- Two types of index can be created:

-- Clustered - often implemented as a PK:
-- Note that for clustered indexes the table is the index and vice-versa
ALTER TABLE [Production].[TransactionHistoryHeap] 
ADD CONSTRAINT PK_TransactionHistoryHeap_TransactionID PRIMARY KEY (TransactionID ASC);
GO

-- this query is much better:
SELECT	TransactionID, ProductID, Quantity, ActualCost
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionID = 186237;

-- But what about this:
SELECT	TransactionID, ProductID, Quantity, ActualCost
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionDate > '20131231';






-- Note that in this query the clustered index is scanned not the table
-- clustered indexes will have linked pages whereas heap tables do not
-- linked pages theoretically make sequential reads faster on large tables but YMMV
-- there are of course other reasons to have a PK on a table

-- Non-clustered indexes
-- You can create a non-clustered index without a clustered index - technically this is still a heap
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PK_TransactionHistoryHeap_TransactionID')
ALTER TABLE [Production].[TransactionHistoryHeap] DROP CONSTRAINT [PK_TransactionHistoryHeap_TransactionID] WITH ( ONLINE = OFF );
GO

CREATE NONCLUSTERED INDEX IX_TransactionHistory_TransactionDate 
	ON [Production].[TransactionHistoryHeap] (TransactionDate ASC)

-- So it should use the Index if we put Date in the predicate right?
SELECT	TransactionID, ProductID, Quantity, ActualCost
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionDate > '20131231';






-- non-clustered indexes only include the specified columns - unlike clustered indexes
-- therefore you need a 'covering' index
-- The index needs to INCLUDE all of the rows asked for by the query:

DROP INDEX [Production].[TransactionHistoryHeap].IX_TransactionHistory_TransactionDate;

CREATE NONCLUSTERED INDEX IX_TransactionHistoryHeap_TransactionDate ON [Production].[TransactionHistoryHeap] (TransactionDate ASC) 
	INCLUDE (TransactionID, ProductID, Quantity, ActualCost)

SELECT	TransactionID, ProductID, Quantity, ActualCost
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionDate > '20131231';

-- So what happens when we add a covering clustered index?
-- PK's do not have to be clustered:
ALTER TABLE [Production].[TransactionHistoryHeap] 
ADD CONSTRAINT PK_TransactionHistoryHeap_TransactionID PRIMARY KEY NONCLUSTERED (TransactionID ASC);

DROP INDEX [Production].[TransactionHistoryHeap].IX_TransactionHistoryHeap_TransactionDate;

-- when creating a clustered index on TransactionDate we don't need the INCLUDE (in fact its not allowed). Why?
CREATE CLUSTERED INDEX IX_TransactionHistoryHeap_TransactionDate 
	ON [Production].[TransactionHistoryHeap] (TransactionDate ASC) ;

SELECT	TransactionID, ProductID, Quantity, ActualCost
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionDate > '20131231';

SELECT	TransactionID, ActualCost, TransactionType
FROM	[Production].[TransactionHistoryHeap]
WHERE	TransactionDate > '20131231';

-- often this sort of indexing pattern is used on fact tables

-- avoid heaps unless you always query all the data in a table
-- indexes do have downsides - updates and inserts