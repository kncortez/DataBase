USE [DeliveryBackOffice]
GO
-- =============================================
-- Author:		<Abner,Juárez>
-- Create date: <2021-04-06>
-- Description:	<Tabla para catalogo de opciones de entrega>
-- =============================================
CREATE TABLE DeliveryBackOffice.dbo.CatDeliveryOptions (
	IdDeliveryOption int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Name nvarchar(100) NOT NULL,
	Description nvarchar(200) NOT NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50),
	DateUpdated datetime
);