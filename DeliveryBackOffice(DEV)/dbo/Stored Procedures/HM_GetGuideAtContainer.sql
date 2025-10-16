-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <13-01-2025>
-- Description:	<Se obtiene información de la guía a partir de un TicketNumber(ej.Temu).>
-- Create date: <06-05-2025>
-- Description:	<Se aumenta la cantidad de caracteres en el ticket number.>
-- Description:	<Se agrega filtro por guía si existe duplicidad de ticket number y cliente.>
-- =============================================
CREATE PROCEDURE [dbo].[HM_GetGuideAtContainer]
	@TicketNumber AS NVARCHAR(150),
	@IdCustomer AS INT = NULL,
	@GuideSerie AS NVARCHAR(3) = 'FD',
	@GuideNumber AS INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		SELECT
			  DO.Guide_Serie	AS 'GuideSerie'
			, DO.Guide_Number	AS 'GuideNumber'
			, COALESCE([DO].[Pieces_Dry], 0) + COALESCE([DO].[Pieces_Cold], 0)		AS 'Pieces'
			, C.IdCustomer AS 'IdCustomer'
			, C.Name AS 'CustomerName'
			, COUNT(DO.Guide_Number) OVER () AS 'TotalGuide'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.Customer C WITH(NOLOCK)
			ON DO.IdCustomer = C.IdCustomer
		WHERE DO.Ticket_Number = @TicketNumber 
		AND (@IdCustomer IS NULL OR DO.IdCustomer = @IdCustomer)
		AND (@GuideNumber IS NULL OR (DO.Guide_Serie = @GuideSerie
			 AND DO.Guide_Number = @GuideNumber));

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END
