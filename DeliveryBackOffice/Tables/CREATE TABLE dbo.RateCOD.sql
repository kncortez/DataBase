

CREATE TABLE dbo.RateCOD
	(IdRateCOD bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	RateId int NOT NULL,
	TypeServiceId int NOT NULL,
	TypeSegmentId int NOT NULL,
	CODRate decimal(12,2) NOT NULL,
	CODExempt decimal(12,2) NULL,
	CreditCardSurcharge decimal(12,2) null,
	RowStatus int  NOT NULL,
	TokenCreated VARCHAR(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated VARCHAR(50) NULL,
	DateUpdated datetime NULL,
	FOREIGN KEY (RateId) REFERENCES dbo.RateHeader(RheId),
	FOREIGN KEY (TypeServiceId) REFERENCES dbo.CatTypeService(CtsId),
	FOREIGN KEY (TypeSegmentId) REFERENCES dbo.CatRateSegment(CrsId)
	)
GO  
