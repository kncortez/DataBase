USE [DeliveryBackOffice]
GO


CREATE TABLE DeliveryBackOffice.dbo.CatTypeProduct
   (IdTypeProduct int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name nvarchar(200)  NULL,
	RowStatus bit  NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO 
insert into dbo.CatTypeProduct values ('Guia',1,'SYS-CAQUINO',GETDATE(),null,null),('Servicio',1,'SYS-CAQUINO',GETDATE(),null,null)

select * from dbo.CatTypeProduct


CREATE TABLE DeliveryBackOffice.dbo.CatTypeCharge
   (IdTypeCharge int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name nvarchar(200)  NULL,
	RowStatus bit  NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO 
insert into dbo.CatTypeCharge values ('Costo de Envío',1,'SYS-CAQUINO',GETDATE(),null,null),('Costo de Recolección',1,'SYS-CAQUINO',GETDATE(),null,null)
select * from CatTypeCharge

CREATE TABLE DeliveryBackOffice.dbo.Cost 
   (IdCost int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	IdProduct int  NULL,
	ProductNumber varchar(100)  NULL,
	IdTypeCharge  int  NULL,
	TotalAmount decimal (18,2)  NULL,
	PaymentDate datetime  NULL,
	IdModule int  NULL,
	RowStatus bit NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKCostProduct FOREIGN KEY (IdProduct) REFERENCES CatTypeProduct(IdTypeProduct),
	CONSTRAINT FKCostCharge FOREIGN KEY (IdTypeCharge) REFERENCES CatTypeCharge(IdTypeCharge),
	CONSTRAINT FKCostModule FOREIGN KEY (IdModule) REFERENCES CatModule(ModIdModule)
	)
GO  

USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CostDetail
   (IdCostDetail int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	IdCost int  NULL,
	IdTypeOfMoney int  NULL,
	Amount decimal (18,2)  NULL,
	Voucher varchar(300)  NULL,
	RowStatus bit NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKCostDetCost FOREIGN KEY (IdCost) REFERENCES Cost(IdCost),
	CONSTRAINT FKCostDetTypeMoney FOREIGN KEY (IdTypeOfMoney) REFERENCES ctgTypeOfInOutOfMoney(tio_pk_id))
GO  

USE [DeliveryBackOffice]
GO

INSERT into DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney  (tio_pk_id, tio_pk_name, tio_tokenCreated, tio_dateCreated)
values (6,'Datafono', 'SYS-CAQUINO', getdate())

select * from dbo.ctgTypeOfInOutOfMoney
