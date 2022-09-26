USE StackOverflow2013;

SET STATISTICS IO, TIME ON;

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

-- what happens when we scale up a RANK function?
-- find last comment per user

-- run the second query first this occasion to save time
SELECT c.UserId, c.CreationDate
FROM dbo.Comments_CCIX c
INNER JOIN 
			(
			SELECT	UserId,
					MAX(CreationDate) MaxCreationDate
			FROM	dbo.Comments_CCIX
			GROUP BY
					UserId
			) maxcd ON c.UserId = maxcd.UserId AND c.CreationDate = maxcd.MaxCreationDate;


-- note the 'spill' on the sort operator

SELECT UserId, CreationDate
FROM
	(
	SELECT	UserId, CreationDate,
			RANK() OVER(PARTITION BY UserId ORDER BY CreationDate DESC) CommentRank
	FROM	dbo.Comments_CCIX
	) CommentHistory
WHERE CommentRank = 1

-- there is also a spill (on a different operator) so why is it faster?