-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-11-04>
-- Description:	<ZIGI - Actualizar informacion de link de pago zigi>
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePaymentZigiByGuide]
	@GuideNumber			INT,
	@GuideSerie				NVARCHAR(2),
	@ZigiLinkStatus			NVARCHAR(20),
	@ZigiReference			NVARCHAR(20),
	@ZigiTransactionId		NVARCHAR(100),
	@ZigiPaymentId			NVARCHAR(100),
	@DateTimeStamp			DATETIME,
	@Token					NVARCHAR(50)
AS
BEGIN
	BEGIN TRY
		UPDATE [dbo].[PaymentZigi]
		SET 
			ZigiLinkStatus		= @ZigiLinkStatus,
			ZigiTransactionId	= @ZigiTransactionId,
			PaymentId			= @ZigiPaymentId,
			DateTimeStamp		= @DateTimeStamp,
			DateUpdated			= GETDATE(),
			TokenUpdated		= @Token
		WHERE 
		GuideNumber = @GuideNumber 
		AND GuideSerie = @GuideSerie
		AND ZigiReference = @ZigiReference

		SELECT 200 [IdResult],
			'link actualizado' AS [Message]
		RETURN;

	END TRY
	BEGIN CATCH
		SELECT 400 AS [IdResult],
			'ERROR'	AS [Message]
		RETURN;

	END CATCH
END;