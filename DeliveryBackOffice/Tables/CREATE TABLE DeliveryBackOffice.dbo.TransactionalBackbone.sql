USE [DeliveryBackOffice]
GO

-- =============================================
-- Author:		<Abner, Juárez>
-- Create date: <2020-04-29>
-- Description:	<Tabla para llevar el control de transacciones de los procesos de Forza Delivery>
-- =============================================

CREATE TABLE DeliveryBackOffice.dbo.TransactionalBackbone(
	IdTransactionalMovement int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	GuideSerie nvarchar(2) NOT NULL,
	GuideNumber int NOT NULL,
	GuidePiece int NOT NULL,
	RouteId int FOREIGN KEY REFERENCES DeliveryBackOffice.dbo.CatRoute(IdRoute) NOT NULL,
	InBound int FOREIGN KEY REFERENCES DeliveryBackOffice.dbo.CatTransportationZone(IdTranportationZone) NOT NULL,
	OutBound int FOREIGN KEY REFERENCES DeliveryBackOffice.dbo.CatTransportationZone(IdTranportationZone) NOT NULL,
	LineHaul bit,
	StatusComplete bit,
	TransactionTypeId int FOREIGN KEY REFERENCES DeliveryBackOffice.dbo.TransactionType(IdTransactionType) NOT NULL,
	CountryId varchar(2) FOREIGN KEY REFERENCES DeliveryBackOffice.dbo.CatCountry(IdCountry) NOT NULL,
	HubId int FOREIGN KEY REFERENCES DeliveryBackOffice.dbo.HubLogistics(IdHubLogistic),
	TypeOfPieceId int,
	ServiceManagmentID int FOREIGN KEY REFERENCES DeliveryBackOffice.dbo.ServiceManagement(IdServiceManagement),
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50),
	DateUpdated datetime)