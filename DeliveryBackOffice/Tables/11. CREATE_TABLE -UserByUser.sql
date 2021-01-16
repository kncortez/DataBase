USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.UserByUser  
   (UbuIdUserAdmin bigint NOT NULL,
	UbuIdUserChild bigint NOT NULL,
	UbuRowStatus bit NOT NULL,
	 primary key (UbuIdUserAdmin, UbuIdUserChild) ,
	CONSTRAINT FKUserAdmin FOREIGN KEY (UbuIdUserAdmin) REFERENCES RegisterUser(UsrIdUser),
	CONSTRAINT FKUserChild FOREIGN KEY (UbuIdUserChild) REFERENCES RegisterUser(UsrIdUser)
	)
GO  


