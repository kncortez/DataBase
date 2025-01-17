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

		SELECT TOP 1
			  SCD.GuideSerie	AS 'GuideSerie'
			, SCD.GuideNumber	AS 'GuideNumber'
			, COALESCE([DO].[Pieces_Dry], 0) + COALESCE([DO].[Pieces_Cold], 0)		AS 'Pieces'
		FROM DeliveryBackOffice.dbo.ShippingContainerDetail SCD WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			ON SCD.GuideSerie = DO.Guide_Serie AND SCD.GuideNumber = DO.Guide_Number
		WHERE SCD.TicketNumber = @TicketNumber AND SCD.RowStatus = 1

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END
