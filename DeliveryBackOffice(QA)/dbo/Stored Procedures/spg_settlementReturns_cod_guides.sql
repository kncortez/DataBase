-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-23>
-- Description:	<Obtiene detalle para generar manifiesto de liquidación rutas de devolución (COD)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlementReturns_cod_guides]
	-- Add the parameters for the stored procedure here
	@IdManifest INT
AS
BEGIN

		SELECT CONCAT(do.Guide_Serie, do.Guide_Number)  Guide_Code
		,	(SELECT COUNT(1)
				FROM SettlementByPickupDetail spd2
				JOIN SettlementByPickup sbp2
					ON sbp2.Id = spd2.SettlementByPickupId
				LEFT JOIN DeliveryOrderPiece dop
					ON spd2.GuideSerie = dop.GuideSerie 
					AND spd2.GuideNumber = dop.GuideNumber
					AND spd2.NoPiece = dop.NoPiece
				WHERE spd2.GuideSerie = do.Guide_Serie  AND spd2.GuideNumber = do.Guide_Number
					AND sbp2.SequenceCode = @IdManifest 
					AND sbp2.SubTypeServiceManagmentId = 3
					AND spd2.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en devolución
					AND spd2.IsCODSettlement = 1 -- Pieza no liquidada en COD
					AND dop.IsDry = 0) Pieces_Cold
		,	(SELECT COUNT(1)
			FROM SettlementByPickupDetail spd2
			JOIN SettlementByPickup sbp2
					ON sbp2.Id = spd2.SettlementByPickupId
			LEFT JOIN DeliveryOrderPiece dop
				ON spd2.GuideSerie = dop.GuideSerie 
				AND spd2.GuideNumber = dop.GuideNumber
				AND spd2.NoPiece = dop.NoPiece
			WHERE spd2.GuideSerie = do.Guide_Serie  AND spd2.GuideNumber = do.Guide_Number
				AND sbp2.SequenceCode = @IdManifest 
				AND sbp2.SubTypeServiceManagmentId = 3
				AND spd2.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en devolución
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
			SELECT sbpd.GuideSerie, sbpd.GuideNumber
			FROM SettlementByPickupDetail sbpd
			JOIN SettlementByPickup sbp
				ON sbp.Id = sbpd.SettlementByPickupId
			WHERE sbp.SequenceCode = @IdManifest 
				AND sbp.SubTypeServiceManagmentId = 3
				AND sbpd.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en devolucón
				AND sbpd.IsCODSettlement = 1 -- Pieza no liquidada en COD
			GROUP BY sbpd.GuideSerie, sbpd.GuideNumber
		) spd ON do.Guide_Serie = spd.GuideSerie AND do.Guide_Number = spd.GuideNumber
    
END
