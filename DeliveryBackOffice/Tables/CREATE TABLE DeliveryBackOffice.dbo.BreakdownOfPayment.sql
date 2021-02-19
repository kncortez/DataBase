CREATE TABLE DeliveryBackOffice.dbo.BreakdownOfPayment
   (IdBreakdownOfPayment int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	IdCost int  NULL,
	Description varchar(100) null,
	Amount decimal (18,2)  NULL,
	ModIdModule int  NULL,
	RowStatus bit NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKCost FOREIGN KEY (IdCost) REFERENCES Cost(IdCost),
	CONSTRAINT FKCostDetCatModule FOREIGN KEY (ModIdModule) REFERENCES CatModule(ModIdModule))
GO  

select * from BreakdownOfPayment