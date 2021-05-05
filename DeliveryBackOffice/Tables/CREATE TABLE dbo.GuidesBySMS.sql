--DROP TABLE dbo.GuidesBySMS
Use DeliveryBackOffice
GO

CREATE TABLE dbo.GuidesBySMS
	(
	IdGuidesBySMS bigint NOT NULL IDENTITY (1, 1),
	SmsId bigint NOT NULL,
	GuideSerie nvarchar(2) NULL,
	GuideNumber int NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.GuidesBySMS ADD CONSTRAINT
	PK_GuidesBySMS PRIMARY KEY CLUSTERED 
	(
	IdGuidesBySMS
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.GuidesBySMS ADD CONSTRAINT
	FK_GuidesBySMS_SMS_Received FOREIGN KEY
	(
	SmsId
	) REFERENCES dbo.SMS_Received
	(
	SMS_ID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.GuidesBySMS ADD CONSTRAINT
	FK_GuidesBySMS_DeliveryOrder FOREIGN KEY
	(
	GuideSerie,
	GuideNumber
	) REFERENCES dbo.DeliveryOrder
	(
	Guide_Serie,
	Guide_Number
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	