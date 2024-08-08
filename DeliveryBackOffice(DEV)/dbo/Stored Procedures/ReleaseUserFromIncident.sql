
-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-07-19>
-- Description:	<SP para liberar proceso de validacion de incidencia Ref. FDAPI-2287>
-- =============================================
CREATE PROCEDURE [dbo].[ReleaseUserFromIncident]
 @GuideSerie NVARCHAR(2) = 'FD',
 @GuideNumber INT

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DescriptionResult NVARCHAR(500)

	BEGIN TRY
		UPDATE coi  
		SET coi.TakenIncidenceUserId = Null, 
			coi.TakenIncidenceUserName = Null,  
			coi.TakenIncidenceDateAndTime = Null 
		FROM [dbo].[ConfirmationOfIncidence] coi
			INNER JOIN [dbo].[DeliveryAttempt] da ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
		WHERE da.Guide_Number = @GuideNumber
			AND da.Guide_Serie = @GuideSerie

		IF @@ROWCOUNT > 0
		BEGIN
			SET @DescriptionResult = 'Usuario Liberado de la incidencia'
		END
		ELSE
		BEGIN
			SET @DescriptionResult = 'No se encuentra registro'
		END
		
		SELECT @DescriptionResult AS DescriptionResult

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(500);
		SET @ErrorMessage = ERROR_MESSAGE();

		SET @DescriptionResult = 'Ocurrió el siguiente error: ' + @ErrorMessage
		SELECT @DescriptionResult AS DescriptionResult

	END CATCH
END;