USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetRoutePreparationDetail]    Script Date: 23/12/2021 09:33:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2021-12-23>
-- Description:	<Obtiene información de la preparación de entregas para una guía.>
-- =============================================
CREATE PROCEDURE [dbo].[GetRoutePreparationDetail]
	@IdRoute INT,
	@Date DATE,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece SMALLINT
AS
BEGIN

	--TABLE 0 para saber si ya está asignado a una ruta
	SELECT TOP 1 rp.IdRoutePreparation, rpd.IdRoutePreparationDetail, rpd.DateCreated, cr.CodeRoute
	FROM RoutePreparationDetail rpd
	JOIN RoutePreparation rp 
		ON rpd.RoutePreparationId = rp.IdRoutePreparation
	JOIN CatRoute cr
		ON rp.CatRouteId = cr.IdRoute
	WHERE rp.DateRoutePreparation = @Date
		AND rpd.RowStatus = 1 
		AND Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
		AND rp.DateRoutePreparation = CONVERT(date, GETDATE())
	ORDER BY rpd.DateCreated DESC

	--TABLE 1 para obtener el total de piezas e información de la guía
	SELECT @GuideSerie Guide_Serie
		, @GuideNumber Guide_Number
		, @GuidePiece Guide_Piece
		, COALESCE(do.Pieces_Dry,0) + COALESCE(do.Pieces_Cold,0) Pieces
		, Receiver_Department Department
		, Receiver_Town Town
		, Receiver_Address Address
	FROM DeliveryOrder do
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber
END