-- Script FDAPI-1291

CREATE TABLE CatTMSalesPerson(
	IdCatTMSalesPerson INT IDENTITY(1,1) NOT NULL,

	Code NVARCHAR(25) NOT NULL,
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
	Country NVARCHAR(25) NOT NULL,

	RegisterUserId BIGINT NOT NULL,

	RowStatus BIT NOT NULL,
	DateCreated DateTime NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateUpdated DateTime NULL,
	TokenUpdated NVARCHAR(50) NOT NULL

	PRIMARY KEY(IdCatTMSalesPerson),
	CONSTRAINT FK_CatTMSalesPerson_RegisterUser FOREIGN KEY (RegisterUserId) REFERENCES RegisterUser(UsrIdUser),
);

-- Table Customer
ALTER TABLE Customer 
ADD CatTMSalesPersonId INT NULL;

ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_CatTMSalesPerson FOREIGN KEY (CatTMSalesPersonId) REFERENCES CatTMSalesPerson(IdCatTMSalesPerson);

GO
DECLARE @v sql_variant 
SET @v = N'Identificador del vendedor de telemercadeo asociado al cliente'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Customer', N'COLUMN', N'CatTMSalesPersonId'
GO

ALTER TABLE Customer
ADD CutOffDate DATETIME NULL;

GO
DECLARE @v sql_variant 
SET @v = N'Fecha de corte para los clientes de tipo PYMES'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Customer', N'COLUMN', N'CutOffDate'
GO

ALTER TABLE Customer 
ADD UpgradeDate DATETIME NULL;

GO
DECLARE @v sql_variant 
SET @v = N'Fecha de actualización de tipo de cliente'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Customer', N'COLUMN', N'UpgradeDate'
GO

ALTER TABLE Customer
ADD CustomerGoalQuantity INT NULL;

GO
DECLARE @v sql_variant 
SET @v = N'Meta de envíos para cliente'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Customer', N'COLUMN', N'CustomerGoalQuantity'
GO

-- Table Membership
ALTER TABLE Membership
ADD CatTMSalesPersonId INT NULL;

GO
DECLARE @v sql_variant 
SET @v = N'Identificador del vendedor de telemercadeo asociado a la membresía vendida'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Membership', N'COLUMN', N'CatTMSalesPersonId'
GO

-- Table CatTypeOfBusiness
INSERT INTO [dbo].[CatTypeOfBusiness]
			([TypeOfBusinessName],
			 [TypeOfBusinessDescription],
			 [CountryID],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
VALUES		('PYMES',
			 'Clientes pequeña y mediana empresa',
			 'GT',
			 1, 
			 'SYS-JOCHOA',
			 SYSDATETIME());