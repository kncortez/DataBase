-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <13-01-2025>
-- Description:	<Se obtiene información de la guía a partir de un TicketNumber(ej.Temu).>
-- =============================================
CREATE PROCEDURE [dbo].[HM_GetGuideAtContainer]
	@TicketNumber AS NVARCHAR(25)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		SELECT
			  DO.Guide_Serie	AS 'GuideSerie'
			, DO.Guide_Number	AS 'GuideNumber'
			, COALESCE([DO].[Pieces_Dry], 0) + COALESCE([DO].[Pieces_Cold], 0)		AS 'Pieces'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		WHERE DO.Ticket_Number = @TicketNumber

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END
