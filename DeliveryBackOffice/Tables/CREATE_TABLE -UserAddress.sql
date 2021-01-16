USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.UserAddress
   (UadIdAddress bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	UadIdTownship int NOT NULL,
	UadIdAccount bigint NOT NULL,
	UadIdCountry varchar(2)  NULL,
	UadFullName varchar(50) NOT NULL,
	UadAddress1 varchar(200) NOT NULL,
	UadAddress2 varchar(200)  NULL,
	UadNirPhone varchar(10) NOT NULL,
	UadPhone varchar(100) NOT NULL,
	UadAdditionalInstructions varchar(250)  NULL,
	UadRowStatus bit NOT NULL,
	UadTokenCreated varchar(50)  NOT NULL,
	UadDateCreated date  NOT NULL,
	UadTokenUpdated varchar(50)   NULL,
	UadDateUpdated date   NULL,
	CONSTRAINT FKAddressTownship FOREIGN KEY (UadIdTownship) REFERENCES Township(IdTownship),
	CONSTRAINT FKAddressAccount FOREIGN KEY (UadIdAccount) REFERENCES Account(AccIdAccount)
	)
GO  
ALTER TABLE [UserAddress]
ADD CodeOfReference INT;

ALTER TABLE [UserAddress] ADD CONSTRAINT FK_IdVisitPointClient
FOREIGN KEY (CodeOfReference) REFERENCES dbo.VisitPointClient (CodeOfReference);


ALTER TABLE [VisitPointClient]
ADD IdTownship INT;

ALTER TABLE [VisitPointClient]
ADD CONSTRAINT FKIdTownship
FOREIGN KEY (IdTownship) REFERENCES dbo.Township(IdTownship);