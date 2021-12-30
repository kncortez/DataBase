USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetRoutePreparation]    Script Date: 29/12/2021 09:28:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2021-12-27>
-- Description:	<Obtiene información de la preparación de entregas en base a una ruta y una fecha.>
-- =============================================
ALTER PROCEDURE [dbo].[GetRoutePreparation]
	@IdRoute INT,
	@Date DATE
AS
BEGIN

	--TABLE 0 Información de la preparación de la ruta
	SELECT rp.IdRoutePreparation, rp.GuidesQuantity, rp.PiecesDry, rp.PiecesCold, rp.DeliveryOrderBySettlementId,
		dobs.CatVehicleId, dobs.StartingKilometers, sr.CUI
	FROM RoutePreparation rp
	LEFT JOIN DeliveryOrderBySettlement dobs
		ON rp.DeliveryOrderBySettlementId = dobs.ID
	LEFT JOIN SenderReceiver sr
		ON dobs.ID_Courier = sr.ID
	WHERE rp.CatRouteId = @IdRoute AND rp.DateRoutePreparation = @Date
		AND rp.RowStatus = 1

	--TABLE 1 Información de las guías en preparación de la ruta
	SELECT rpd.Guide_Serie
		, rpd.Guide_Number
		, COALESCE(do.Pieces_Dry,0) + COALESCE(do.Pieces_Cold,0) Pieces
		, do.Receiver_Department Department
		, do.Receiver_Town Town
		, do.Receiver_Address Address
		, do.Pieces_Dry Pieces_Dry
		, do.Pieces_Cold Pieces_Cold
		, do.Collect_OnDelivery COD
		, do.IsCollect IsCollect
	FROM RoutePreparationDetail rpd
	JOIN RoutePreparation rp
		ON rpd.RoutePreparationId = rp.IdRoutePreparation
		AND rp.RowStatus = 1
	JOIN DeliveryOrder do
		ON do.Guide_Serie = rpd.Guide_Serie AND do.Guide_Number = rpd.Guide_Number
	WHERE rp.CatRouteId = @IdRoute AND rp.DateRoutePreparation = @Date
		AND rpd.RowStatus = 1
END