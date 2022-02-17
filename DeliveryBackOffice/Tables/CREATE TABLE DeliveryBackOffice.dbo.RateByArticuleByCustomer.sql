CREATE TABLE DeliveryBackOffice.dbo.RateByArticuleByCustomer  
   (Id int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ArticuleByCustomerId int NOT NULL,
	SegmetId int not null,
	Price decimal(12,2) not null,
	RmsRowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKRateCustomerArticule FOREIGN KEY (ArticuleByCustomerId) REFERENCES ArticleByCustomer(AbcId),
	CONSTRAINT FKRateCutomerSegment FOREIGN KEY (SegmetId) REFERENCES  CatRateSegment(CrsId)
	)





