CREATE TABLE DeliveryBackOffice.dbo.SpecialSale  
   (IdSpecialSale int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name varchar(50) NOT NULL,
	Description varchar(200)  NULL,
	StartDate datetime not null,
	FinishDate datetime null,
	IsGlobal bit not null,
	Priority int not null,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)

