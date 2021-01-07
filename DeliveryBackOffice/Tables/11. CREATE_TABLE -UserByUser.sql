USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.UserByUser  
   (UbuIdUserAdmin bigint NOT NULL,
	UbuIdUserChild bigint NOT NULL,
	UbuRowStatus bit NOT NULL,
	 primary key (UbuIdUserAdmin, UbuIdUserChild) ,
	CONSTRAINT FKRolAdmin FOREIGN KEY (UbuIdUserAdmin) REFERENCES RegisterUser(UsrIdUser),
	CONSTRAINT FKRolChild FOREIGN KEY (UbuIdUserChild) REFERENCES RegisterUser(UsrIdUser)
	)
GO  


