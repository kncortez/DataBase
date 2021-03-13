
CREATE TABLE DeliveryBackOffice.dbo.SpecialSaleTarget  
   (IdSpecialSaleTarget int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SpecialSaleId int NOT NULL,
	SalesPipeLineId int  NULL,
	CustomerTypeid int  NULL,
	CustomerId int  NULL,
	TypeServiceId int  NULL,
	TypeProductId int  NULL,

	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL
	CONSTRAINT FKTargetSale FOREIGN KEY (SpecialSaleId) REFERENCES SpecialSale(IdSpecialSale),
	CONSTRAINT FKTargetPipe FOREIGN KEY (SalesPipeLineId) REFERENCES CatSalePipelines(IdSalePipeLine),
	CONSTRAINT FKTargetCustomerType FOREIGN KEY (CustomerTypeid) REFERENCES  CustomerType(IdCustomerType),
	CONSTRAINT FKTargetCustomer FOREIGN KEY (CustomerId) REFERENCES  Customer(IdCustomer),
	CONSTRAINT FKTargetTypeService FOREIGN KEY (TypeServiceId) REFERENCES  CatTypeService(CtsId),
	CONSTRAINT FKTargetProduct FOREIGN KEY (TypeProductId) REFERENCES  CatTypeProduct(IdTypeProduct)
	)

