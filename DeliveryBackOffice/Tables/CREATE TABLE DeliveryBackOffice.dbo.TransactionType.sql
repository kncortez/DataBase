USE [DeliveryBackOffice]
GO

-- =============================================
-- Author:		<Abner, Juárez>
-- Create date: <2020-04-29>
-- Description:	<Tabla para el catalogo de procesos de Forza delivery >
-- =============================================

CREATE TABLE DeliveryBackOffice.dbo.TransactionType (
	IdTransactionType int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Name nvarchar(100) NOT NULL,
	Description nvarchar(200) NOT NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50),
	DateUpdated datetime)