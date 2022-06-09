
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Obtiene la información de una guía para ser mandada a Simpliroute mediante un flujo manual.>
-- =============================================

CREATE PROCEDURE [dbo].[GetGuideParameters]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN

	SELECT
		CONCAT(DO.Guide_Serie,DO.Guide_Number) 'Guide'
		,DO.Guide_Serie 'GuideSerie'
		,DO.Guide_Number 'GuideNumber'
		,SO.OrderDescription 'Checkpoint'
		,DO.Pieces_Dry 'DryPieces'
		,DO.Pieces_Cold 'ColdPieces'
		,DO.Receiver_Address 'ReceiverAddress'
		,HL.HubAbbreviation 'Hub'
		,IIF(SDFG.StartTime IS NULL, NULL,CONCAT(CONVERT(NVARCHAR,SDFG.StartTime,108),' - ',CONVERT(NVARCHAR,SDFG.EndTime,108))) 'Window1'
		,SDFG.StartTime 'Window1Start'
		,SDFG.EndTime 'Window1End'
		,IIF(SDFG.StartTime2 IS NULL, NULL,CONCAT(CONVERT(NVARCHAR,SDFG.StartTime2,108),' - ',CONVERT(NVARCHAR,SDFG.EndTime2,108))) 'Window2'
		,SDFG.StartTime2 'Window2Start'
		,SDFG.EndTime2 'Window2End'
		,DO.StatusOrderId 'IdCheckpoint'
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
		JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO
			ON
			DO.StatusOrderId = SO.StatusOrderId
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG
			ON
			SDFG.GuideSerie = DO.Guide_Serie
			AND
			SDFG.GuideNumber = DO.Guide_Number
			AND
			SDFG.IsDelivery =  1
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL
			ON
			DO.HubDestinationId = HL.IdHubLogistic
	WHERE
		DO.Guide_Serie = @GuideSerie
		AND
		DO.Guide_Number = @GuideNumber

END