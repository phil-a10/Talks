
-- MAXDOP (MAx Degree Of Parallelisation) sets the upper limit to the number of threads a query can run on
-- this can cause problems when moving between environments with different number of cores or different parallelisation thresholds
-- if you've excluded everything else and still have perf. problems - this might be the problem

-- demo:

USE [AdventureWorks2019];

SET STATISTICS TIME ON;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- normal query - no parallelisation
SELECT  wo.[DueDate],
        MIN(wo.[OrderQty]) MinOrderQty,
        MIN(wo.[StockedQty]) MinStockedQty,
        MIN(wo.[ScrappedQty]) MinScrappedQty,
        MAX(wo.[OrderQty]) MaxOrderQty,
        MAX(wo.[StockedQty]) MaxStockedQty,
        MAX(wo.[ScrappedQty]) MaxScrappedQty
FROM    [Production].[WorkOrder] wo
GROUP BY wo.[DueDate]
ORDER BY wo.[DueDate]

-- lower the threshold to parallelisation to force the query to go parallel:
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- run a query - this will be parallelised because the threshold is so low
-- under normal circumstances this query won't be parallelised
SELECT  wo.[DueDate],
        MIN(wo.[OrderQty]) MinOrderQty,
        MIN(wo.[StockedQty]) MinStockedQty,
        MIN(wo.[ScrappedQty]) MinScrappedQty,
        MAX(wo.[OrderQty]) MaxOrderQty,
        MAX(wo.[StockedQty]) MaxStockedQty,
        MAX(wo.[ScrappedQty]) MaxScrappedQty
FROM    [Production].[WorkOrder] wo
GROUP BY wo.[DueDate]
ORDER BY wo.[DueDate]

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- MAXDOP hint forces the query to run on single thread
-- which is faster as parallelisation comes with its own overheads
SELECT  wo.[DueDate],
        MIN(wo.[OrderQty]) MinOrderQty,
        MIN(wo.[StockedQty]) MinStockedQty,
        MIN(wo.[ScrappedQty]) MinScrappedQty,
        MAX(wo.[OrderQty]) MaxOrderQty,
        MAX(wo.[StockedQty]) MaxStockedQty,
        MAX(wo.[ScrappedQty]) MaxScrappedQty
FROM    [Production].[WorkOrder] wo
GROUP BY wo.[DueDate]
ORDER BY wo.[DueDate] OPTION (MAXDOP 1)

-- reset the threshold:
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'5'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO