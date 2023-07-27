-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-29>
-- Description:	<Obtiene información para módulo de ingreso de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetSpecialRouteArrival]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		SELECT
			'1' 'ResultCode'
		   ,'Registros obtenidos correctamente.' 'Description'

		DECLARE @HasFirstPickupProcessCount INT
		DECLARE @HasFirstArrivalProcessCount INT

		SELECT 
			@HasFirstPickupProcessCount = SUM(CASE WHEN HasFirstPickupProcess = 1 THEN 1 ELSE 0 END)
			,@HasFirstArrivalProcessCount = SUM(CASE WHEN HasFirstArrivalProcess = 1 THEN 1 ELSE 0 END)
		FROM TSERoutePreparationHeader WITH(NOLOCK)
		WHERE RowStatus = 1


		SELECT
			@HasFirstPickupProcessCount HasFirstPickupProcessCount
		   ,@HasFirstArrivalProcessCount HasFirstArrivalProcessCount
		   ,SUM(CASE
				WHEN trph.HasFirstPickupProcess = 1 THEN 1
				ELSE 0
			END) HasFirstPickupProcessGuide
		   ,SUM(CASE
				WHEN trph.HasFirstArrivalProcess = 1 THEN 1
				ELSE 0
			END) HasFirstArrivalProcessGuide
		   ,SUM(CASE
				WHEN trph.HasFirstPickupProcess = 1 THEN ISNULL(do.Pieces_Dry + do.Pieces_Cold, 0)
				ELSE 0
			END) HasFirstPickupProcessPiece
		   ,SUM(CASE
				WHEN trph.HasFirstArrivalProcess = 1 THEN ISNULL(do.Pieces_Dry + do.Pieces_Cold, 0)
				ELSE 0
			END) HasFirstArrivalProcessPiece
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
			ON trph.IDTSERoutePreparationHeader = trpd.TSERoutePreparationHeaderID
		INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON trpd.GuideSerie = do.Guide_Serie
				AND trpd.GuideNumber = do.Guide_Number
		WHERE trph.RowStatus = 1
		AND trpd.RowStatus = 1
		AND (do.Pieces_Dry + do.Pieces_Cold) > 1

		SELECT
			trph.TSECustomsMark [TSECustomsMark]
		   ,cr.CodeRoute [Route]
		   ,cv.Plate [Vehicle]
		   ,CONCAT(sr.First_Name, ' ', sr.Last_Name) [Courier]
		   ,CONCAT(srl.First_Name, ' ', srl.Last_Name) [Leader]
		   ,CONCAT(srs.First_Name, ' ', srs.Last_Name) [Supervisor]
		   ,crc.ClusterName [Cluster]
		   ,ISNULL(trpd.Pieces, 0) [Pieces]
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		INNER JOIN CatRoute cr WITH (NOLOCK)
			ON trph.IdCatRoute = cr.IdRoute
		INNER JOIN CatVehicle cv WITH (NOLOCK)
			ON trph.IdCatVehicle = cv.IdVehicle
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
			ON trph.SenderReceiverId = sr.ID
		INNER JOIN SenderReceiver srl WITH (NOLOCK)
			ON trph.IdRouteLeader = srl.ID
		INNER JOIN SenderReceiver srs WITH (NOLOCK)
			ON trph.IdRouteSupervisor = srs.ID
		INNER JOIN CatRouteCluster crc WITH (NOLOCK)
			ON trph.IdCatRouteCluster = crc.IdCatRouteCluster
		OUTER APPLY (SELECT
				SUM(do.Pieces_Dry + do.Pieces_Cold) [Pieces]
			FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON do.Guide_Serie = trpd.GuideSerie
			AND do.Guide_Number = trpd.GuideNumber
			WHERE trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
			AND trph.RowStatus = 1
			AND trpd.RowStatus = 1
			AND (do.Pieces_Dry + do.Pieces_Cold) > 1) trpd
		WHERE trph.RowStatus = 1
		AND trph.HasFirstPickupProcess = 1
		AND trph.HasFirstArrivalProcess = 1

	END TRY
	BEGIN CATCH
		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'

	END CATCH
END