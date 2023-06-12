-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-31>
-- Description:	<Obtiene información para módulo del detalle de despacho de rutas en procesos especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetSpecialRouteDeliveryDispatchDetail]
	-- Add the parameters for the stored procedure here
	@CustomMark NVARCHAR(50)
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

		SELECT
			COUNT(1) Guides
			,SUM(ISNULL(do.Pieces_Dry + do.Pieces_Cold, 0)) Pieces
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
			ON trph.IDTSERoutePreparationHeader = trpd.TSERoutePreparationHeaderID
		INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON trpd.GuideSerie = do.Guide_Serie
				AND trpd.GuideNumber = do.Guide_Number
		WHERE trph.TSECustomsMark = @CustomMark
		AND	trph.RowStatus = 1
		AND trpd.RowStatus = 1
		AND (do.Pieces_Dry + do.Pieces_Cold) > 1

		SELECT
			CONCAT(do.Guide_Serie, do.Guide_Number) Guide
			,CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) Receiver
			,do.Receiver_Address [Address]
			,do.Pieces_Dry + do.Pieces_Cold Pieces
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
		ON trph.IDTSERoutePreparationHeader = trpd.TSERoutePreparationHeaderID
		AND trph.TSECustomsMark = @CustomMark
		INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON do.Guide_Serie = trpd.GuideSerie
			AND do.Guide_Number = trpd.GuideNumber 
		WHERE trph.RowStatus = 1
		AND trpd.RowStatus = 1
		AND (do.Pieces_Dry + do.Pieces_Cold) > 1
		AND trph.HasFirstPickupProcess = 1
		AND trph.HasFirstArrivalProcess = 1
		AND trph.HasFirstDispatchProcess = 0

	END TRY
	BEGIN CATCH
		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'

	END CATCH
END