USE AdventureWorks2019;

-- set-up
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Production_Product_NameLastLetter')
DROP INDEX [Production].[TransactionHistory].[IX_TransactionHistory_ProductID_01]


SET STATISTICS IO, TIME ON;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- find most recent transaction per product
-- one way is to use ranking and chose the product ranked first: 
SELECT ProductID, TransactionDate, TransactionType
FROM
	(
	SELECT	ProductID, TransactionDate, TransactionType,
			RANK() OVER(PARTITION BY ProductID ORDER BY TransactionDate DESC) ProductRank
	FROM	[Production].[TransactionHistory]
	) ProductHistory
WHERE ProductRank = 1



-- this forces a sort and requires a memory grant


-- BUT consider doing this instead:
SELECT th.ProductID, TransactionDate, TransactionType
FROM [Production].[TransactionHistory] th
INNER JOIN 
			(
			SELECT	ProductID,
					MAX(TransactionDate) MaxTransactionDate
			FROM	[Production].[TransactionHistory]
			GROUP BY
					ProductID
			) maxth ON th.ProductID = maxth.ProductID AND th.TransactionDate = maxth.MaxTransactionDate;

-- This can be optimised:

CREATE NONCLUSTERED INDEX [IX_TransactionHistory_ProductID_01]
ON [Production].[TransactionHistory] ([ProductID],[TransactionDate])
INCLUDE (TransactionType)

SELECT ProductID, TransactionDate, TransactionType
FROM
	(
	SELECT	ProductID, TransactionDate, TransactionType,
			RANK() OVER(PARTITION BY ProductID ORDER BY TransactionDate DESC) ProductRank
	FROM	[Production].[TransactionHistory]
	) ProductHistory
WHERE ProductRank = 1;

SELECT th.ProductID, TransactionDate, TransactionType
FROM [Production].[TransactionHistory] th
INNER JOIN 
			(
			SELECT	ProductID,
					MAX(TransactionDate) MaxTransactionDate
			FROM	[Production].[TransactionHistory]
			GROUP BY
					ProductID
			) maxth ON th.ProductID = maxth.ProductID AND th.TransactionDate = maxth.MaxTransactionDate;

