USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.PasswordLog  
   (PslIdLog bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	PslIdUser bigint NOT NULL,
	PslPassword varchar(100) NOT NULL,
	PslTokenCreated varchar(50)  NOT NULL,
	PslDateCreated date  NOT NULL,
	FOREIGN KEY (PslIdUser) REFERENCES RegisterUser(UsrIdUser)
	)
GO  
