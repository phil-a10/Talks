USE StackOverflow2013;


-- what happens when we scale up a RANK function?
-- find last comment per user

SET STATISTICS IO, TIME ON;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT UserId, CreationDate, Score
FROM
	(
	SELECT	UserId, CreationDate,
			Score,
			RANK() OVER(PARTITION BY UserId ORDER BY CreationDate DESC) CommentRank
	FROM	dbo.Comments_CCIX
	) CommentHistory
WHERE CommentRank = 1

-- there is a spill on the sort operator

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

SELECT c.UserId, c.CreationDate, Score
FROM dbo.Comments_CCIX c
INNER JOIN 
			(
			SELECT	UserId,
					MAX(CreationDate) MaxCreationDate
			FROM	dbo.Comments_CCIX
			GROUP BY
					UserId
			) maxcd ON c.UserId = maxcd.UserId AND c.CreationDate = maxcd.MaxCreationDate;



-- why so much slower


