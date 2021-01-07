USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.RolByRol  
   (RbrIdRolAdmin int NOT NULL,
	RbrIdRolChild int NOT NULL,
	RbrRowStatus bit NOT NULL,
	 primary key (RbrIdRolAdmin, RbrIdRolChild) ,
	CONSTRAINT FKRolAdmin FOREIGN KEY (RbrIdRolAdmin) REFERENCES CatRol(RolIdRol),
	CONSTRAINT FKRolChild FOREIGN KEY (RbrIdRolChild) REFERENCES  CatRol(RolIdRol)
	)
GO  


