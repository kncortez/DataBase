

CREATE TABLE DeliveryBackOffice.dbo.SpecialSaleDetail  
   (IdSpecialSaleDetail int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SpecialSaleId int NOT NULL,
	UnitId int NOT NULL,
	Value decimal (12,2),
	TypeDiscountId int not null,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL
	CONSTRAINT FKDiscountSale FOREIGN KEY (SpecialSaleId) REFERENCES SpecialSale(IdSpecialSale),
	CONSTRAINT FKDiscountUnit FOREIGN KEY (UnitId) REFERENCES Unit(IdUnit),
	CONSTRAINT FKDiscountType FOREIGN KEY (TypeDiscountId) REFERENCES  CatTypeDiscount(IdCatTypeDiscount)
	)



