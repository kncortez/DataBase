-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-06-30>
-- Description:	<Guarda la descripción de la incidencia para sobres>
-- =============================================
CREATE PROCEDURE [dbo].[SetSpecialRouteDeliveryConfirmationIncidence]
	-- Add the parameters for the stored procedure here
	@IDTSERoutePreparationHeader INT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Observation NVARCHAR(200),
	@Token NVARCHAR(50)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE TSERoutePreparationDetail
		SET Observation = @Observation
		   ,TokenUpdated = @Token
		   ,DateUpdated = GETDATE()
		WHERE TSERoutePreparationHeaderID = @IDTSERoutePreparationHeader
		AND GuideSerie = @GuideSerie
		AND GuideNumber = @GuideNumber
		AND RowStatus = 1

		COMMIT TRANSACTION
		
		SELECT
			'1' 'ResultCode'
		   ,'Registros guardados correctamente.' 'Description'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END