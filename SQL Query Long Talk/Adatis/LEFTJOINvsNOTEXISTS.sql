
SET STATISTICS IO, TIME ON

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

SELECT	p.ProductID, p.ProductNumber
FROM Production.Product p
LEFT OUTER JOIN Production.WorkOrder wo ON p.ProductID = wo.ProductID 
WHERE wo.ProductID IS NULL

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

SELECT	p.ProductID, p.ProductNumber
FROM Production.Product p
WHERE NOT EXISTS (SELECT 1 FROM Production.WorkOrder WHERE WorkOrder.ProductID = p.ProductID)