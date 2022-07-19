USE AdventureWorks2019;

-- set-up
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Production_Product_NameLastLetter')
DROP INDEX [IX_TransactionHistory_ProductID_01]


SET STATISTICS IO, TIME ON;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- find last transaction per product
-- one way is to use ranking and chose the product ranked first: 
SELECT ProductID, TransactionDate
FROM
	(
	SELECT	ProductID, TransactionDate,
			RANK() OVER(PARTITION BY ProductID ORDER BY TransactionDate DESC) ProductRank
	FROM	[Production].[TransactionHistory]
	) ProductHistory
WHERE ProductRank = 1

-- BUT consider doing this instead:
SELECT th.ProductID, TransactionDate
FROM [Production].[TransactionHistory] th
INNER JOIN 
			(
			SELECT	ProductID,
					MAX(TransactionDate) MaxTransactionDate
			FROM	[Production].[TransactionHistory]
			GROUP BY
					ProductID
			) maxth ON th.ProductID = maxth.ProductID AND th.TransactionDate = maxth.MaxTransactionDate;

-- Note that the second does not force a sort
-- Later versions of SQL are better at optimising windowing functions

-- The second can also be optimised:

CREATE NONCLUSTERED INDEX [IX_TransactionHistory_ProductID_01]
ON [Production].[TransactionHistory] ([ProductID],[TransactionDate])

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT ProductID, TransactionDate
FROM
	(
	SELECT	ProductID, TransactionDate,
			RANK() OVER(PARTITION BY ProductID ORDER BY TransactionDate DESC) ProductRank
	FROM	[Production].[TransactionHistory]
	) ProductHistory
WHERE ProductRank = 1;

SELECT th.ProductID, TransactionDate
FROM [Production].[TransactionHistory] th
INNER JOIN 
			(
			SELECT	ProductID,
					MAX(TransactionDate) MaxTransactionDate
			FROM	[Production].[TransactionHistory]
			GROUP BY
					ProductID
			) maxth ON th.ProductID = maxth.ProductID AND th.TransactionDate = maxth.MaxTransactionDate;

