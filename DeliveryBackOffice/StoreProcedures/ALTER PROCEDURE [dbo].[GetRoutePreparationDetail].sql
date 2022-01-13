USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetRoutePreparationDetail]    Script Date: 12/01/2022 23:13:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2021-12-23>
-- Description:	<Obtiene información de la preparación de entregas para una guía.>
-- =============================================
ALTER PROCEDURE [dbo].[GetRoutePreparationDetail] @IdRoute INT,
@Date DATE,
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@GuidePiece SMALLINT
AS
BEGIN

	DECLARE @StatusOrderId TINYINT

	--TABLE 0 para saber si ya está asignado a una ruta
	SELECT TOP 1
		rp.IdRoutePreparation
	   ,rpd.IdRoutePreparationDetail
	   ,rpd.DateCreated
	   ,cv.UnitNumber 'CodeRoute'
	   ,rp.IsSimpliRoute
	FROM RoutePreparationDetail rpd
	JOIN RoutePreparation rp
		ON rpd.RoutePreparationId = rp.IdRoutePreparation
	JOIN CatVehicle cv
		ON rp.CatVehicleId = cv.IdVehicle
	WHERE rp.DateRoutePreparation = @Date
	AND rpd.RowStatus = 1
	AND Guide_Serie = @GuideSerie
	AND Guide_Number = @GuideNumber
	AND rp.DateRoutePreparation = CONVERT(DATE, GETDATE())
	ORDER BY rpd.DateCreated DESC

	--TABLE 1 para obtener el total de piezas e información de la guía
	SELECT
		@GuideSerie Guide_Serie
	   ,@GuideNumber Guide_Number
	   ,@GuidePiece Guide_Piece
	   ,COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) Pieces
	   ,Receiver_Department Department
	   ,Receiver_Town Town
	   ,Receiver_Address Address
	   ,Pieces_Dry Pieces_Dry
	   ,Pieces_Cold Pieces_Cold
	FROM DeliveryOrder do
	WHERE do.Guide_Serie = @GuideSerie
	AND do.Guide_Number = @GuideNumber
	--AND do.StatusOrderId NOT IN (5,7,14,20,22,23,24,25)

	--TABLE 2 Validar que la guía no este en un estado no permitido 
	SET @StatusOrderId = (SELECT TOP 1
			dod.StatusOrderId
		FROM DeliveryOrderDetail dod
		WHERE dod.Guide_Serie = @GuideSerie
		AND dod.Guide_Number = @GuideNumber
		ORDER BY dod.DateCreated DESC)

	IF (SELECT
				COUNT(1)
			FROM StatusOrderUpdate sou
			WHERE sou.StatusOrderId = @StatusOrderId
			AND sou.InvalidIdUpdate = 3)
		= 0
	BEGIN
		--ES VALIDO
		SELECT
			1 StatusCode
		   ,'' Description
	END
	ELSE
	BEGIN
		--NO ES VALIDO
		SELECT
			0 StatusCode
		   ,so.OrderDescription Description
		FROM StatusOrder so
		WHERE so.StatusOrderId = @StatusOrderId
	END
END