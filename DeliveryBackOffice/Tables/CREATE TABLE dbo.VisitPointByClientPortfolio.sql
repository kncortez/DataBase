USE [DeliveryBackOffice]
GO
CREATE TABLE dbo.VisitPointByClientPortfolio
	(
	IdVisitPointByClientPortfolio bigint NOT NULL IDENTITY (1, 1),
	FirstName nvarchar(50)  NULL,
	SecondName nvarchar(50)  NULL,
	LastName nvarchar(50)  NULL,
	SecondLastName nvarchar(50)  NULL,
	Email nvarchar(200)  NULL,
	NirPhone nvarchar(10)  NULL,
	Phone nvarchar(20)  NULL,
	CUI nvarchar(100)  NULL,
	VisitPointId int NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(150) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(150) NULL,
	DateUpdated datetime NULL
	)  
GO