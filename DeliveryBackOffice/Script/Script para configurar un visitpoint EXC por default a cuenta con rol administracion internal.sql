--INSERT INTO dbo.VisitPointByUser
--(
--	IdVisitPointClient,
--	RegisterUserID,
--	RowStatus,
--	TokenCreated,
--	DateCreated,
--	TokenUpdated,
--	DateUpdated
--)
--VALUES
--(   999,       -- IdVisitPointClient - int
--	21,    -- RegisterUserID - bigint
--	'TRUE', -- RowStatus - bit
--	'SYS-ERAMIREZ',    -- TokenCreated - nvarchar(50)
--	GETDATE(),    -- DateCreated - datetime
--	NULL,    -- TokenUpdated - nvarchar(50)
--	NULL     -- DateUpdated - datetime
--	)

INSERT INTO dbo.VisitPointByUser
(
	IdVisitPointClient,
	RegisterUserID,
	RowStatus,
	TokenCreated,
	DateCreated,
	TokenUpdated,
	DateUpdated
)
VALUES
(   152,       -- IdVisitPointClient - int
	21,    -- RegisterUserID - bigint
	'TRUE', -- RowStatus - bit
	'SYS-ERAMIREZ',    -- TokenCreated - nvarchar(50)
	GETDATE(),    -- DateCreated - datetime
	NULL,    -- TokenUpdated - nvarchar(50)
	NULL     -- DateUpdated - datetime
	)