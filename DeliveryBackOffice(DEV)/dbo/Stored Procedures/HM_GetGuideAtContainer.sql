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
			, DOP.NoPiece		AS 'Pieces'
		FROM DeliveryBackOffice.dbo.ShippingContainerDetail SCD WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
			ON SCD.GuideSerie = DOP.GuideSerie AND SCD.GuideNumber = DOP.GuideNumber
		WHERE SCD.TicketNumber = @TicketNumber AND SCD.RowStatus = 1
		ORDER BY DOP.NoPiece DESC

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END
