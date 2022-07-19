USE [StackOverflow2013];

DROP TABLE dbo.Comments_Heap;
GO

CREATE TABLE dbo.Comments_Heap
(
Id INT IDENTITY(1,1) NOT NULL,
CreationDate datetime NOT NULL,
PostId int NOT NULL,
Score int NOT NULL,
Text nvarchar(700) NOT NULL,
UserId INT NULL
);

INSERT dbo.Comments_Heap (CreationDate, PostId, Score, Text, UserId)
SELECT CreationDate, PostId, Score, Text, UserId
FROM dbo.Comments;

SELECT  TOP 20 
		allocated_page_page_id ,
        next_page_page_id ,
        previous_page_page_id
FROM    sys.dm_db_database_page_allocations(DB_ID(),
                                            OBJECT_ID('Comments_Heap'),
                                            NULL, NULL, 'Detailed')
WHERE   page_type_desc = 'DATA_PAGE';

SELECT  TOP 20
		allocated_page_page_id ,
        next_page_page_id ,
        previous_page_page_id
FROM    sys.dm_db_database_page_allocations(DB_ID(),
                                            OBJECT_ID('Comments'),
                                            NULL, NULL, 'Detailed')
WHERE   page_type_desc = 'DATA_PAGE'

SET STATISTICS IO, TIME ON;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	COUNT(*)
FROM dbo.Comments_Heap ch

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	COUNT(*)
FROM dbo.Comments ch

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	UserId, 		
		COUNT(*)
FROM dbo.Comments_Heap ch
INNER JOIN dbo.Users u ON ch.UserId = u.Id
GROUP BY
		UserId;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT	UserId, 
		COUNT(*)
FROM dbo.Comments ch
INNER JOIN dbo.Users u ON ch.UserId = u.Id
GROUP BY
		UserId;

