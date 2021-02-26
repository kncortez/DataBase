CREATE TABLE DeliveryBackOffice.dbo.ImagesByVisitPoint
   (IdImage int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	CodeOfReference int  NULL,
	PathImage varchar(200) NULL,
	RowStatus bit NULL,
	TokenCreated varchar(150)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(150)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKCodeOfReference FOREIGN KEY (CodeOfReference) REFERENCES VisitPointClient(CodeOfReference))
GO  

select * from ImagesByVisitPoint