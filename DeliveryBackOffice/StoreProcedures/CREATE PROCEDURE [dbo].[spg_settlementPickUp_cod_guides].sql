USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Morales,Oscar>
-- Create date: <2021-09-07>
-- Description:	<Obtiene detalle para generar manifiesto de liquidación rutas recolectoras (COD)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlementPickUp_cod_guides]
	-- Add the parameters for the stored procedure here
	@IdManifest INT
AS
BEGIN

		SELECT CONCAT(do.Guide_Serie, do.Guide_Number)  Guide_Code
		,	(SELECT COUNT(1)
				FROM SettlementByPickupDetail spd2
				LEFT JOIN DeliveryOrderPiece dop
					ON spd2.GuideSerie = dop.GuideSerie 
					AND spd2.GuideNumber = dop.GuideNumber
					AND spd2.NoPiece = dop.NoPiece
				WHERE spd2.GuideSerie = do.Guide_Serie  AND spd2.GuideNumber = do.Guide_Number
					AND spd2.SettlementByPickupId = @IdManifest 
					AND spd2.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en recolección
					AND spd2.IsCODSettlement = 1 -- Pieza no liquidada en COD
					AND dop.IsDry = 0) Pieces_Cold
		,	(SELECT COUNT(1)
			FROM SettlementByPickupDetail spd2
			LEFT JOIN DeliveryOrderPiece dop
				ON spd2.GuideSerie = dop.GuideSerie 
				AND spd2.GuideNumber = dop.GuideNumber
				AND spd2.NoPiece = dop.NoPiece
			WHERE spd2.GuideSerie = do.Guide_Serie  AND spd2.GuideNumber = do.Guide_Number
				AND spd2.SettlementByPickupId = @IdManifest 
				AND spd2.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en recolección
				AND spd2.IsCODSettlement = 1 -- Pieza no liquidada en COD
				AND (dop.IsDry IS NULL OR dop.IsDry = 1)) Pieces_Dry
		, CONCAT(do.Receiver_FirstName,' ', do.Receiver_LastName) Receiver_Fullname
		, do.Receiver_Address Receiver_Address
		, CONVERT(INT, ISNULL(do.Receiver_Zone,0)) Receiver_Zone
		, do.Receiver_Town Receiver_Town
		, do.Receiver_Department  Receiver_Departament
		, do.Receiver_Phone Receiver_Phone
		, do.PriceShippment PriceShippment
	FROM DeliveryOrder do
	INNER JOIN (
			SELECT GuideSerie, GuideNumber
			FROM SettlementByPickupDetail
			WHERE SettlementByPickupId = @IdManifest 
				AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en recolección
				AND IsCODSettlement = 1 -- Pieza no liquidada en COD
			GROUP BY GuideSerie, GuideNumber
		) spd ON do.Guide_Serie = spd.GuideSerie AND do.Guide_Number = spd.GuideNumber
    
END

